//
//  STFeedFilterTableViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import EmitterKit

private enum FilterFields : Int {
    
    case archived, offers, search
}


class STFeedFilterTableViewController: UITableViewController {
    
    
    private let dataSource = TableViewDataSource()
    
    private var filter = STFeedFilter()
    
    private var filterCallback: (() -> Void)?
    
    private var toggleListener: EventListener<Bool>?
    
    private var toggleEmitter = Event<Bool>()
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }

    init(applyFilterCallback: (() -> Void)?) {
        
        super.init(style: .grouped)
        
        self.filter = AppDelegate.appSettings.feedFilter
        self.filterCallback = applyFilterCallback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.allowsMultipleSelection = true
        
        self.tableView.dataSource = self.dataSource
        
        self.tableView.register(nibClass: STFeedFilterTableViewCell.self)
        self.tableView.register(nibClass: STFeedFilterSwitchTableViewCell.self)
        
        let leftItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem = UIBarButtonItem(title: "Применить", style: .plain, target: self, action: #selector(self.applyFilter))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.navigationItem.title = "Фильтр"
        
        let section1 = CollectionSection()
        self.dataSource.sections.append(section1)
        
        section1.addItem(cellClass: STFeedFilterSwitchTableViewCell.self,
                         itemType: FilterFields.archived) { [unowned self] (cell, item) in
                            
                            let viewCell = cell as! STFeedFilterSwitchTableViewCell
                            
                            viewCell.toggle.addTarget(self, action: #selector(self.toggleAction(sender:)), for: .valueChanged)
                            
                            self.toggleListener = self.toggleEmitter.on({ isOn in
                                
                                item.selected = isOn
                            })
                            
                            if self.filter.showArchived {
                                
                                viewCell.toggle.setOn(true, animated: false)
                                item.selected = true
                            }
        }
        
        let section2 = CollectionSection()
        self.dataSource.sections.append(section2)
        
        section2.addItem(cellClass: STFeedFilterTableViewCell.self,
                         itemType: FilterFields.offers) { [unowned self] (cell, item) in
                            
                            let viewCell = cell as! STFeedFilterTableViewCell
                            
                            viewCell.title.text = "Предложения"
                            viewCell.icon.image = UIImage(named: "icon-offer")
                            
                            if self.filter.offer {
                                
                                self.tableView.selectRow(at: item.indexPath, animated: false, scrollPosition: .none)
                                item.selected = true
                            }
        }
        
        section2.addItem(cellClass: STFeedFilterTableViewCell.self,
                         itemType: FilterFields.search) { [unowned self] (cell, item) in
                            
                            let viewCell = cell as! STFeedFilterTableViewCell
                            
                            viewCell.title.text = "Запросы/Поиск"
                            viewCell.icon.image = UIImage(named: "icon-search")
                            
                            if self.filter.search {
                                
                                self.tableView.selectRow(at: item.indexPath, animated: false, scrollPosition: .none)
                                item.selected = true
                            }
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
        
        let filter = STFeedFilter()
        
        self.dataSource.sections.flatMap({ $0.items }).forEach { item in
            
            switch item.itemType as! FilterFields {
                
            case .archived:
                
                filter.showArchived = item.selected
                
                break
                
            case .offers:
                
                filter.offer = item.selected
                
                break
                
            case .search:
                
                filter.search = item.selected
                
                break
            }
        }
        
        filter.writeToDB()
        
        self.filterCallback?()
        self.dismiss(animated: true, completion: nil)
    }
    
    func toggleAction(sender: UISwitch) {
        
        self.toggleEmitter.emit(sender.isOn)
    }
}
