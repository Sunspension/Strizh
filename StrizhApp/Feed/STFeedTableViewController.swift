//
//  STFeedTableViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 05/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import ReactiveKit
import AlamofireImage

enum STFeedControllerOpenReason {
    
    case openFromPush, regular
}

class STFeedTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    
    fileprivate var feedDataSource = STFeedDataSource()
    
    fileprivate var favoritesFeedDataSource = STFeedDataSource(isFavorite: true)
    
    fileprivate var searchFeedDataSource = STFeedDataSource()
    
    fileprivate var searchFavoriteDataSource = STFeedDataSource(isFavorite: true)
    
    fileprivate var dataSourceSwitch = UISegmentedControl(items: ["feed_page_filter_all_feed_text".localized,
                                                                  "feed_page_filter_favorites_text".localized])
    
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate var shouldShowSearchResults = false
    
    fileprivate var filter: STFeedFilter?
    
    fileprivate var searchQueryString = ""
    
    fileprivate let disposeBag = DisposeBag()

    fileprivate var myUser: STUser {
        
        return STUser.objects(by: STUser.self).first!
    }
    
    fileprivate var currentDataSource: STFeedDataSource {
        
        return self.dataSourceSwitch.selectedSegmentIndex == 0 ?
            (self.shouldShowSearchResults ? self.searchFeedDataSource : self.feedDataSource) :
            (self.shouldShowSearchResults ? self.searchFavoriteDataSource : self.favoritesFeedDataSource)
    }
    
    var reason = STDialogsControllerOpenReason.regular
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    deinit {
        
        print("deinit \(String(describing: self))")
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
        
        // set footer view after data source to prevent unwanted data source calls
        self.tableView.tableFooterView = UIView()
        
        self.dataSourceSwitch.selectedSegmentIndex = 0
        
        self.setupSearchController()
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kPostCreatedNotification),
                                                         object: nil)
            .observeNext { [unowned self] notification in
                
                // temporary
                self.feedDataSource.loadFeed(isRefresh: true)
                
            }.dispose(in: disposeBag)
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kUserUpdatedNotification), object: nil)
            .observeNext { [unowned self] notification in
                
                self.tableView.reloadData()
            }
            .dispose(in: disposeBag)
        
        guard self.reason == .regular else {
            
            return
        }
        
        self.feedDataSource.loadFeed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.analytics.logEvent(eventName: st_eFeed, timed: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.analytics.endTimeEvent(eventName: st_eFeed)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.currentDataSource.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataSource = self.currentDataSource
        let post = dataSource.posts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: STPostTableViewCell.self),
                                                 for: indexPath) as! STPostTableViewCell
        
        if indexPath.row + 10 > dataSource.posts.count && dataSource.canLoadNext {
            
            dataSource.loadFeed()
        }
        
        cell.selectionStyle = .none
        cell.postTitle.text = post.title
        cell.postDetails.text = post.postDescription
        cell.iconFavorite.isSelected = post.isFavorite
        cell.postType.isSelected = post.type == 2 ? true : false
        cell.postTime.text = post.createdAt?.elapsedInterval()
        
        cell.onFavoriteButtonTap = { [outerCell = cell] in
            
            let favorite = !outerCell.iconFavorite.isSelected
            outerCell.iconFavorite.isSelected = favorite
            
            self.api.favorite(postId: post.id, favorite: favorite)
                .onSuccess(callback: { postResponse in
                    
                    post.isFavorite = postResponse.isFavorite
                    NotificationCenter.default.post(name: NSNotification.Name(kItemFavoriteNotification), object: postResponse)
                })
        }
        
        if post.dateFrom != nil && post.dateTo != nil {
            
            cell.durationDate.isHidden = false
            let period = post.dateFrom!.shortLocalizedFormat + " - " + post.dateTo!.shortLocalizedFormat
            cell.durationDate.setTitle(period , for: .normal)
        }
        else {
            
            cell.durationDate.isHidden = true
        }
        
        if post.fileIds.count > 0 {
            
            cell.documents.isEnabled = true
            cell.documents.setTitle("\(post.fileIds.count)", for: .normal)
        }
        else {
            
            cell.documents.isEnabled = false
            cell.documents.setTitle("\(0)", for: .normal)
        }
        
        if post.imageIds.count > 0 {
            
            cell.images.isEnabled = true
            cell.images.setTitle("\(post.imageIds.count)", for: .normal)
        }
        else {
            
            cell.images.isEnabled = false
            cell.images.setTitle("\(0)", for: .normal)
        }
        
        if post.locationIds.count > 0 {
            
            cell.locations.isEnabled = true
            cell.locations.setTitle("\(post.locationIds.count)", for: .normal)
        }
        else {
            
            cell.locations.isEnabled = false
            cell.locations.setTitle("\(0)", for: .normal)
        }
        
        if let user = dataSource.users.first(where: { $0.id == post.userId }) {
            
            cell.userName.text = user.lastName + " " + user.firstName
            
            if user.id == self.myUser.id && self.myUser.imageData != nil {
                
                if let image = UIImage(data: self.myUser.imageData!) {
                    
                    let userIcon = image.af_imageAspectScaled(toFill: cell.userIcon.bounds.size)
                    cell.userIcon.image = userIcon.af_imageRoundedIntoCircle()
                }
            }
            else {
                
                if user.imageUrl.isEmpty {
                    
                    var defaultImage = UIImage(named: "avatar")
                    defaultImage = defaultImage?.af_imageAspectScaled(toFill: cell.userIcon.bounds.size)
                    cell.userIcon.image = defaultImage?.af_imageRoundedIntoCircle()
                }
                else {
                    
                    let urlString = user.imageUrl + cell.userIcon.queryResizeString()
                    
                    let filter = RoundedCornersFilter(radius: cell.userIcon.bounds.size.width)
                    cell.userIcon.af_setImage(withURL: URL(string: urlString)!,
                                              filter: filter,
                                              completion: nil)
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let dataSource = currentDataSource
        let post = dataSource.posts[indexPath.row]
        
        let images = dataSource.imagesBy(post: post)
        
        let files = dataSource.filesBy(post: post)
        
        let locations = dataSource.locationsBy(post: post)
        
        if let user = dataSource.userBy(post: post) {
            
            if dataSource.isFavorite {
                
                self.analytics.logEvent(eventName: st_ePostDetails, params: ["post_id" : post.id, "from" : "pFeedFavorite"], timed: true)
            }
            else {
                
                self.analytics.logEvent(eventName: st_ePostDetails, params: ["post_id" : post.id, "from" : st_eFeed], timed: true)
            }
            
            self.st_router_openPostDetails(post: post, user: user, images: images,
                                           files: files, locations: locations)
        }
    }
    
    //MARK: - UISearchBar delegate implementation
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        self.shouldShowSearchResults = true
        
        self.refreshControl = nil
        self.reloadTableView()
        self.tableView.hideBusy()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.shouldShowSearchResults = false
        
        self.createRefreshControl()
        self.reloadTableView()
        self.tableView.hideBusy()
    }
    
    //MARK: - UISearchResultUpdating delegate implementation
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let dataSource = self.dataSourceSwitch.selectedSegmentIndex == 0 ?
            self.searchFeedDataSource : self.searchFavoriteDataSource
        
        if let string = searchController.searchBar.text {
            
            let query = string
            
            let time = DispatchTime.now() + 0.5
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                
                guard searchController.searchBar.text == query, self.searchQueryString != query else {
                    
                    return
                }
                
                dataSource.reset()
                dataSource.loadFeed(searchString: query)
                self.searchQueryString = query
            }
        }
    }

    func openPostDetails(by id: Int) {
        
        self.feedDataSource.reset()
        self.feedDataSource.loadFeed() { [weak self] in
            
            if let index = self?.feedDataSource.posts.index(where: { $0.id == id }) {
                
                let indexPath = IndexPath(row: index, section: 0)
                self?.tableView.selectRow(at: indexPath , animated: false, scrollPosition: .middle)
                self?.tableView.delegate?.tableView!((self?.tableView)!, didSelectRowAt: indexPath)
            }
        }
    }
    
    func switchDataSource(control: UISegmentedControl) {
        
        let feedPost = control.selectedSegmentIndex == 0
        self.analytics.endTimeEvent(eventName: feedPost ? st_eFeedPostTab : st_eFavoritePostTab)
        self.currentDataSource.loadFeedIfNotYet()
        self.reloadTableView()
    }
    
    func openFilter() {
        
        let controller = STFeedFilterTableViewController() { [unowned self] in
            
            // analytics
            if let filter = STFeedFilter.objects(by: STFeedFilter.self).first {
                
                var types = [Int]()
                
                if filter.isOffer {
                    
                    types.append(1)
                }
                else if filter.isSearch {
                    
                    types.append(2)
                }
                else {
                    
                    types.append(contentsOf: [1, 2])
                }
                
                self.analytics.logEvent(eventName: st_eFeedFilter, params: ["type" : types])
            }
            
            self.feedDataSource.reloadFilter(notify: self.dataSourceSwitch.selectedSegmentIndex == 0)
            self.favoritesFeedDataSource.reloadFilter(notify: self.dataSourceSwitch.selectedSegmentIndex == 1)
            self.reloadTableView()
        }
        
        controller.filter = AppDelegate.appSettings.feedFilter
        
        let navi = STNavigationController(rootViewController: controller)
        
        self.present(navi, animated: true, completion: nil)
    }
    
    private func setupDataSources() {
        
        // setup data sources
        self.feedDataSource.onLoadingStatusChanged = self.onDataSourceLoadingStatusChanged(_:)
        self.feedDataSource.onDataSourceChanged = self.onDataSourceChanged
        
        self.searchFeedDataSource.onLoadingStatusChanged = self.onDataSourceLoadingStatusChanged(_:)
        self.searchFeedDataSource.onDataSourceChanged = self.onDataSourceChanged
        self.searchFeedDataSource.disableAddToFavoriteHadler = true
        
        self.favoritesFeedDataSource.onDataSourceChanged = self.onDataSourceChanged
        self.favoritesFeedDataSource.onLoadingStatusChanged = self.onDataSourceLoadingStatusChanged(_:)
        
        self.searchFavoriteDataSource.onLoadingStatusChanged = self.onDataSourceLoadingStatusChanged(_:)
        self.searchFavoriteDataSource.onDataSourceChanged = self.onDataSourceChanged
        self.searchFavoriteDataSource.disableAddToFavoriteHadler = true
    }
    
    fileprivate func onDataSourceLoadingStatusChanged(_ status: STLoadingStatusEnum) {
        
        switch status {
            
        case .loading:
            
            self.tableView.showBusy()
            break
            
        default:
            self.tableView.hideBusy()
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
    
    private func onDataSourceChanged(animation: Bool) {
        
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
            
            dataSource.loadFeed(isRefresh: true)
            
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
            
            if self.currentDataSource === self.favoritesFeedDataSource
                || self.currentDataSource === self.searchFavoriteDataSource {
                
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
