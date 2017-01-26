//
//  STSingUpViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 23/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import SHSPhoneComponent

class STSingUpTableViewController: UITableViewController {
    
    private let dataSource = TableViewDataSource()
    
    private let logo = UIImageView(image: #imageLiteral(resourceName: "logo"))
    
    var contentInset: UIEdgeInsets?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "photo"))
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsSelection = false;
        self.tableView.dataSource = dataSource
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        
        self.setCustomBackButton()
        
        self.tableView.register(nibClass: STLoginTableViewCell.self)
        self.tableView.register(nibClass: STLoginLogoTableViewCell.self)
        
        let rigthItem = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(self.actionNext))
        rigthItem.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = rigthItem
        
        var section = CollectionSection()
        
        section.addItem(nibClass: STLoginLogoTableViewCell.self)
        
        section.addItem(nibClass: STLoginTableViewCell.self) { (cell, item) in
        
            let viewCell = cell as! STLoginTableViewCell
            viewCell.contentView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.2)
            viewCell.title.textColor = UIColor.white
            viewCell.value.textColor = UIColor.white
        }
        
        self.dataSource.sections.append(section)
    }
    
    func actionNext() {
        
        self.view.endEditing(true)
        self.st_Router_SigUpStepTwo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
    }
}
