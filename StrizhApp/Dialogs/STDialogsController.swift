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
    
    var postId: Int?
    
    
    deinit {
        
        disposeBag.dispose()
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
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kReceiveDialogBadgeNotification),
                                                         object: nil)
            .observeNext { [unowned self] notification in
                
                let badge = (notification.object as? STDialogBadge)!
                
                for i in 0 ... self.section.items.count - 1 {
                    
                    let dialogItem = self.section.items[i].item as! STDialog
                    
                    if dialogItem.id != badge.dialogId {
                        
                        continue
                    }
                    
                    let index = i
                    
                    self.api.loadDialogWithLastMessage(by: badge.dialogId)
                        .onSuccess(callback: { dialog in
                            
                            guard let lastMessage = dialog.message else {
                                
                                return
                            }
                            
                            let indexPath = IndexPath(row: index, section: 0)
                            self.section.items.remove(at: index)
                            
                            self.messages.insert(lastMessage)
                            self.section.insert(item: dialog,
                                                at: index,
                                                cellClass: STDialogCell.self,
                                                bindingAction: self.bindingAction)
                            
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    })
                    
                    break
                }
                
            }.dispose(in: disposeBag)
        
        self.loadDialogs()
    }
    
    //MARK: - UISearchBar delegate implementation
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
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
   
    private func setupSearchController() {
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor =
            UIColor(red: 232 / 255.0, green: 237 / 255.0, blue: 247 / 255.0, alpha: 1)
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
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
    
    fileprivate func loadDialogs() {
        
        self.loadingStatus = .loading
        self.tableView.showBusy()
        
        let page = self.shouldShowSearchResults ? self.searchPage : self.page
        
        api.loadDialogs(page: page, pageSize: self.pageSize, postId: self.postId, searchString: searchQueryString)
            
            .onSuccess { [unowned self] dialogPage in
            
                self.loadingStatus = .loaded
                self.tableView.hideBusy()
                
                if let control = self.refreshControl, control.isRefreshing {
                    
                    self.section.items.removeAll()
                    control.endRefreshing()
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
        if let opponentId = dialog.userIds.first(where: { $0.value != self.myUser.id }) {
            
            if let user = self.users.first(where: { $0.id == opponentId.value }) {
                
                viewCell.userName.text = user.firstName + " " + user.lastName
                
                if !user.imageUrl.isEmpty {
                    
                    let urlString = user.imageUrl + viewCell.userImage.queryResizeString()
                    
                    let filter = RoundedCornersFilter(radius: viewCell.userImage.bounds.width)
                    viewCell.userImage.af_setImage(withURL: URL(string: urlString)!,
                                                   filter: filter,
                                                   completion: nil)
                }
            }
        }
        
        // get the date and the time
        viewCell.time.text = dialog.createdAt.mediumLocalizedFormat
        
        // get last message
        if let message = self.messages.first(where: { $0.id == dialog.messageId }) {
            
            if message.userId == self.myUser.id {
                
                viewCell.inOutIcon.isSelected = true
                
                let prefixColor = UIColor(red: 75 / 255.0, green: 75 / 255.0, blue: 75 / 255.0, alpha: 1)
                let prefix = NSMutableAttributedString(attributedString: "Вы: ".string(with: prefixColor))
                
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
            self.loadDialogs()
            
        }).dispose(in: disposeBag)
    }
    
    fileprivate func reloadTableView() {
        
        self.tableView.reloadData()
        
        // dummy view
        if self.tableView.numberOfSections == 0
            || self.tableView.numberOfRows(inSection: 0) == 0 {
            
            self.showDummyView(imageName: "empty-dialogs",
                               title: "Диалогов нет",
                               subTitle: "Начните общение по темам, нажав \"написать сообщение\" в карточке из ленты.")
        }
        else {
            
            self.hideDummyView()
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
