//
//  STFeedTableViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 05/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STFeedTableViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!

    private var feedDataSource: STFeedDataSourceWrapper?
    
    private var favoritesFeedDataSource: STFeedDataSourceWrapper?
    
    private var dataSourceSwitch = UISegmentedControl(items: ["Вся Лента", "Избранное"])
    
    private var filter: STFeedFilter?
    
    
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
        
        self.setCustomBackButton()
        
        self.navigationItem.rightBarButtonItem = rigthItem
        
        // setup data sources
        self.feedDataSource = STFeedDataSourceWrapper(onDataSourceChanged: { [unowned self] in
            
            self.tableView.reloadData()
        })
        
        self.feedDataSource!.initialize()
        
        self.favoritesFeedDataSource = STFeedDataSourceWrapper(isFavorite: true, onDataSourceChanged: { [unowned self] in
            
            self.tableView.reloadData()
        })
        
        self.favoritesFeedDataSource?.initialize()
        
        // set data source
        self.tableView.dataSource = self.feedDataSource!.dataSource
        self.feedDataSource!.loadFeed()
        
        self.dataSourceSwitch.selectedSegmentIndex = 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataSource = self.dataSourceSwitch.selectedSegmentIndex == 0 ? self.feedDataSource : self.favoritesFeedDataSource
        let post = dataSource!.dataSource!.item(by: indexPath).item
        
        let images = dataSource!.imagesBy(post: post)
        
        let files = dataSource!.filesBy(post: post)
        
        let locations = dataSource!.locationsBy(post: post)
        
        if let user = dataSource?.userBy(post: post) {
            
            self.st_router_openPostDetails(post: post, user: user, images: images,
                                           files: files, locations: locations)
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
}
