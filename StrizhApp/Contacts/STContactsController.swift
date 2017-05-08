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

class STContactsController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, NVActivityIndicatorViewable {
    
    enum OpenContactsReasonEnum {
        
        case usual, newPost
    }
    
    fileprivate var itemsSource: STContactsDataSourceWrapper?
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate var shouldShowSearchResults = false
    
    fileprivate let selectedItems = MutableObservableArray([Int]())
    
    fileprivate lazy var postObject: STUserPostObject = {
        
        return try! self.dependencyContainer.resolve(STUserPostObject.self) as! STUserPostObject
        
    }()
    
    var disposeBag: Disposable?
    
    var reason = OpenContactsReasonEnum.usual
    
    
    deinit {
        
        disposeBag?.dispose()
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
            
            self.disposeBag = self.selectedItems.observeNext(with: { event in
                
                rightItem.isEnabled = event.dataSource.count != 0
            })
        }
        
        self.itemsSource = STContactsDataSourceWrapper(viewController: self)
        
        if self.reason == .newPost {
            
            self.tableView.allowsMultipleSelection = true
            self.itemsSource!.allowsSelection = true
            self.itemsSource!.showOnlyRegistered = true
        }
        else {
            
            self.tableView.allowsSelection = false
        }
        
        self.itemsSource!.loadingStatusChanged = { loadingStatus in
        
            switch loadingStatus {
                
            case .loading:
                
                self.tableView.showBusy()
                
            default:
                
                self.tableView.hideBusy()
            }
        }
        
        self.itemsSource!.onDataSourceChanged = {
            
            self.reloadTableView()
        }
        
        self.itemsSource!.dataSource.onDidSelectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) in
        
            self.selectedItems.append((item.item as! STContact).contactUserId)
        }
        
        self.itemsSource!.dataSource.onDidDeselectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) in
            
            let contactId = (item.item as! STContact).contactUserId
            let index = self.selectedItems.index(of: (contactId))!
            self.selectedItems.remove(at: index)
        }
        
        self.tableView.dataSource = self.itemsSource!.dataSource
        self.tableView.delegate = self.itemsSource!.dataSource
        
        self.tableView.tableFooterView = UIView()
        
        self.itemsSource!.synchronizeContacts()
        
        self.setupSearchController()
    }
    
    func nextAction() {
        
        self.postObject.userIds.append(contentsOf: self.selectedItems.array)
        
        startAnimating()
        
        switch self.postObject.objectType {
            
        case .new:
         
            if self.selectedItems.count > 0 {
                
                let totalCount = self.itemsSource!.dataSource.sections.reduce(0, { (result, section) -> Int in
                    
                    return result + section.items.count
                })
                
                self.analytics.logEvent(eventName: st_eNewPostContactSelect, params: ["select_count" : self.selectedItems.count, "total_count" : totalCount])
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
        
        self.tableView.dataSource = self.itemsSource?.searchDataSource
        self.tableView.delegate = self.itemsSource?.searchDataSource
        self.reloadTableView()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.tableView.dataSource = self.itemsSource?.dataSource
        self.tableView.delegate = self.itemsSource?.dataSource
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
                
                self.analytics.logEvent(eventName: st_eContactSearch, params: ["query" : query])
                
                self.itemsSource?.searchContacts(searchString: query)
                self.reloadTableView()
            }
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
