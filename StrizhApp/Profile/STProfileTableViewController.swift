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
    
    
    fileprivate var dataSource = TableViewDataSource()
    
    fileprivate var userInfoSection = CollectionSection()
    
    fileprivate var userPostsSection = CollectionSection()
    
    fileprivate var user: STUser?
    
    fileprivate var status = STLoadingStatusEnum.idle
    
    fileprivate var minId = 0
    
    fileprivate var pageSize = 20
    
    fileprivate var hasMore = false
    
    fileprivate var canLoadNext: Bool {
        
        return hasMore && status != .loading
    }

    fileprivate var disposeBag = DisposeBag()
    
    
    var images = Set<STImage>()
    
    var files = Set<STFile>()
    
    var locations = [STLocation]()
    
    
    deinit {
        
        disposeBag.dispose()
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
        
        self.tableView.register(nibClass: STProfileHeaderCell.self)
        self.tableView.register(nibClass: STPostTableViewCell.self)
        self.tableView.register(nibClass: STPersonalPostCell.self)
        self.tableView.register(headerFooterNibClass: STProfileFooterCell.self)
        
        self.dataSource.sections.append(self.userInfoSection)
        self.dataSource.sections.append(self.userPostsSection)
        
        self.tableView.dataSource = dataSource
        self.tableView.delegate = dataSource
        
        self.setCustomBackButton()
        
        self.dataSource.onDidSelectRowAtIndexPath = { [unowned self] (tableView, indexPath, item) in
            
            // trying to avoid to tap on the info section
            if indexPath.section == 0 {
                
                return
            }
            
            let post = item.item as! STPost
            
            if let user = self.user {
                
                let images = self.images.filter { image -> Bool in
                    
                    return post.imageIds.contains(where: { $0.value == image.id })
                }
                
                let files = self.files.filter({ file -> Bool in
                    
                    return post.fileIds.contains(where: { $0.value == file.id })
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
            }.dispose(in: disposeBag)
        
//        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kPostAddedToArchiveNotification),
//                                                         object: nil).observeNext { [unowned self] notification in
//                                                            
//                                                            let post = notification.object as! STPost
//                                                            
//                                                            for item in self.userPostsSection.items {
//                                                                
//                                                                let p =  item.item as! STPost
//                                                                
//                                                                if p.id == post.id {
//                                                                    
//                                                                    p.isArchived = true
//                                                                    self.tableView.reloadRows(at: [item.indexPath], with: .none)
//                                                                    break
//                                                                }
//                                                            }
//            }.dispose(in: bag)
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kPostDeleteFromDetailsNotification),
                                                         object: nil).observeNext { [unowned self] notification in
                                                            
                                                            let post = notification.object as! STPost
                                                            
                                                            self.userPostsSection.items = self.userPostsSection.items
                                                                .filter({ ($0.item! as! STPost).id != post.id })
                                                            
                                                            // save last item id for loading next objects
                                                            if let lastPost = self.userPostsSection.items.last {
                                                                
                                                                self.minId = (lastPost.item as! STPost).id
                                                            }
                                                            else {
                                                                
                                                                self.minId = 0
                                                            }
                                                            
                                                            self.tableView.reloadSections(IndexSet(integer: 1) , with: .none)
            }.dispose(in: disposeBag)
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kPostCreatedNotification),
                                                         object: nil)
            .observeNext { [unowned self] notification in
                
                // temporary
                self.minId = 0
                self.loadFeed(isRefresh: true)
                
            }.dispose(in: disposeBag)
        
        
        // refresh control setup
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.reactive.refreshing.observeNext(with: { refreshing in
            
            if !refreshing {
                
                return
            }
            
            // temporary
            self.minId = 0
            self.loadFeed(isRefresh: true)
            
        }).dispose(in: disposeBag)
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
//                                        viewCell.isArchived.isHidden = !post.isArchived
                                        
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
                                        
                                        if post.fileIds.count > 0 {
                                            
                                            viewCell.documents.isEnabled = true
                                            viewCell.documents.setTitle("\(post.fileIds.count)", for: .normal)
                                        }
                                        else {
                                            
                                            viewCell.documents.isEnabled = false
                                            viewCell.documents.setTitle("\(0)", for: .normal)
                                        }
                                        
                                        if post.imageIds.count > 0 {
                                            
                                            viewCell.images.isEnabled = true
                                            viewCell.images.setTitle("\(post.imageIds.count)", for: .normal)
                                        }
                                        else {
                                            
                                            viewCell.images.isEnabled = false
                                            viewCell.images.setTitle("\(0)", for: .normal)
                                        }
                                        
                                        if post.locationIds.count > 0 {
                                            
                                            viewCell.locations.isEnabled = true
                                            viewCell.locations.setTitle("\(post.locationIds.count)", for: .normal)
                                        }
                                        else {
                                            
                                            viewCell.locations.isEnabled = false
                                            viewCell.locations.setTitle("\(0)", for: .normal)
                                        }
                                        
                                        viewCell.more.reactive.tap.observe { _ in
                                            
                                            let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                                            
                                            let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
                                            
                                            let actionEdit = UIAlertAction(title: "Редактировать", style: .default, handler: { action in
                                                
                                                // open edit controller
                                                let postObject = STUserPostObject(post: post)
                                                postObject.images = self.images
                                                
                                                self.st_router_openPostController(postObject: postObject)
                                            })
                                            
                                            actionController.addAction(actionEdit)

                                            
//                                            if !post.isArchived {
//                                                
//                                                let actionArchive = UIAlertAction(title: "В архив", style: .default,
//                                                                                  handler: { [unowned self, unowned viewCell] action in
//                                                    
//                                                    self.api.archivePost(postId: post.id, isArchived: true)
//                                                        .onSuccess(callback: { _ in
//                                                            
//                                                            post.isArchived = true
//                                                            viewCell.isArchived.isHidden = false
//                                                        })
//                                                        .onFailure(callback: { error in
//                                                            
//                                                            self.showError(error: error)
//                                                        })
//                                                })
//                                                
//                                                actionController.addAction(actionArchive)
//                                            }
                                            
                                            let actionDelete = UIAlertAction(title: "Удалить", style: .default, handler: { action in
                                                
                                                self.api.deletePost(postId: post.id)
                                                    .onSuccess(callback: { [unowned self] _ in
                                                        
                                                        self.userPostsSection.items = self.userPostsSection.items
                                                                .filter({ ($0.item! as! STPost).id != (item.item! as! STPost).id })
                                                        
                                                        NotificationCenter.default.post(name: NSNotification.Name(kPostDeleteNotification), object: post)
                                                        
                                                        // save last item id for loading next objects
                                                        if let lastPost = self.userPostsSection.items.last {
                                                            
                                                            self.minId = (lastPost.item as! STPost).id
                                                        }
                                                        else {
                                                            
                                                            self.minId = 0
                                                        }
                                                        
                                                        self.tableView.reloadSections(IndexSet(integer: item.indexPath.section) , with: .automatic)
                                                    })
                                                    .onFailure(callback: { error in
                                                        
                                                        self.showError(error: error)
                                                    })
                                            })
                                            
                                            actionController.addAction(cancel)
                                            actionController.addAction(actionDelete)
                                            
                                            self.present(actionController, animated: true, completion: nil)
                                            
                                        }.dispose(in: viewCell.bag)
            })
        }
    }
    
    private func loadFeed(isRefresh: Bool = false) {
        
        self.tableView.showBusy()
        
        self.status = .loading
        api.loadPersonalPosts(minId: self.minId, pageSize: self.pageSize)
            .onSuccess { [unowned self] feed in
                
                self.tableView.hideBusy()
                
                if let refresh = self.refreshControl, refresh.isRefreshing {
                    
                    DispatchQueue.main.async {
                        
                        refresh.endRefreshing()
                    }
                }
                
                self.hasMore = feed.posts.count == self.pageSize
                
                if let lastPost = feed.posts.last {
                    
                    self.minId = lastPost.id
                }
                
                self.status = .loaded
                
                if isRefresh {
                    
                    self.userPostsSection.items.removeAll()
                }
                
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
