//
//  STContactsController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 25/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ReactiveKit
import Bond
import Dip
import AlamofireImage

enum OpenContactsReasonEnum {
    
    case usual, newPost
}

fileprivate enum TypeOfRecepientsEnum {
    
    case all, contactsOnly
}

fileprivate enum InviteSectionItemEnum {
    
    case invite
}

class STContactsController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, NVActivityIndicatorViewable {
    
    
    fileprivate var contactsProvider = STContactsProvider.sharedInstance
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate let selectedItems = MutableObservableArray([STContact]())
    
    fileprivate lazy var postObject: STUserPostObject = {
        
        return try! self.dependencyContainer.resolve(STUserPostObject.self) as! STUserPostObject
        
    }()
    
    fileprivate let dataSource = TableViewDataSource()
    
    fileprivate let searchDataSource = TableViewDataSource()
    
    fileprivate let notRelatedContactsSection = TableSection()
    
    fileprivate let typeOfRecepientsSection = TableSection()
    
    fileprivate let inviteSection = TableSection()
    
    fileprivate var disposeBag = DisposeBag()
    
    fileprivate var searchString = ""
    
    fileprivate var keyBoardHeight: CGFloat = 0
    
    fileprivate var isPublic = true
    
    var reason = OpenContactsReasonEnum.usual
    
