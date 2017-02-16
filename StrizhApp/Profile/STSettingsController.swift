//
//  STSettingsController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 15/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STSettingsController: UITableViewController {

    private let dataSource = TableViewDataSource()
    
    private let section1 = CollectionSection(title: "УВЕДОМЛЕНИЯ")
    
    private let section2 = CollectionSection()
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    init() {
        
        super.init(style: .grouped)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        self.dataSource.sections.append(self.section1)
        self.dataSource.sections.append(self.section2)
        
        self.tableView.dataSource = self.dataSource
        
        self.tableView.register(cell: STFeedFilterSwitchTableViewCell.self)
        
        self.title = "Настройки"
        
        let rigthItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(self.close))
        
        let leftItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(self.close))
        
        self.navigationItem.rightBarButtonItem = rigthItem
        self.navigationItem.leftBarButtonItem = leftItem
        
        self.createDataSource()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section != 1 {
            
            return
        }
        
        self.st_router_logout()
    }
    
    func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func createDataSource() {
        
        self.section1.addItem(cellClass: STFeedFilterSwitchTableViewCell.self) { (cell, item) in
            
            let viewCell = cell as! STFeedFilterSwitchTableViewCell
            viewCell.title.text = "Темы"
            viewCell.toggle.isOn = true
        }
        
        self.section1.addItem(cellClass: STFeedFilterSwitchTableViewCell.self) { (cell, item) in
            
            let viewCell = cell as! STFeedFilterSwitchTableViewCell
            viewCell.title.text = "Сообщения"
            viewCell.toggle.isOn = true
        }
        
        self.section2.addItem(cellStyle: .default) { (cell, item) in
            
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.stBrick
            cell.textLabel?.text = "Выйти из аккаунта"
        }
    }
}
