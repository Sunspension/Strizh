//
//  STFeedTableViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 05/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STFeedTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var searchBar: UISearchBar!

    private var feedDataSource: STFeedDataSourceWrapper?
    
    private var favoritesFeedDataSource: STFeedDataSourceWrapper?
    
    private var searchFeedDataSource: STFeedDataSourceWrapper?
    
    private var searchFavoriteDataSource: STFeedDataSourceWrapper?
    
    private var dataSourceSwitch = UISegmentedControl(items: ["Вся Лента", "Избранное"])
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var shouldShowSearchResults = false
    
    private var filter: STFeedFilter?
    
    private var searchQueryString = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 176
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        
        self.tableView.register(cell: STPostTableViewCell.self)
        
        self.dataSourceSwitch.tintColor = UIColor.stBrightBlue
        self.dataSourceSwitch.addTarget(self, action: #selector(self.switchDataSource(control:)), for: .valueChanged)
        self.navigationItem.titleView = self.dataSourceSwitch
        
        let rigthItem = UIBarButtonItem(image: UIImage(named: "icon-filter"),
                                        landscapeImagePhone: UIImage(named: "icon-filter"),
                                        style: .plain, target: self, action: #selector(self.openFilter))
        
        self.navigationItem.rightBarButtonItem = rigthItem
        
        self.setCustomBackButton()
        self.setupDataSources()
        
        // set data source
        self.tableView.dataSource = self.feedDataSource!.dataSource
        
        self.tableView.showBusy()
        self.feedDataSource!.loadFeed()
        
        self.dataSourceSwitch.selectedSegmentIndex = 0
        
        self.setupSearchController()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataSource = self.dataSourceSwitch.selectedSegmentIndex == 0 ?
            (self.shouldShowSearchResults ? self.searchFeedDataSource : self.feedDataSource) :
            (self.shouldShowSearchResults ? self.searchFavoriteDataSource : self.favoritesFeedDataSource)
        
        let post = dataSource!.dataSource!.item(by: indexPath).item
        
        let images = dataSource!.imagesBy(post: post)
        
        let files = dataSource!.filesBy(post: post)
        
        let locations = dataSource!.locationsBy(post: post)
        
        if let user = dataSource?.userBy(post: post) {
            
            self.st_router_openPostDetails(post: post, user: user, images: images,
                                           files: files, locations: locations)
        }
    }
    
    //MARK: - UISearchBar delegate implementation
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        self.shouldShowSearchResults = true
        
        let dataSource = self.dataSourceSwitch.selectedSegmentIndex == 0 ? self.searchFeedDataSource : self.searchFavoriteDataSource
        
        self.tableView.dataSource = dataSource!.dataSource
        self.tableView.reloadData()
        self.tableView.hideBusy()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.shouldShowSearchResults = false
        
        let dataSource = self.dataSourceSwitch.selectedSegmentIndex == 0 ? self.feedDataSource : self.favoritesFeedDataSource
        
        self.tableView.dataSource = dataSource!.dataSource
        self.tableView.reloadData()
        self.tableView.hideBusy()
    }
    
    //MARK: - UISearchResultUpdating delegate implementation
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let dataSource = self.dataSourceSwitch.selectedSegmentIndex == 0 ? self.searchFeedDataSource : self.searchFavoriteDataSource
        
        if let string = searchController.searchBar.text {
            
            let query = string
            
            let time = DispatchTime.now() + 0.5
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                
                guard searchController.searchBar.text == query, self.searchQueryString != query else {
                    
                    return
                }
                
                dataSource!.reset()
                dataSource!.loadFeed(searchString: query)
                self.searchQueryString = query
            }
        }
    }

    
    func switchDataSource(control: UISegmentedControl) {
        
        switch control.selectedSegmentIndex {
            
        case 0:
            
            self.tableView.dataSource = self.feedDataSource!.dataSource
            self.feedDataSource!.loadFeedIfNotYet()
            break
            
        case 1:
            self.tableView.dataSource = self.favoritesFeedDataSource!.dataSource
            self.favoritesFeedDataSource!.loadFeedIfNotYet()
            break
            
        default:
            return
        }
        
        self.tableView.reloadData()
    }
    
    func openFilter() {
        
        let controller = STFeedFilterTableViewController() { [unowned self] in
            
            self.feedDataSource?.reloadFilter(notify: self.dataSourceSwitch.selectedSegmentIndex == 0)
            self.favoritesFeedDataSource?.reloadFilter(notify: self.dataSourceSwitch.selectedSegmentIndex == 1)
            self.tableView.reloadData()
        }
        
        let navi = STNavigationController(rootViewController: controller)
        
        self.present(navi, animated: true, completion: nil)
    }
    
    private func setupDataSources() {
        
        // setup data sources
        self.feedDataSource = STFeedDataSourceWrapper(onDataSourceChanged: self.onDataSourceChanged)
        self.feedDataSource!.onStartLoading = self.onStartLoading
        self.feedDataSource!.onStopLoading = self.onStopLoading
        self.feedDataSource!.initialize()
        
        self.searchFeedDataSource = STFeedDataSourceWrapper(onDataSourceChanged: self.onDataSourceChanged)
        self.searchFeedDataSource!.onStartLoading = self.onStartLoading
        self.searchFeedDataSource!.onStopLoading = self.onStopLoading
        self.searchFeedDataSource!.initialize()
        
        self.favoritesFeedDataSource = STFeedDataSourceWrapper(isFavorite: true, onDataSourceChanged: self.onDataSourceChanged)
        self.favoritesFeedDataSource!.onStartLoading = self.onStartLoading
        self.favoritesFeedDataSource!.onStopLoading = self.onStopLoading
        self.favoritesFeedDataSource!.initialize()
        
        self.searchFavoriteDataSource = STFeedDataSourceWrapper(isFavorite: true, onDataSourceChanged: self.onDataSourceChanged)
        self.searchFavoriteDataSource!.onStartLoading = self.onStartLoading
        self.searchFavoriteDataSource!.onStopLoading = self.onStopLoading
        self.searchFavoriteDataSource!.initialize()
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
    
    private func onDataSourceChanged(animation: Bool) {
        
        self.tableView.hideBusy()
        
        if animation {
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        else {
            
            self.tableView.reloadData()
        }
    }
    
    private func onStartLoading() {
        
        self.tableView.showBusy()
    }
    
    private func onStopLoading() {
        
        self.tableView.hideBusy()
    }
}
