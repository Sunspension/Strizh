//
//  STProfileTableViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 13/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RealmSwift
import AlamofireImage

class STProfileTableViewController: UITableViewController {
    
    private var dataSource: STFeedDataSourceWrapper?
    
    private var user: STUser?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 176
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        
        self.tableView.register(cell: STProfileHeaderCell.self)
        self.tableView.register(cell: STPostTableViewCell.self)
        self.tableView.register(headerFooterCell: STProfilePostHeader.self)
        
        self.setupDataSource()
        
        if let user = STUser.objects(by: STUser.self).first {
            
            self.user = user
            self.createTableViewHeader()
        }
        else {
            
            if let session = STSession.objects(by: STSession.self).first {
                
                api.loadUser(transport: .webSocket, userId: session.userId)
                    .onSuccess(callback: { [unowned self] user in
                        
                        self.user = user
                        user.updateUserImage()
                        
                        self.createTableViewHeader()
                        self.tableView.reloadData()
                    })
            }
        }
    }
    
    private func setupDataSource() {
        
        // setup data sources
        self.dataSource = STFeedDataSourceWrapper(isPersonal: true) { [unowned self] in
            
            self.tableView.reloadData()
        }
        
        self.dataSource!.initialize()
        
        self.tableView.dataSource = self.dataSource!.dataSource
        self.dataSource!.loadFeed()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return tableView.dequeueReusableHeaderFooterView(withIdentifier:
            String(describing: STProfilePostHeader.self))
    }
    
    private func createTableViewHeader() {
        
        if let header = UIView.loadFromNib(view: STProfileHeaderCell.self) {
            
            if let user = self.user {
                
                header.userName.text = user.firstName + " " + user.lastName
                header.edit.makeCircular()
                header.settings.makeCircular()
                
                if let imageData = user.imageData {
                    
                    header.userImage.image = UIImage(data: imageData)
                    header.userImage.makeCircular()
                }
                else {
                    
                    guard !user.imageUrl.isEmpty else {
                        
                        return
                    }
                    
                    let width = Int(header.userImage.bounds.size.width * UIScreen.main.scale)
                    let height = Int(header.userImage.bounds.size.height * UIScreen.main.scale)
                    
                    let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                    
                    let urlString = user.imageUrl + queryResize
                    
                    let filter = RoundedCornersFilter(radius: header.userImage.bounds.size.width)
                    header.userImage.af_setImage(withURL: URL(string: urlString)!, filter: filter)
                }
                
                let height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
                var frame = header.frame
                frame.size.height = height
                header.frame = frame
                
                self.tableView.tableHeaderView = header
            }
        }
    }
}
