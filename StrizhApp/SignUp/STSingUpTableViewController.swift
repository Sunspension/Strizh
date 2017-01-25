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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "photo"))
        self.tableView.backgroundView!.addSubview(logo)
        
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        
        self.tableView.dataSource = dataSource
        self.tableView.register(nibClass: STLoginTableViewCell.self)
        
        var section = CollectionSection()
        section.addItem(STLoginTableViewCell.self) { (cell, item) in
            
        }
        
        self.dataSource.sections.append(section)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.tableView.contentInset = UIEdgeInsets(top: logo.frame.maxY + 65 , left: 0, bottom: 0, right: 0)
    }
}
