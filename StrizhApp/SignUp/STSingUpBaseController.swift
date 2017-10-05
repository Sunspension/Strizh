//
//  STSingUpBaseController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 9/23/17.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class STSingUpBaseController: UITableViewController, NVActivityIndicatorViewable {
    
    private let logo = UIImageView(image: #imageLiteral(resourceName: "logo-login"))
    
    private var contentInset: UIEdgeInsets?
    
    private lazy var rightNavigationItem: UIBarButtonItem = {
        
        let rigthItem = UIBarButtonItem(title: self.rightNavigationItemText(), style: .plain, target: self, action: #selector(self.actionNext))
        rigthItem.tintColor = UIColor.white
        rigthItem.isEnabled = false
        
        return rigthItem
    }()
    
    private lazy var tapRecognaizer: UITapGestureRecognizer = {
        
        let tapRecognaizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler))
        tapRecognaizer.numberOfTapsRequired = 1
        tapRecognaizer.numberOfTouchesRequired = 1
        
        return tapRecognaizer
    }()
    
    let dataSource = TableViewDataSource()
    
    
    func rightNavigationItemText() -> String {
        
        return "action_next".localized
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = dataSource
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        
        self.navigationItem.rightBarButtonItem = rightNavigationItem
        self.view.addGestureRecognizer(tapRecognaizer)
        
        self.setCustomBackButton()
        
        let section = self.createDataSection()
        self.dataSource.sections.append(section)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        var naviHeight = UIApplication.shared.statusBarFrame.height
        
        if let barHeight = self.navigationController?.navigationBar.frame.size.height {
            
            naviHeight += barHeight
        }
        
        let offset = (self.tableView.frame.height - (self.tableView.contentSize.height + naviHeight)) / 2
        
        guard offset > 64 else {
            
            return
        }
        
        self.tableView.contentInset = UIEdgeInsets(top: offset, left: 0, bottom: 0, right: 0)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
    }
    
    @objc func actionNext() {
        
        self.view.endEditing(true)
    }
    
    func createDataSection() -> TableSection {
        
        fatalError("You have to override this method")
    }
    
    @objc private func tapGestureHandler(tapRecognizer: UITapGestureRecognizer) {
        
        if tapRecognizer.state != .recognized {
            
            return
        }
        
        self.view.endEditing(true)
    }
}
