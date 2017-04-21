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
    
    private var itemsSource: STContactsDataSourceWrapper?
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var shouldShowSearchResults = false
    
    private let selectedItems = MutableObservableArray([Int]())
    
    private lazy var postObject: STUserPostObject = {
        
        return try! self.dependencyContainer.resolve(STUserPostObject.self) as! STUserPostObject
        
    }()
    
    var disposeBag: Disposable?
    
    var reason = OpenContactsReasonEnum.usual
    
    
    deinit {
        
        disposeBag?.dispose()
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
         
            api.createPost(post: self.postObject)
                
                .onSuccess(callback: { [unowned self] post in
                    
                    self.stopAnimating()
                    
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
