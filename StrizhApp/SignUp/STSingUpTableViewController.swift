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
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsSelection = false;
        self.tableView.dataSource = dataSource
        self.tableView.bounces = false
        
        self.tableView.register(nibClass: STLoginTableViewCell.self)
        self.tableView.register(nibClass: STLoginLogoTableViewCell.self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardNotificationListener.keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardNotificationListener.keyboardWillHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        let rigthItem = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(self.actionNext))
        rigthItem.tintColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = rigthItem
        
        var section = CollectionSection()
        
        section.addItem(STLoginLogoTableViewCell.self) { (cell, item) in
            
            
        }
        
        section.addItem(STLoginTableViewCell.self) { (cell, item) in
        
            let viewCell = cell as! STLoginTableViewCell
            viewCell.contentView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.2)
            viewCell.title.textColor = UIColor.white
            viewCell.value.textColor = UIColor.white
            viewCell.value.becomeFirstResponder()
        }
        
        section.addItem(STLoginTableViewCell.self) { (cell, item) in
            
            let viewCell = cell as! STLoginTableViewCell
            viewCell.contentView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.2)
            viewCell.title.textColor = UIColor.white
            viewCell.value.textColor = UIColor.white
        }
        
        section.addItem(STLoginLogoTableViewCell.self) { (cell, item) in
            
            
        }
        
        self.dataSource.sections.append(section)
    }
    
    func actionNext() {
        
        
    }
    
    

    func keyboardWillShow(_ notification: Notification) {
        
        let lastRow = self.tableView.numberOfRows(inSection: 0) - 1
        let indexPath = IndexPath(row: lastRow, section: 0);
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        
//        let lastRow: Int = self.tableView.numberOfRows(inSection: 0) - 1
//        let indexPath = IndexPath(row: lastRow, section: 0);
//        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {
//
//            
//        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
//        self.tableView?.contentInset = self.contentInset ?? UIEdgeInsets.zero
//        self.tableView?.scrollIndicatorInsets = self.contentInset ?? UIEdgeInsets.zero
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)

        
    }
}
