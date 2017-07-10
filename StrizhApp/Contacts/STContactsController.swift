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

enum OpenContactsReasonEnum {
    
    case usual, newPost
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
    
    fileprivate var disposeBag = DisposeBag()
    
    fileprivate var searchString = ""
    
    var reason = OpenContactsReasonEnum.usual
    
    
    
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
        if self.navigationController?.viewControllers.index(of: self) == NSNotFound {
            
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
        
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(nibClass: STContactCell.self)
        self.tableView.register(headerFooterNibClass: STContactHeaderCell.self)
        
        self.title = "contacts_page_title".localized
        
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
            
            self.tableView.allowsMultipleSelection = true
            self.tableView.allowsSelection = true
        }
        else {
            
            self.tableView.allowsSelection = false
            
            self.notRelatedContactsSection.header(headerClass: STContactHeaderCell.self, bindingAction: { (cell, item) in
                
                let header = cell as! STContactHeaderCell
                header.title.text = "contacts_page_users_who_don't_use_app_title".localized
                header.title.textColor = UIColor.stSteelGrey
            })
            
            self.notRelatedContactsSection.headerItem?.cellHeight = 30
        }
        
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
        
            self.selectedItems.append((item.item as! STContact))
        }
        
        self.dataSource.onDidDeselectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) in
            
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
        
        self.dataSource.sections.append(TableSection())
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
        self.tableView.tableFooterView = UIView()
        
        self.setupSearchController()
        self.synchronizeContacts()
    }
    
    func nextAction() {
        
        self.postObject.userIds.append(contentsOf: self.selectedItems.array.map({ $0.contactUserId }))
        
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
    
    //MARK: - UISearchBar delegate implementation
    
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
    
    fileprivate func synchronizeContacts() {
        
        _ = self.contactsProvider.contacts.andThen { result in
            
            if let contacts = result.value {
                
                self.dataSource.sections.removeAll()
                self.createDataSource(for: self.dataSource, contacts: contacts)
                self.reloadTableView()
            }
        }
    }
    
    fileprivate func searchContacts(searchString: String) {
        
        self.searchDataSource.sections.removeAll()
        self.notRelatedContactsSection.items.removeAll()
        
        _ = self.contactsProvider.contacts.andThen { result in
            
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
        
        contacts.forEach({ contact in
            
            if contact.isRegistered {
                
                let letter = String(contact.firstName.characters.first!)
                
                var section = dataSource.sections.filter({ ($0.sectionType as? String) == letter }).first
                
                if section == nil {
                    
                    section = TableSection(title: letter)
                    section!.sectionType = letter
                    
                    section!.header(headerClass: STContactHeaderCell.self, item: letter, bindingAction: { (cell, item) in
                        
                        let header = cell as! STContactHeaderCell
                        let title = item.item as! String
                        
                        header.title.textColor = UIColor.black
                        header.title.text = title
                    })
                    
                    section!.headerItem!.cellHeight = 30
                    
                    dataSource.sections.append(section!)
                }
                
                section!.addItem(cellClass: STContactCell.self,
                                 item: contact,
                                 bindingAction: self.binding)
            }
            else {
                
                self.notRelatedContactsSection.addItem(cellClass: STContactCell.self,
                                                       item: contact,
                                                       bindingAction: self.binding)
            }
        })
        
        // sorting
        dataSource.sections.sort { (oneSection, otherSection) -> Bool in
            
            return (oneSection.sectionType as! String) < (otherSection.sectionType as! String)
        }
        
        if self.reason == .usual && self.notRelatedContactsSection.items.count > 0 {
            
            dataSource.sections.append(self.notRelatedContactsSection)
        }
    }
    
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
    
    fileprivate func binding(_ cell: UITableViewCell, item: TableSectionItem) {
        
        let viewCell = cell as! STContactCell
        let contact = item.item as! STContact
        
        viewCell.contactName.text = contact.firstName + " " + contact.lastName
        viewCell.addContact.isHidden = contact.isRegistered
        viewCell.layoutMargins = UIEdgeInsets.zero
        viewCell.separatorInset = UIEdgeInsets.zero
        viewCell.accessoryType = self.tableView.allowsSelection ? .checkmark : .none
        viewCell.disableSelection = self.reason == .usual
        
        if self.tableView.allowsSelection && self.selectedItems.contains(item.item as! STContact) {
            
            self.tableView.selectRow(at: item.indexPath, animated: false, scrollPosition: .none)
        }
        
        if !contact.isRegistered {
            
            let textToShare = "contacts_page_share_text".localized
            
            viewCell.addContact.reactive.tap.observe { [unowned self] _ in
                
                // analytics
                let container = AppDelegate.appSettings.dependencyContainer
                let analytics: STAnalytics = try! container.resolve()
                analytics.logEvent(eventName: st_eContactInvite)
                
                let activity = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
                self.present(activity, animated: true, completion: nil)
                
                }.dispose(in: viewCell.bag)
        }
        
        if contact.imageUrl.isEmpty {
            
            DispatchQueue.main.async {
                
                var defaultImage = UIImage(named: "avatar")
                defaultImage = defaultImage?.af_imageAspectScaled(toFill: viewCell.contactImage.bounds.size)
                viewCell.contactImage.image = defaultImage?.af_imageRoundedIntoCircle()
            }
            
            return
        }
        
        let urlString = contact.imageUrl + viewCell.contactImage.queryResizeString()
        viewCell.contactImage.af_setImage(withURL: URL(string: urlString)!, completion: nil)
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
            
            self.showDummyView(imageName: "empty-contacts",
                               title: "contacts_page_empty_contacts_title".localized,
                               subTitle: "contacts_page_empty_contacts_message".localized)
        }
        else {
            
            self.hideDummyView()
        }
    }
}
