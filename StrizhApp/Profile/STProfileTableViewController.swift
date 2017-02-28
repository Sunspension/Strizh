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
import Bond
import ReactiveKit

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

    private var bag = DisposeBag()
    
    
    var images = Set<STImage>()
    
    var files = Set<STFile>()
    
    var locations = [STLocation]()
    
    
    deinit {
        
        bag.dispose()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
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
        
        self.setCustomBackButton()
        
        self.dataSource.onDidSelectRowAtIndexPath = { [unowned self] (tableView, indexPath) in
            
            let post = self.dataSource.item(by: indexPath).item as! STPost
            
            if let user = self.user {
                
                let images = self.images.filter { image -> Bool in
                    
                    return post.imageIds.contains(where: { $0.value == image.id })
                }
                
                let files = self.files.filter({ file -> Bool in
                    
                    return post.fileIds.contains(where: { Int64($0.value) == file.id })
                })
                
                let locations = self.locations.filter({ location -> Bool in
                    
                    return post.locationIds.contains(where: { $0.value == location.id })
                })
                
                self.st_router_openPostDetails(personal: true, post: post, user: user, images: images,
                                               files: files, locations: locations)
            }
        }
        
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
                        user.writeToDB()
                        user.updateUserImage()
                        
                        self.createHeader()
                        self.loadFeed()
                    })
            }
        }
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kUserUpdatedNotification),
                                                         object: nil).observeNext { [unowned self] notification in
                                                            
                                                            if let user = STUser.objects(by: STUser.self).first {
                                                                
                                                                self.user = user
                                                                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
                                                            }
            }.dispose(in: bag)
    }
    
    private func createHeader() {
        
        userInfoSection.addItem(cellClass: STProfileHeaderCell.self, item: self.user) { (cell, item) in
            
            if let user = item.item as? STUser {
                
                let viewCell = cell as! STProfileHeaderCell
            
                if viewCell.binded {
                    
                    return
                }
                
                viewCell.selectionStyle = .none
                
                viewCell.userName.text = user.firstName + " " + user.lastName
                viewCell.edit.makeCircular()
                
                viewCell.settings.makeCircular()
                _ = viewCell.settings.reactive.tap.observe { [unowned self] _ in
                    
                    self.st_router_openSettings()
                }
                
                _ = viewCell.edit.reactive.tap.observe { [unowned self] _ in
                    
                    self.st_router_openProfileEditing()
                }
                
                if let imageData = user.imageData {
                    
                    viewCell.userImage.image = UIImage(data: imageData)
                    viewCell.userImage.makeCircular()
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
                                            viewCell.openDialogsTitle.text = post.dialogCount == 1 ? "Открыт:" : "Открыто:"
                                            
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
        
        self.tableView.showBusy()
        
        self.status = .loading
        api.loadPersonalPosts(page: self.page, pageSize: self.pageSize)
            .onSuccess { [unowned self] feed in
                
                self.tableView.hideBusy()
                
                self.hasMore = feed.posts.count == self.pageSize
                self.page += 1
                self.status = .loaded
                self.createDataSource(posts: feed.posts)
                
                feed.images.forEach({ image in
                    
                    self.images.insert(image)
                })
                
                feed.files.forEach({ file in
                    
                    self.files.insert(file)
                })
                
                self.locations.append(contentsOf: feed.locations)
                
                self.tableView.reloadData()
            }
            .onFailure { [unowned self] error in
                
                self.tableView.hideBusy()
                self.status = .failed
        }
    }
}
