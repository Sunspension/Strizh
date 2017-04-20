//
//  STFeedTableViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 05/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit

class STFeedTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var searchBar: UISearchBar!

    fileprivate var feedDataSource: STFeedDataSourceWrapper?
    
    fileprivate var favoritesFeedDataSource: STFeedDataSourceWrapper?
    
    fileprivate var searchFeedDataSource: STFeedDataSourceWrapper?
    
    fileprivate var searchFavoriteDataSource: STFeedDataSourceWrapper?
    
    fileprivate var dataSourceSwitch = UISegmentedControl(items: ["feed_page_filter_all_feed_text".localized,
                                                                  "feed_page_filter_favorites_text".localized])
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate var shouldShowSearchResults = false
    
    fileprivate var filter: STFeedFilter?
    
    fileprivate var searchQueryString = ""
    
    fileprivate let disposeBag = DisposeBag()
    
    
    deinit {
        
        disposeBag.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.backgroundView = backgroundView
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 176
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        
        self.tableView.register(nibClass: STPostTableViewCell.self)
        
        self.dataSourceSwitch.tintColor = UIColor.stBrightBlue
        self.dataSourceSwitch.addTarget(self, action: #selector(self.switchDataSource(control:)), for: .valueChanged)
        self.navigationItem.titleView = self.dataSourceSwitch
        
        let rigthItem = UIBarButtonItem(image: UIImage(named: "icon-filter"),
                                        landscapeImagePhone: UIImage(named: "icon-filter"),
                                        style: .plain, target: self, action: #selector(self.openFilter))
        
        self.navigationItem.rightBarButtonItem = rigthItem
        
        self.setCustomBackButton()
        self.setupDataSources()
        
        // refresh control setup
        self.createRefreshControl()
        
        // set data source
        self.tableView.dataSource = self.feedDataSource!.dataSource
        
        // set footer view after data source to prevent unwanted data source calls
        self.tableView.tableFooterView = UIView()
        
        self.tableView.showBusy()
        self.feedDataSource!.loadFeed()
        
        self.dataSourceSwitch.selectedSegmentIndex = 0
        
        self.setupSearchController()
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kPostCreatedNotification),
                                                         object: nil)
            .observeNext { [unowned self] notification in
                
                // temporary
                self.feedDataSource?.loadFeed(isRefresh: true)
                
            }.dispose(in: disposeBag)
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
        
        self.refreshControl = nil
        
        let dataSource = self.dataSourceSwitch.selectedSegmentIndex == 0 ? self.searchFeedDataSource : self.searchFavoriteDataSource
        
        self.tableView.dataSource = dataSource!.dataSource
        self.reloadTableView()
        self.tableView.hideBusy()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.shouldShowSearchResults = false
        
        self.createRefreshControl()
        
        let dataSource = self.dataSourceSwitch.selectedSegmentIndex == 0 ? self.feedDataSource : self.favoritesFeedDataSource
        
        self.tableView.dataSource = dataSource!.dataSource
        self.reloadTableView()
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
        
        self.reloadTableView()
    }
    
    func openFilter() {
        
        let controller = STFeedFilterTableViewController() { [unowned self] in
            
            self.feedDataSource?.reloadFilter(notify: self.dataSourceSwitch.selectedSegmentIndex == 0)
            self.favoritesFeedDataSource?.reloadFilter(notify: self.dataSourceSwitch.selectedSegmentIndex == 1)
            self.reloadTableView()
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
        searchController.searchBar.placeholder = "placeholder_search".localized
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor.stLightBlueGrey
        searchController.searchBar.backgroundImage = UIImage()
        self.definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    private func onDataSourceChanged(animation: Bool) {
        
        self.tableView.hideBusy()
        
        if let refresh = self.refreshControl, refresh.isRefreshing {
            
            DispatchQueue.main.async {
                
                refresh.endRefreshing()
            }
        }
        
        self.reloadTableView(animation: animation)
    }
    
    private func onStartLoading() {
        
        self.tableView.showBusy()
    }
    
    private func onStopLoading() {
        
        self.tableView.hideBusy()
    }
    
    private func createRefreshControl() {
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.reactive.refreshing.observeNext(with: { [unowned self] refreshing in
            
            if !refreshing {
                
                return
            }
            
            let dataSource = self.dataSourceSwitch.selectedSegmentIndex == 0 ?
                self.feedDataSource : self.favoritesFeedDataSource
            
            dataSource?.loadFeed(isRefresh: true)
            
        }).dispose(in: disposeBag)
    }
    
    private func reloadTableView(animation: Bool = false) {
        
        if animation {
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        else {
            
            self.tableView.reloadData()
        }
        
        if self.tableView.numberOfRows(inSection: 0) == 0 {
            
            if self.tableView.dataSource === self.favoritesFeedDataSource!.dataSource
                || self.tableView.dataSource === self.searchFavoriteDataSource!.dataSource {
                
                self.showDummyView(imageName: "empty-feed-favorite",
                                   title: "feed_page_empty_favotites_feed_title".localized,
                                   subTitle: "feed_page_empty_favotites_feed_message".localized)
            }
            else {
                
                self.showDummyView(imageName: "empty-feed",
                                   title: "feed_page_empty_feed_title".localized,
                                   subTitle: "feed_page_empty_feed_message".localized)
            }
        }
        else {
            
            self.hideDummyView()
        }
    }
}
