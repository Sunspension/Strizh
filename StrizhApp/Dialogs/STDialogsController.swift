//
//  STDialogsController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage
import ReactiveKit

enum STDialogsControllerOpenReason {
    
    case openFromPush, regular
}

class STDialogsController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {


    fileprivate let dataSource = TableViewDataSource()
    
    fileprivate let section = TableSection()
    
    fileprivate var searchDataSource = TableViewDataSource()
    
    fileprivate var searchSection = TableSection()
    
    fileprivate var loadingStatus = STLoadingStatusEnum.idle
    
    fileprivate var loadingStatusSearch = STLoadingStatusEnum.idle
    
    fileprivate var hasMore = false
    
    fileprivate var hasMoreSearch = false
    
    fileprivate var page = 1
    
    fileprivate var searchPage = 1
    
    fileprivate var pageSize = 20
    
    fileprivate var users = Set<STUser>()
    
    fileprivate var messages = Set<STMessage>()
    
    fileprivate var myUser: STUser!
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate var shouldShowSearchResults = false
    
    fileprivate var searchQueryString = ""
    
    fileprivate var dialogId = 0
    
    var reason = STDialogsControllerOpenReason.regular
    
    var postId: Int?
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        disposeBag.dispose()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.analytics.logEvent(eventName: st_eDialogList)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.backgroundView = backgroundView
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorInset = .zero
        
        self.myUser = STUser.objects(by: STUser.self).first!
        
        self.setCustomBackButton()
        self.createRefreshControl()
        self.setupSearchController()
        self.setupDataSource()
        
        self.tableView.tableFooterView = UIView()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-filter"), style: .plain, target: self, action: #selector(self.openFilter))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDidReceiveNewMessageNotification(_:)), name: NSNotification.Name(kReceiveMessageNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDidReceiveDialogBadgeNotification(_:)), name: NSNotification.Name(kReceiveDialogBadgeNotification), object: nil)
        
        guard self.reason == .regular else {
            
            return
        }
        
