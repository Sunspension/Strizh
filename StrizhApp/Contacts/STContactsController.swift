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
    
    var bag: Disposable?
    
    var reason = OpenContactsReasonEnum.usual
    
    
    deinit {
        
        bag?.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(nibClass: STContactCell.self)
        self.tableView.register(headerFooterNibClass: STContactHeaderCell.self)
        
        self.title = "Контакты"
        
        if self.reason == .newPost {
            
            let rightItem = UIBarButtonItem(title: "Создать", style: .plain, target: self, action: #selector(self.nextAction))
            rightItem.isEnabled = false
            self.navigationItem.rightBarButtonItem = rightItem
            
            self.bag = self.selectedItems.observeNext(with: { event in
                
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
            
            self.tableView.reloadData()
        }
        
        self.itemsSource!.dataSource.onDidSelectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: CollectionSectionItem) in
        
            self.selectedItems.append((item.item as! STContact).contactUserId)
        }
        
        self.itemsSource!.dataSource.onDidDeselectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: CollectionSectionItem) in
            
            let contactId = (item.item as! STContact).contactUserId
            let index = self.selectedItems.index(of: (contactId))!
            self.selectedItems.remove(at: index)
        }
        
        self.tableView.dataSource = self.itemsSource!.dataSource
        self.tableView.delegate = self.itemsSource!.dataSource
        
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
                    
                    self.showOkAlert(title: "Успешно", message:"Вы успешно создали новую тему", okAction: {
                        
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
                    
                    self.showOkAlert(title: "Успешно", message:"Вы успешно обновили тему", okAction: {
                        
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
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.tableView.dataSource = self.itemsSource?.dataSource
        self.tableView.delegate = self.itemsSource?.dataSource
        self.tableView.reloadData()
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
                self.tableView.reloadData()
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
}
