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
    
    fileprivate let section = TableSection()
    
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
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 0)
        
        self.tableView.dataSource = self.dataSource
        
        self.tableView.register(nibClass: STFeedFilterTableViewCell.self)
        
        let leftItem = UIBarButtonItem(title: "action_cancel".localized, style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem = UIBarButtonItem(title: "action_apply".localized, style: .plain, target: self, action: #selector(self.applyFilter))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.navigationItem.title = "feed_filter_page_title".localized
        
        self.dataSource.sections.append(section)
        
        guard let filter = self.filter else {
            
            return
        }
        
        for filter in filter.filterItems {
            
            self.section.addItem(cellClass: STFeedFilterTableViewCell.self, item: filter,
                             bindingAction: { [unowned self] (cell, item) in
                                
                                let viewCell = cell as! STFeedFilterTableViewCell
                                let filterItem = item.item as! STFilterItem
                                
                                viewCell.title.text = filterItem.itemName.localized
                                viewCell.icon.image = UIImage(named: filterItem.itemIconName)
                                
                                if item.selected == nil {
                                    
                                    item.selected = filterItem.isSelected
                                }
                                
                                if item.selected != nil && item.selected! {
                                    
                                    self.tableView.selectRow(at: item.indexPath, animated: false, scrollPosition: .none)
                                }
            })
        }
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

        guard self.filter != nil else {
            
            return
        }
        
        for item in self.section.items {
            
            if item.selected != nil {
                
                let filterItem = item.item as! STFilterItem
                
                STFilterItem.updateObject({
                    
                    filterItem.isSelected = item.selected!
                })
            }
        }
        
        self.filterCallback?()
        self.cancel()
    }
}
