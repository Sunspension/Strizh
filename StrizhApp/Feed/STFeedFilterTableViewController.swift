//
//  STFeedFilterTableViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STFeedFilterTableViewController: UITableViewController {
    
    private enum FilterFields : Int {
        
        case archived, offers, search
    }
    
    fileprivate let dataSource = TableViewDataSource()
    
    fileprivate var filterCallback: (() -> Void)?

    var filter: STBaseFilter?
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }

    init(applyFilterCallback: (() -> Void)?) {
        
        super.init(style: .plain)
        
        self.filterCallback = applyFilterCallback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.allowsMultipleSelection = true
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)
        
        self.tableView.dataSource = self.dataSource
        
        self.tableView.register(nibClass: STFeedFilterTableViewCell.self)
        
        let leftItem = UIBarButtonItem(title: "action_cancel".localized, style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem = UIBarButtonItem(title: "action_apply".localized, style: .plain, target: self, action: #selector(self.applyFilter))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.navigationItem.title = "feed_filter_page_title".localized
        
        let section2 = TableSection()
        self.dataSource.sections.append(section2)
        
        guard let filter = self.filter else {
            
            return
        }
        
        for filter in filter.filterItems {
            
            section2.addItem(cellClass: STFeedFilterTableViewCell.self, item: filter,
                             bindingAction: { [unowned self] (cell, item) in
                                
                                let viewCell = cell as! STFeedFilterTableViewCell
                                let filterItem = item.item as! STFilterItem
                                
                                viewCell.title.text = filterItem.itemName
                                viewCell.icon.image = UIImage(named: filterItem.itemIconName)
                                
                                if filter.isSelected {
                                    
                                    self.tableView.selectRow(at: item.indexPath, animated: false, scrollPosition: .none)
                                }
            })
        }
        
//        section2.addItem(item: cellClass: STFeedFilterTableViewCell.self,
//                         itemType: FilterFields.offers) { [unowned self] (cell, item) in
//                            
//                            let viewCell = cell as! STFeedFilterTableViewCell
//                            
//                            viewCell.title.text = "feed_filter_page_offer_text".localized
//                            viewCell.icon.image = UIImage(named: "icon-offer")
//                            
//                            if self.filter.isOffer {
//                                
//                                self.tableView.selectRow(at: item.indexPath, animated: false, scrollPosition: .none)
//                                item.selected = true
//                            }
//        }
//        
//        section2.addItem(cellClass: STFeedFilterTableViewCell.self,
//                         itemType: FilterFields.search) { [unowned self] (cell, item) in
//                            
//                            let viewCell = cell as! STFeedFilterTableViewCell
//                            
//                            viewCell.title.text = "feed_filter_page_search_text".localized
//                            viewCell.icon.image = UIImage(named: "icon-search")
//                            
//                            if self.filter.isSearch {
//                                
//                                self.tableView.selectRow(at: item.indexPath, animated: false, scrollPosition: .none)
//                                item.selected = true
//                            }
//        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = self.dataSource.item(by: indexPath)
        item.selected = true
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let item = self.dataSource.item(by: indexPath)
        item.selected = false
    }
    
    func cancel() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func applyFilter() {

        guard let filter = self.filter else {
            
            return
        }
        
        filter.writeToDB()
        self.filterCallback?()
        self.cancel()
        
//        let filter = STFeedFilter()
//        
//        self.dataSource.sections.flatMap({ $0.items }).forEach { item in
//            
//            switch item.itemType as! FilterFields {
//                
//            case .archived:
//                
//                filter.showArchived = item.selected
//                
//                break
//                
//            case .offers:
//                
//                filter.offer = item.selected
//                
//                break
//                
//            case .search:
//                
//                filter.search = item.selected
//                
//                break
//            }
//        }
//        
//        filter.writeToDB()
//        
//        self.filterCallback?()
//        self.cancel()
    }
}