        self.loadDialogs()
    }
    
    //MARK: - UISearchBar delegate implementation
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        self.analytics.logEvent(eventName: st_eDialogListSearch)
        
        self.shouldShowSearchResults = true
        
        self.refreshControl = nil
        
        self.tableView.dataSource = self.searchDataSource
        self.tableView.delegate = self.searchDataSource
        self.reloadTableView()
        self.tableView.hideBusy()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.shouldShowSearchResults = false
        
        self.createRefreshControl()
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        self.reloadTableView()
        self.tableView.hideBusy()
    }
    
    //MARK: - UISearchResultUpdating delegate implementation
    func updateSearchResults(for searchController: UISearchController) {
        
        if let string = self.searchController.searchBar.text {
            
            let query = string
            
            let time = DispatchTime.now() + 0.5
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                
                guard
                    
                    self.searchController.searchBar.text == query,
                    self.searchQueryString != query else {
                    
                    return
                }
                
                self.searchSection.items.removeAll()
                self.searchQueryString = query
                self.searchPage = 1
                self.loadDialogs()
            }
        }
    }
   
    func openDialog(by id: Int) {
        
        self.page = 1
        
        self.loadDialogs {
            
            if let index = self.section.items.index(where: { ($0.item as! STDialog).id == id }) {
                
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.selectRow(at: indexPath , animated: false, scrollPosition: .middle)
                self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: indexPath)
            }
        }
    }
    
    func openFilter() {
        
        let controller = STFeedFilterTableViewController() { [unowned self] in
            
            var userIdAndIsIncoming: (Int, Bool)? = nil
            
            // analytics
            if let filter = STDialogFilter.objects(by: STDialogFilter.self).first {
                
                if filter.isIncoming {
                    
                    userIdAndIsIncoming = (self.myUser.id, true)
                }
                    
                if filter.isOutgoing {
                    
                    userIdAndIsIncoming = (self.myUser.id, false)
                }
            }
         
            self.page = 1
            self.loadDialogs(userIdAndIsIncoming: userIdAndIsIncoming)
        }
        
        controller.filter = AppDelegate.appSettings.dialogFilter
        
        let navi = STNavigationController(rootViewController: controller)
        
        self.present(navi, animated: true, completion: nil)
    }

    func onDidReceiveNewMessageNotification(_ notification: Notification) {
        
        self.page = 1
        self.loadDialogs()
    }
    
    func onDidReceiveDialogBadgeNotification(_ notification: Notification) {
        
        if self.loadingStatus == .loading {
            
            return
        }
        
        let badge = (notification.object as? STDialogBadge)!
        
        if let targetDialog = self.section.items.first(where: { ($0.item as! STDialog).id == badge.dialogId }) {
            
            self.api.loadDialogWithLastMessage(by: badge.dialogId)
                .onSuccess(callback: { [unowned self] dialog in
                    
                    guard let lastMessage = dialog.message else {
                        
                        return
                    }
                    
                    if let index = self.section.items.index(of: targetDialog) {
                        
                        self.messages.insert(lastMessage)
                        
                        let indexPath = IndexPath(row: index, section: 0)
                        self.section.items.remove(at: index)
                        self.section.insert(item: dialog,
                                            at: index,
                                            cellClass: STDialogCell.self,
                                            bindingAction: self.bindingAction)
                        
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                })
        }
    }
    
    //MARK: - Private methods
    
    private func setupSearchController() {
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor =
            UIColor(red: 232 / 255.0, green: 237 / 255.0, blue: 247 / 255.0, alpha: 1)
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "placeholder_search".localized
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor.stLightBlueGrey
        searchController.searchBar.backgroundImage = UIImage()
        self.definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    fileprivate func setupDataSource() {
        
        self.dataSource.sections.append(self.section)
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
        self.dataSource.onDidSelectRowAtIndexPath = { [unowned self] (tableView, indexPath, item) in
            
            let dialog = item.item as! STDialog
            
            let userIds = dialog.userIds.map({ $0.value })
            let users = self.users.filter({ userIds.contains($0.id) })
            
            self.st_router_openChatController(dialog: dialog, users: users)
        }
        
        self.searchDataSource.sections.append(self.searchSection)
        
        self.searchDataSource.onDidSelectRowAtIndexPath = { [unowned self] (tableView, indexPath, item) in
            
            let dialog = item.item as! STDialog
            
            let userIds = dialog.userIds.map({ $0.value })
            let users = self.users.filter({ userIds.contains($0.id) })
            
            self.st_router_openChatController(dialog: dialog, users: users)
        }
    }
    
    fileprivate func loadDialogs(userIdAndIsIncoming: (Int, Bool)? = nil, completion: (() -> Void)? = nil) {
        
        self.loadingStatus = .loading
        self.tableView.showBusy()
        
        let page = self.shouldShowSearchResults ? self.searchPage : self.page
        
        self.analytics.logEvent(eventName: st_eDialogListScroll, params: ["page" : page])
        
        api.loadDialogs(page: page,
                        pageSize: self.pageSize,
                        postId: self.postId,
                        userIdAndIsIncoming: userIdAndIsIncoming,
                        searchString: searchQueryString)
            
            .onSuccess { [unowned self] dialogPage in
            
                self.loadingStatus = .loaded
                self.tableView.hideBusy()
                
                if let control = self.refreshControl, control.isRefreshing {
                    
                    self.section.items.removeAll()
                    control.endRefreshing()
                }
                
                if (self.page == 1) {
                    
                    self.section.items.removeAll()
                }
                
                if self.shouldShowSearchResults {
                    
                    self.searchPage += 1
                    self.hasMoreSearch = dialogPage.dialogs.count == self.pageSize
                }
                else {
                    
                    self.page += 1
                    self.hasMore = dialogPage.dialogs.count == self.pageSize
                }
                
                self.handleResponse(dialogPage)
                self.reloadTableView()
                completion?()
            }
            .onFailure { [unowned self] error in
                
                if self.shouldShowSearchResults {
                    
                    self.loadingStatusSearch = .failed
                }
                else {
                    
                    self.loadingStatus = .failed
                }
                
                self.tableView.hideBusy()
                
                if let control = self.refreshControl, control.isRefreshing {
                    
                    control.endRefreshing()
                }
                
                self.showError(error: error)
            }
    }
    
    fileprivate func handleResponse(_ dialogsPage: STDialogsPage) {
        
        self.messages = self.messages.union(dialogsPage.messages)
        self.users = self.users.union(dialogsPage.users)
        
        if self.shouldShowSearchResults {
            
            for dialog in dialogsPage.dialogs {
                
                self.searchSection.addItem(cellClass: STDialogCell.self,
                                           item: dialog, bindingAction: self.bindingAction)
            }
        }
        else {
            
            for dialog in dialogsPage.dialogs {
                
                self.section.addItem(cellClass: STDialogCell.self,
                                     item: dialog, bindingAction: self.bindingAction)
            }
        }
    }
    
    fileprivate func bindingAction(cell: UITableViewCell, item: TableSectionItem) {
        
        if item.indexPath.row + 10 > self.section.items.count
            && self.loadingStatus != .loading && self.hasMore {
            
            self.loadDialogs()
        }
        
        let viewCell = cell as! STDialogCell
        let dialog = item.item as! STDialog
        
        viewCell.topicTitle.text = dialog.title
        
        // unread
        if (dialog.unreadMessageCount == 0) {
            
            viewCell.newMessageCounter.isHidden = true
            viewCell.backgroundView?.backgroundColor = UIColor.white
        }
        else {
            
            viewCell.backgroundView?.backgroundColor = UIColor.stPaleGrey
            viewCell.newMessageCounter.isHidden = false
            viewCell.newMessageCounter.setTitle("\(dialog.unreadMessageCount)", for: .normal)
            viewCell.newMessageCounter.sizeToFit()
        }
        
        // get user
        if let user = self.users.first(where: { $0.id == dialog.ownerUserId }) {
            
            viewCell.userName.text = user.firstName + " " + user.lastName
            
            if !user.imageUrl.isEmpty {
                
                let urlString = user.imageUrl + viewCell.userImage.queryResizeString()
                
                let filter = RoundedCornersFilter(radius: viewCell.userImage.bounds.width)
                viewCell.userImage.af_setImage(withURL: URL(string: urlString)!,
                                               filter: filter,
                                               completion: nil)
            }
            else {
                
                DispatchQueue.main.async {
                    
                    var defaultImage = UIImage(named: "avatar")
                    defaultImage = defaultImage?.af_imageAspectScaled(toFill: viewCell.userImage.bounds.size)
                    viewCell.userImage.image = defaultImage?.af_imageRoundedIntoCircle()
                }
            }
        }
        
        // get the date and the time
        viewCell.time.text = dialog.updatedAt != nil ?
            dialog.updatedAt?.mediumLocalizedFormat : dialog.createdAt.mediumLocalizedFormat
        
        // get last message
        if let message = self.messages.first(where: { $0.id == dialog.messageId }) {
            
            if message.userId == self.myUser.id {
                
                viewCell.inOutIcon.isSelected = true
                
                let prefixColor = UIColor(red: 75 / 255.0, green: 75 / 255.0, blue: 75 / 255.0, alpha: 1)
                let prefix = NSMutableAttributedString(attributedString: "prefix_you".localized.string(with: prefixColor))
                
                let messageColor = UIColor(red: 129 / 255.0, green: 129 / 255.0, blue: 129 / 255.0, alpha: 1)
                prefix.append(message.message.string(with: messageColor))
                
                viewCell.message.attributedText = prefix
            }
            else {
                
                viewCell.inOutIcon.isSelected = false
                viewCell.message.text = message.message
            }
        }
    }
    
    fileprivate func createRefreshControl() {
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.reactive.refreshing.observeNext(with: { [unowned self] refreshing in
            
            if !refreshing {
                
                return
            }
            
            self.page = 1
            
            self.analytics.logEvent(eventName: st_eDialogListRefresh)
            
            self.loadDialogs()
            
        }).dispose(in: disposeBag)
    }
    
    fileprivate func reloadTableView() {
        
        self.tableView.reloadData()
        
        // dummy view
        if self.tableView.numberOfSections == 0
            || self.tableView.numberOfRows(inSection: 0) == 0 {
            
            self.showDummyView(imageName: "empty-dialogs", title: "dummy_dialogs_title".localized,
                               subTitle: "dummy_dialogs_subtitle".localized)
        }
        else {
            
            self.hideDummyView()
        }
    }
}
