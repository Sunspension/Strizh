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
    
    private var dataSource = TableViewDataSource()
    
    private var userInfoSection = CollectionSection()
    
    private var userPostsSection = CollectionSection()
    
    private var user: STUser?
    
    private var status = STLoadingStatusEnum.idle
    
    private var page = 1
    
    private var pageSize = 20
    
    private var hasMore = false
    
    private var canLoadNext: Bool {
        
        return hasMore && status != .loading
    }
    
    
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
        self.tableView.register(cell: STPersonalPostCell.self)
        self.tableView.register(headerFooterCell: STProfileFooterCell.self)
        
        self.dataSource.sections.append(self.userInfoSection)
        self.dataSource.sections.append(self.userPostsSection)
        
        self.tableView.dataSource = dataSource
        self.tableView.delegate = dataSource
        
        if let user = STUser.objects(by: STUser.self).first {
            
            self.user = user
            self.createHeader()
            self.loadFeed()
        }
        else {
            
            if let session = STSession.objects(by: STSession.self).first {
                
                api.loadUser(transport: .webSocket, userId: session.userId)
                    .onSuccess(callback: { [unowned self] user in
                        
                        self.user = user
                        user.updateUserImage()
                        
                        self.createHeader()
                        self.loadFeed()
                    })
            }
        }
    }
    
    private func createHeader() {
        
        userInfoSection.addItem(cellClass: STProfileHeaderCell.self, item: self.user) { (cell, item) in
            
            if let user = item.item as? STUser {
                
                let viewCell = cell as! STProfileHeaderCell
            
                if viewCell.binded {
                    
                    return
                }
                
                viewCell.userName.text = user.firstName + " " + user.lastName
                viewCell.edit.makeCircular()
                viewCell.settings.makeCircular()
                
                if let imageData = user.imageData {
                    
                    DispatchQueue.global().async {
                        
                        DispatchQueue.main.async {
                            
                            viewCell.userImage.image = UIImage(data: imageData)
                            viewCell.userImage.makeCircular()
                        }
                    }
                }
                else {
                    
                    if !user.imageUrl.isEmpty {
                        
                        let width = Int(viewCell.userImage.bounds.size.width * UIScreen.main.scale)
                        let height = Int(viewCell.userImage.bounds.size.height * UIScreen.main.scale)
                        
                        let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                        
                        let urlString = user.imageUrl + queryResize
                        
                        let filter = RoundedCornersFilter(radius: viewCell.userImage.bounds.size.width)
                        viewCell.userImage.af_setImage(withURL: URL(string: urlString)!, filter: filter)
                    }
                }
                
                viewCell.binded = true
            }
        }
        
        userInfoSection.footer(footerClass: STProfileFooterCell.self)
        userInfoSection.footerItem!.cellHeight = 40
    }
    
    private func createDataSource(posts: [STPost]) {
        
        posts.forEach { post in
            
            userPostsSection.addItem(cellClass: STPersonalPostCell.self,
                                     item: post,
                                     bindingAction: { [unowned self] (cell, item) in
                                        
                                        if item.indexPath.row + 10 >
                                            self.userPostsSection.items.count &&
                                            self.canLoadNext {
                                            
                                            self.loadFeed()
                                        }
                                        
                                        let viewCell = cell as! STPersonalPostCell
                                        let post = item.item as! STPost
                                        
                                        viewCell.selectionStyle = .none
                                        viewCell.postTitle.text = post.title
                                        viewCell.postDetails.text = post.postDescription
                                        viewCell.createdAt.text = post.createdAt?.mediumLocalizedFormat
                                        
                                        if post.dialogCount == 0 {
                                            
                                            viewCell.dialogsCount.isHidden = true
                                            viewCell.openDialogsTitle.isHidden = true
                                        }
                                        else {
                                            
                                            viewCell.dialogsCount.isHidden = false
                                            viewCell.openDialogsTitle.isHidden = false
                                            viewCell.openDialogsTitle.text = post.dialogCount == 1 ? "Открыт" : "Открыто"
                                            
                                            let ending = post.dialogCount.ending(yabloko: "диалог", yabloka: "диалога", yablok: "диалогов")
                                            
                                            viewCell.dialogsCount.text = "\(post.dialogCount)" + " " + ending
                                        }
                                        
                                        if post.dateFrom != nil && post.dateTo != nil {
                                            
                                            viewCell.duration.isHidden = false
                                            let period = post.dateFrom!.mediumLocalizedFormat + " - " + post.dateTo!.mediumLocalizedFormat
                                            viewCell.duration.setTitle(period , for: .normal)
                                        }
                                        else {
                                            
                                            viewCell.duration.isHidden = true
                                        }
            })
        }
    }
    
    private func loadFeed() {
        
        self.status = .loading
        api.loadPersonalPosts(page: self.page, pageSize: self.pageSize)
            .onSuccess { [unowned self] feed in
                
                self.hasMore = feed.posts.count == self.pageSize
                self.page += 1
                self.status = .loaded
                self.createDataSource(posts: feed.posts)
                self.tableView.reloadData()
            }
            .onFailure { [unowned self] error in
                
                self.status = .failed
        }
    }
}