    fileprivate var myUser: STUser {
        
        return STUser.objects(by: STUser.self).first!
    }
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if self.reason == .newPost {
            
            self.analytics.logEvent(eventName: st_eNewPostStep3, timed: true)
        }
        else {
            
            self.analytics.logEvent(eventName: st_eContacts)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        // checking press back button
        if self.navigationController?.viewControllers.index(of: self) == nil {
            
            if self.reason != .newPost {
                
                return
            }
            
            self.analytics.endTimeEvent(eventName: st_eNewPostStep3)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.stLightBlueGrey
        
        self.tableView.backgroundView = backgroundView
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(nibClass: STContactCell.self)
        self.tableView.register(headerFooterNibClass: STContactHeaderCell.self)
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
        self.title = "contacts_page_title".localized
        
        setup()
        setCustomBackButton()
        setupDataSource()
        synchronizeContacts()
    }
    
    func nextAction() {
        
        self.postObject.userIds.append(contentsOf: self.selectedItems.array.map({ $0.contactUserId }))
        self.postObject.isPublic = self.isPublic
        
        self.startAnimating()
        
        switch self.postObject.objectType {
            
        case .new:
         
            if self.selectedItems.count > 0 {
                
                _ = self.contactsProvider.contacts.andThen(callback: { result in
                    
                    if let totalContacts = result.value {
                        
                        self.analytics.logEvent(eventName: st_eNewPostContactSelect, params: ["select_count" : self.selectedItems.count,
                                                                                              "total_count" : totalContacts.count])
                    }
                })
            }
            
            self.analytics.endTimeEvent(eventName: st_eNewPostStep3)
            
            api.createPost(post: self.postObject)
                
                .onSuccess(callback: { [unowned self] post in
                    
                    self.stopAnimating()
                    self.analytics.logEvent(eventName: st_eNewPostCreateFinish, params: ["select_count" : self.selectedItems.count])
                    
                    NotificationCenter.default.post(name: NSNotification.Name(kPostCreatedNotification), object: post)
                    
                    self.showOkAlert(title: "contacts_page_success_title".localized,
                                     message:"contacts_page_success_create_message".localized, okAction: {
                        
                        action in self.navigationController?.dismiss(animated: true, completion: nil)
                    })
                })
                .onFailure(callback: { [unowned self] error in
                    
                    self.stopAnimating()
                    self.showError(error: error)
                })
            
            break
            
        case .old:
            
            api.updatePost(post: self.postObject)
                
                .onSuccess(callback: { [unowned self] post in
                    
                    self.stopAnimating()
                    
                    // still having the same behavior
                    NotificationCenter.default.post(name: NSNotification.Name(kPostCreatedNotification), object: post)
                    
                    self.showOkAlert(title: "contacts_page_success_title".localized,
                                     message:"contacts_page_success_update_message".localized, okAction: {
                        
                        action in self.navigationController?.dismiss(animated: true, completion: nil)
                    })
                })
                .onFailure(callback: { [unowned self] error in
                    
                    self.stopAnimating()
                    self.showError(error: error)
                })
            
            break
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let height = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            self.keyBoardHeight = height
        }
        
        if let dummy = self.dummyView() {
            
            let inset = self.tableView.contentInset
            let bounds = self.view.bounds
            let visibleRect = CGRect(x: bounds.minX,
                                     y: inset.top,
                                     width: bounds.width,
                                     height: bounds.height - self.keyBoardHeight)
            
            dummy.center = CGPoint(x: dummy.center.x, y: visibleRect.midY)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        if let dummy = self.dummyView() {
            
            let inset = self.tableView.contentInset
            let bounds = self.view.bounds
            let visibleRect = CGRect(x: bounds.minX,
                                     y: inset.top,
                                     width: bounds.width,
                                     height: bounds.height - inset.bottom)
            
            dummy.center = CGPoint(x: dummy.center.x, y: visibleRect.midY)
        }
    }
    
    //MARK: - UISearchBar delegate implementation
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        return reason == .usual ? true : isPublic == false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if self.reason == .newPost {
            
            self.analytics.logEvent(eventName: st_eNewPostContactSearch)
        }
        
        self.tableView.dataSource = self.searchDataSource
        self.tableView.delegate = self.searchDataSource
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        self.reloadTableView()
    }
    
    //MARK: - UISearchResultUpdating delegate implementation
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let string = searchController.searchBar.text {
            
            let query = string
            
            let time = DispatchTime.now() + 0.3
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                
                guard searchController.searchBar.text == query else {
                    
                    return
                }
                
                self.searchContacts(searchString: query)
                self.analytics.logEvent(eventName: st_eContactSearch, params: ["query" : query])
            }
        }
    }
    
    //MARK: - Private methods
    
    fileprivate func setup() {
        
        if self.reason == .newPost {
            
            let rightItem = UIBarButtonItem(title: "contacts_page_create_text".localized,
                                            style: .plain, target: self, action: #selector(self.nextAction))
            rightItem.isEnabled = false
            self.navigationItem.rightBarButtonItem = rightItem
            
            self.selectedItems.observeNext(with: { [unowned self] event in
                
                rightItem.isEnabled = event.dataSource.count != 0
                
                if (event.dataSource.count == 0) {
                    
                    self.title = "contacts_page_title".localized
                }
                else {
                    
                    self.title = "contacts_page_title".localized + "(\(event.dataSource.count))"
                }
            })
                .dispose(in: self.disposeBag)
            
            self.tableView.allowsMultipleSelection = !isPublic
            
            //            self.notRelatedContactsSection.header(headerClass: STContactHeaderCell.self, bindingAction: { (cell, item) in
            //
            //                let header = cell as! STContactHeaderCell
            //                header.title.text = "contacts_page_users_who_don't_use_app_title".localized
            //                header.title.textColor = UIColor.stSteelGrey
            //            })
            //
            //            self.notRelatedContactsSection.headerItem?.cellHeight = 30
        }
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kUserUpdatedNotification), object: nil)
            .observeNext { [unowned self] notification in
                
                self.tableView.reloadData()
            }
            .dispose(in: disposeBag)
    }
    
    fileprivate func setupTypeOfRecepientsSection() {
        
        self.typeOfRecepientsSection.add(itemType: TypeOfRecepientsEnum.all, cellStyle: .subtitle) { (cell, item) in
            
            item.cellHeight = 65
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.detailTextLabel?.textColor = UIColor(red: 129 / 255.0, green: 137 / 255.0, blue: 150 / 255.0, alpha: 1)
            cell.detailTextLabel?.numberOfLines = 0
            cell.textLabel?.text = "Все пользователи Strizhapp"
            cell.detailTextLabel?.text = "После модерации сделка отправится всем пользователям Strizhapp"
            cell.accessoryType = .checkmark
            cell.selectionStyle = .none
            cell.tintColor = self.isPublic ? UIColor.stBrightBlue : UIColor.lightGray
            
            self.tableView.selectRow(at: item.indexPath, animated: false, scrollPosition: .none)
        }
        
        self.typeOfRecepientsSection.add(itemType: TypeOfRecepientsEnum.contactsOnly, cellStyle: .subtitle) { (cell, item) in
            
            item.cellHeight = 65
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.detailTextLabel?.textColor = UIColor(red: 129 / 255.0, green: 137 / 255.0, blue: 150 / 255.0, alpha: 1)
            cell.detailTextLabel?.numberOfLines = 0
            cell.textLabel?.text = "Мои контакты"
            cell.detailTextLabel?.text = "Выберите получателей из своих зарегистрированных контактов"
            cell.selectionStyle = .none
            cell.accessoryType = .checkmark
            cell.tintColor = !self.isPublic ? UIColor.stBrightBlue : UIColor.lightGray
        }
        
        self.dataSource.sections.append(self.typeOfRecepientsSection)
        
        let dummySection = TableSection()
        
        // dummy cell
        dummySection.add(cellStyle: .default, bindingAction: { (cell, item) in
            
            item.cellHeight = 14
            cell.backgroundColor = UIColor.clear
        })
        
        self.dataSource.sections.append(dummySection)
    }
    
    fileprivate func setupDataSource() {
        
        self.contactsProvider.loadingStatusChanged = { loadingStatus in
            
            switch loadingStatus {
                
            case .loading:
                
                self.tableView.showBusy()
                
            default:
                
                self.tableView.hideBusy()
            }
        }
        
        self.dataSource.onDidSelectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) in
            
            if let type =  item.itemType as? TypeOfRecepientsEnum {
                
                switch type {
                    
                case .contactsOnly:
                    
                    self.isPublic = false
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    self.tableView.allowsMultipleSelection = !self.isPublic
                    self.tableView.reloadData()
                    
                    break
                    
                default:
                    break
                }
                
                return
            }
            
            if let type = item.itemType as? InviteSectionItemEnum {
                
                switch type {
                    
                case .invite:
                    
                    tableView.deselectRow(at: indexPath, animated: true)
                    self.inviteContacts()
                    
                    break
                }
                
                return
            }
            
            if self.reason != .newPost {
                
                return
            }
            
            self.selectedItems.append((item.item as! STContact))
        }
        
        self.dataSource.onDidDeselectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) in
            
            if let type =  item.itemType as? TypeOfRecepientsEnum {
                
                if type == .all {
                    
                    self.isPublic = true
                    self.selectedItems.removeAll()
                    self.tableView.allowsMultipleSelection = !self.isPublic
                    self.tableView.reloadData()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                }
                
                return
            }
            
            if self.reason != .newPost {
                
                return
            }
            
            let index = self.selectedItems.index(of: item.item as! STContact)!
            self.selectedItems.remove(at: index)
        }
        
        self.searchDataSource.onDidSelectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) in
            
            self.selectedItems.append((item.item as! STContact))
        }
        
        self.searchDataSource.onDidDeselectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) in
            
            let index = self.selectedItems.index(of: item.item as! STContact)!
            self.selectedItems.remove(at: index)
        }
    }
    
    fileprivate func synchronizeContacts() {
        
        _ = self.contactsProvider.registeredContacts.andThen { result in
            
            if let contacts = result.value {
                
                // when user trying to edit post
                if self.reason == .newPost {
                    
                    if self.postObject.userIds.count > 0 {
                        
                        for userId in self.postObject.userIds {
                            
                            if let contact = contacts.first(where: { $0.contactUserId == userId }) {
                                
                                self.selectedItems.append(contact)
                            }
                        }
                    }
                    
                    self.setupTypeOfRecepientsSection()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
                else {
                    
                    self.inviteSection.add(itemType: InviteSectionItemEnum.invite,
                                           cellClass: STContactCell.self, bindingAction: { (cell, item) in
                                            
                                            let viewCell = cell as! STContactCell
                                            viewCell.contactImage.setImage(UIImage(named: "icon-invite"), for: .normal)
                                            viewCell.contactName.text = "Пригласить в STRIZHAPP"
                                            viewCell.contactName.font = UIFont.systemFont(ofSize: 16)
                                            viewCell.contactName.textColor = UIColor.stBrightBlue
                                            viewCell.accessoryType = .none
                                            viewCell.disableSelection = true
                                            viewCell.selectionStyle = .default
                    })
                    
                    self.dataSource.sections.append(self.inviteSection)
                }
                
                self.createDataSource(for: self.dataSource, contacts: contacts)
                self.setupSearchController()
                self.reloadTableView()
            }
        }
    }
    
    fileprivate func searchContacts(searchString: String) {
        
        self.searchDataSource.sections.removeAll()
//        self.notRelatedContactsSection.items.removeAll()
        
        _ = self.contactsProvider.registeredContacts.andThen { result in
            
            guard let contacts = result.value else {
                
                return
            }
            
            if searchString.isEmpty {
                
                self.createDataSource(for: self.searchDataSource, contacts: contacts)
                self.reloadTableView()
                return
            }
            
            let items = contacts.filter({ $0.firstName.contains(searchString) || $0.lastName.contains(searchString) })
            self.createDataSource(for: self.searchDataSource, contacts: items)
            self.reloadTableView()
        }
    }
    
    fileprivate func createDataSource(for dataSource: TableViewDataSource, contacts: [STContact]) {
        
        for contact in contacts {
            
            if contact.isRegistered {
                
                let letter = String(contact.firstName.characters.first!)
                var section = dataSource.sections.filter({ $0.title == letter }).first
                
                if section == nil {
                    
                    section = TableSection(title: letter)
                    
                    section!.header(item: letter, headerClass: STContactHeaderCell.self, bindingAction: { (cell, item) in
                        
                        let header = cell as! STContactHeaderCell
                        let title = item.item as! String
                        
                        header.title.textColor = UIColor.black
                        header.title.text = title
                    })
                    
                    section!.headerItem!.cellHeight = 30
                    
                    dataSource.sections.append(section!)
                }
                
                section!.add(item: contact,
                             cellClass: STContactCell.self,
                             bindingAction: self.binding)
            }
            else {
                
                self.notRelatedContactsSection.add(item: contact,
                                                   cellClass: STContactCell.self,
                                                   bindingAction: self.binding)
            }
        }
        
        // sorting
        dataSource.sections.sort { (oneSection, otherSection) -> Bool in
            
            return oneSection.title! < otherSection.title!
        }
        
//        if self.reason == .newPost && self.notRelatedContactsSection.items.count > 0 {
//            
//            dataSource.sections.append(self.notRelatedContactsSection)
//        }
    }
    
    private func setupSearchController() {
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "placeholder_search".localized
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor.stLightBlueGrey
        searchController.searchBar.backgroundImage = UIImage()
        
        if let textField = searchController.searchBar.value(forKey: "_searchField") as? UITextField {
            
            textField.backgroundColor = UIColor.stPaleGreyTwo
        }
        
        self.definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    @objc fileprivate func inviteContacts() {
        
        var textToShare = "https://strizhapp.ru"
        
        if let user = STUser.objects(by: STUser.self).first {
            
            textToShare += "/?ref=\(user.id)"
        }
        
        let activity = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
        
        // analytics
        let container = AppDelegate.appSettings.dependencyContainer
        let analytics: STAnalytics = try! container.resolve()
        analytics.logEvent(eventName: st_eContactInvite)
    }
    
    fileprivate func binding(_ cell: UITableViewCell, item: TableSectionItem) {
        
        let viewCell = cell as! STContactCell
        let contact = item.item as! STContact
        
        viewCell.contactName.textColor = UIColor.black
        viewCell.contactName.text = contact.firstName + " " + contact.lastName
        viewCell.layoutMargins = UIEdgeInsets.zero
        viewCell.separatorInset = UIEdgeInsets.zero
        viewCell.accessoryType = self.reason == .newPost ? .checkmark : .none
        viewCell.disableSelection = self.reason == .usual
        viewCell.selectionStyle = .none
        
        if reason == .usual {
            
            viewCell.disableSelection = true
        }
        else {
            
            viewCell.disableSelection = false
            viewCell.isDisabledCell = self.isPublic
        }
        
        if self.tableView.allowsSelection && self.selectedItems.contains(item.item as! STContact) {
            
            self.tableView.selectRow(at: item.indexPath, animated: false, scrollPosition: .none)
        }
        
        viewCell.contactImage.reactive.tap.observeNext { [unowned self] in
            
                self.st_router_openUserProfile(userId: contact.contactUserId)
            }
            .dispose(in: viewCell.disposeBag)
        
        if contact.userId == myUser.id && self.myUser.imageData != nil {
            
            if let image = UIImage(data: self.myUser.imageData!) {
                
                let userIcon = image.af_imageAspectScaled(toFill: viewCell.contactImage.bounds.size)
                viewCell.contactImage.setImage(userIcon.af_imageRoundedIntoCircle(), for: .normal)
            }
        }
        else {
            
            if contact.imageUrl.isEmpty {
                
                var defaultImage = UIImage(named: "avatar")
                defaultImage = defaultImage?.af_imageAspectScaled(toFill: viewCell.contactImage.bounds.size)
                viewCell.contactImage.setImage(defaultImage?.af_imageRoundedIntoCircle(), for: .normal)
            }
            else {
                
                let urlString = contact.imageUrl + viewCell.contactImage.queryResizeString()
                let filter = RoundedCornersFilter(radius: viewCell.contactImage.bounds.size.width)
                viewCell.contactImage.af_setImage(for: .normal, url: URL(string: urlString)!, filter: filter)
            }
        }
    }
    
    private func reloadTableView(animation: Bool = false) {
        
        if animation {
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        else {
            
            self.tableView.reloadData()
        }
        
        if self.tableView.numberOfSections == 0
            || self.tableView.numberOfRows(inSection: 0) == 0 {
            
            if self.keyBoardHeight != 0 {
                
                let inset = self.tableView.contentInset
                let bounds = self.view.bounds
                let visibleRect = CGRect(x: bounds.minX,
                                         y: inset.top,
                                         width: bounds.width,
                                         height: bounds.height - self.keyBoardHeight)
                
                self.showDummyView(imageName: "empty-contacts",
                                   title: "contacts_page_empty_contacts_title".localized,
                                   subTitle: "contacts_page_empty_contacts_message".localized,
                                   inRect: visibleRect)
                return
            }
            
            self.showDummyView(imageName: "empty-contacts",
                               title: "contacts_page_empty_contacts_title".localized,
                               subTitle: "contacts_page_empty_contacts_message".localized)
        }
        else {
            
            self.hideDummyView()
        }
    }
}
