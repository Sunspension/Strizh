//
//  STContactsController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 25/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STContactsController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    private var itemsSource: STContactsDataSourceWrapper?
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.allowsSelection = false
        
        self.tableView.register(cell: STContactCell.self)
        self.tableView.register(headerFooterCell: STContactHeaderCell.self)
        
        self.itemsSource = STContactsDataSourceWrapper(viewController: self)
        
        self.itemsSource!.loadingStatusChanged = { loadingStatus in
        
            switch loadingStatus {
                
            case .loading:
                
                self.tableView.showBusy()
                
            default:
                
                self.tableView.hideBusy()
                self.tableView.reloadData()
            }
        }
        
        self.tableView.dataSource = self.itemsSource!.dataSource
        self.tableView.delegate = self.itemsSource!.dataSource
        
        self.itemsSource!.synchronizeContacts()
        
        self.setupSearchController()
    }
    
    //MARK: - UISearchBar delegate implementation
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
//        let dataSource = self.dataSourceSwitch.selectedSegmentIndex == 0 ? self.searchFeedDataSource : self.searchFavoriteDataSource
//        
//        self.tableView.dataSource = dataSource!.dataSource
//        self.tableView.reloadData()
//        self.tableView.hideBusy()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
//        let dataSource = self.dataSourceSwitch.selectedSegmentIndex == 0 ? self.feedDataSource : self.favoritesFeedDataSource
//        
//        self.tableView.dataSource = dataSource!.dataSource
//        self.tableView.reloadData()
//        self.tableView.hideBusy()
    }
    
    //MARK: - UISearchResultUpdating delegate implementation
    
    func updateSearchResults(for searchController: UISearchController) {
        
//        let dataSource = self.dataSourceSwitch.selectedSegmentIndex == 0 ? self.searchFeedDataSource : self.searchFavoriteDataSource
//        
//        if let string = searchController.searchBar.text {
//            
//            let query = string
//            
//            let time = DispatchTime.now() + 0.5
//            
//            DispatchQueue.main.asyncAfter(deadline: time) {
//                
//                guard searchController.searchBar.text == query else {
//                    
//                    return
//                }
//                
//                dataSource!.reset()
//                dataSource!.loadFeed(searchString: query)
//            }
//        }
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
