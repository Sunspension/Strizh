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
    
    private var userInfoSection = TableSection()
    
    private var userPostsSection = TableSection()
    
    private var user: STUser {
        
        return STUser.dbFind(by: STUser.self)!
    }
    
    private var status = STLoadingStatusEnum.idle
    
    private var minId = 0
    
    private var pageSize = 20
    
    private var hasMore = false
    
    private var canLoadNext: Bool {
        
        return hasMore && status != .loading
    }
    
    private var disposeBag = DisposeBag()
    
    var images = Set<STImage>()
    
    var files = Set<STFile>()
    
    var locations = [STLocation]()
    
    var userImage: UIImage?
    
    deinit {
        
        print("deinit \(String(describing: self))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.analytics.logEvent(eventName: st_eMyProfile, timed: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.analytics.endTimeEvent(eventName: st_eMyProfile)
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
        
        if let data = self.user.imageData {
            
            self.userImage = UIImage(data: data)
        }
        
        self.dataSource.onDidSelectRowAtIndexPath = { [unowned self] (tableView, indexPath, item) in
            
            // trying to avoid to tap on the info section
            if indexPath.section == 0 {
                
                return
            }
            
            let post = item.item as! STPost
            
            let images = self.images.filter { image -> Bool in
                
                return post.imageIds.contains(where: { $0.value == image.id })
            }
            
            let files = self.files.filter({ file -> Bool in
                
                return post.fileIds.contains(where: { $0.value == file.id })
            })
            
            let locations = self.locations.filter({ location -> Bool in
                
                return post.locationIds.contains(where: { $0.value == location.id })
            })
            
            self.analytics.logEvent(eventName: st_ePostDetails,
                                    params: ["post_id" : post.id, "from=" : st_eMyProfile])
            
            self.st_router_openPostDetails(post: post, user: self.user, images: images,
                                           files: files, locations: locations)
        }
        
        self.createHeader()
        self.loadFeed()
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kPostDeleteNotification), object: nil)
            .observeNext { [unowned self] notification in
                
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
                
                self.tableView.reloadSections(IndexSet(integer: 1) , with: .automatic)
                self.showDummyViewIfNeeded()
            }
            .dispose(in: disposeBag)

        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kUserUpdatedNotification), object: nil)
            .observeNext { [unowned self] notification in
                
                if let data = self.user.imageData {
                    
                    self.userImage = UIImage(data: data)
                }
                
                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
            .dispose(in: disposeBag)
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kPostCreatedNotification), object: nil)
            .observeNext { [unowned self] notification in
                
                self.analytics.logEvent(eventName: st_ePostRefresh)
                
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
        
        userInfoSection.add(cellClass: STProfileHeaderCell.self) { (cell, item) in
            
            let viewCell = cell as! STProfileHeaderCell
            viewCell.selectionStyle = .none
            
            viewCell.userName.text = self.user.firstName + " " + self.user.lastName
            viewCell.edit.makeCircular()
            
            viewCell.settings.makeCircular()
            _ = viewCell.settings.reactive.tap.observe { [unowned self] _ in
                
                self.st_router_openSettings()
            }
            
            _ = viewCell.edit.reactive.tap.observe { [unowned self] _ in
                
                self.st_router_openProfileEditing()
            }
            
            if let imageData = self.user.imageData {
                
                var image = UIImage(data: imageData)!
                image = image.af_imageAspectScaled(toFill: viewCell.userImage.bounds.size)
                viewCell.setImageWithTransition(image: image.af_imageRoundedIntoCircle())
            }
            else {
                
                if !self.user.imageUrl.isEmpty {
                    
                    let urlString = self.user.imageUrl + viewCell.userImage.queryResizeString()
                    let filter = RoundedCornersFilter(radius: viewCell.userImage.bounds.width)
                    
                    viewCell.userImage.af_setImage(withURL: URL(string: urlString)!, filter: filter, imageTransition: .crossDissolve(0.3))
                }
                else {
                    
                    var defaultImage = UIImage(named: "avatar")
                    defaultImage = defaultImage?.af_imageAspectScaled(toFill: viewCell.userImage.bounds.size)
                    viewCell.setImageWithTransition(image: defaultImage?.af_imageRoundedIntoCircle())
                }
            }
        }
        
        userInfoSection.footer(footerClass: STProfileFooterCell.self) { (view, item) in
            
            let footer = view as! STProfileFooterCell
            footer.label.text = "profile_page_my_topics".localized
        }
        
        userInfoSection.footerItem!.cellHeight = 40
    }
    
    private func createDataSource(posts: [STPost]) {
        
        for post in posts {
            
            userPostsSection.add(item: post,
                                 cellClass: STPersonalPostCell.self,
                                 bindingAction: { [unowned self] (cell, item) in
                                    
                                    if item.indexPath.row + 10 >
                                        self.userPostsSection.items.count &&
                                        self.canLoadNext {
                                        
                                        self.loadFeed()
                                    }
                                    
                                    let viewCell = cell as! STPersonalPostCell
                                    let post = item.item as! STPost
                                    
                                    self.configureCell(post, viewCell)
            })
        }
    }
    
    private func configureCell(_ post: STPost, _ viewCell: STPersonalPostCell) {
        
        viewCell.selectionStyle = .none
        viewCell.postTitle.text = post.title
        viewCell.postDetails.text = post.postDescription
        viewCell.createdAt.text = post.createdAt?.mediumLocalizedFormat
        viewCell.iconFavorite.isSelected = post.isFavorite
        
        viewCell.userName.text = self.user.lastName + " " + self.user.firstName
        
        let end = post.dialogCount.ending(yabloko: "отклик", yabloka: "отлика", yablok: "откликов")
        let title = "\(post.dialogCount)" + " " + end
        
        viewCell.dialogsCount.setTitle( title, for: .normal)
        
        viewCell.onFavoriteButtonTap = { [viewCell, unowned self] in
            
            let favorite = !viewCell.iconFavorite.isSelected
            viewCell.iconFavorite.isSelected = favorite
            
            self.api.favorite(postId: post.id, favorite: favorite)
                .onSuccess(callback: { [post] postResponse in
                    
                    post.isFavorite = postResponse.isFavorite
                    NotificationCenter.default.post(name: NSNotification.Name(kItemFavoriteNotification), object: postResponse)
                })
        }
        
        if post.dateFrom != nil && post.dateTo != nil {
            
            viewCell.duration.isHidden = false
            let period = post.dateFrom!.mediumLocalizedFormat + " - " + post.dateTo!.mediumLocalizedFormat
            viewCell.duration.setTitle(period , for: .normal)
        }
        else {
            
            viewCell.duration.isHidden = true
        }
        
        viewCell.more.reactive.tap.observeNext { [unowned self] in
            
            self.showActionController(post)
            
        }.dispose(in: viewCell.disposeBag)
        
        if user.id == user.id && self.userImage != nil {
            
            let userIcon = self.userImage!.af_imageAspectScaled(toFill: viewCell.userIcon.bounds.size)
            viewCell.userIcon.setImage(userIcon.af_imageRoundedIntoCircle(), for: .normal)
        }
        else {
            
            if user.imageUrl.isEmpty {
                
                var defaultImage = UIImage(named: "avatar")
                defaultImage = defaultImage?.af_imageAspectScaled(toFill: viewCell.userIcon.bounds.size)
                viewCell.userIcon.setImage(defaultImage?.af_imageRoundedIntoCircle(), for: .normal)
            }
            else {
                
                let urlString = user.imageUrl + viewCell.userIcon.queryResizeString()
                let filter = RoundedCornersFilter(radius: viewCell.userIcon.bounds.size.width)
                viewCell.userIcon.af_setImage(for: .normal, url: URL(string: urlString)!, filter: filter)
            }
        }
    }
    
    private func showActionController(_ post: STPost) {
        
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction.cancel
        
        let actionEdit = UIAlertAction.defaultAction(title: "action_edit".localized) { action in
            
            // open edit controller
            let postObject = STUserPostObject(post: post)
            postObject.images = self.images
            
            self.analytics.logEvent(eventName: st_ePostEdit,
                                    params: ["post_id" : post.id])
            
            self.st_router_openPostController(postObject: postObject)
        }
        
        actionController.addAction(actionEdit)
        
        let actionDelete = UIAlertAction.destructiveAction(title: "action_delete".localized) { action in
            
            self.api.deletePost(postId: post.id)
                .onSuccess(callback: { [unowned self] _ in
                    
                    self.analytics.logEvent(eventName: st_ePostDelete, params: ["post_id" : post.id])
                    
                    self.userPostsSection.items = self.userPostsSection.items
                        .filter({ ($0.item! as! STPost).id != post.id })
                    
                    NotificationCenter.default.post(name: NSNotification.Name(kPostDeleteNotification), object: post)
                    
                    // save last item id for loading next objects
                    if let lastPost = self.userPostsSection.items.last {
                        
                        self.minId = (lastPost.item as! STPost).id
                    }
                    else {
                        
                        self.minId = 0
                    }
                    
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                    self.showDummyViewIfNeeded()
                })
                .onFailure(callback: { [unowned self] error in
                    
                    self.showError(error: error)
                })
        }
        
        actionController.addAction(cancel)
        actionController.addAction(actionDelete)
        
        self.present(actionController, animated: true, completion: nil)
    }
    
    private func loadFeed(isRefresh: Bool = false) {
        
        self.tableView.showBusy()
        
        self.status = .loading
        
        self.analytics.logEvent(eventName: st_ePostScroll)
        
        api.loadPersonalPosts(minId: self.minId, pageSize: self.pageSize)
            .onSuccess { [unowned self] feed in
                
                self.tableView.hideBusy()
                
                if let refresh = self.refreshControl, refresh.isRefreshing {
                    
                    refresh.endRefreshing()
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
                self.showDummyViewIfNeeded()
                
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
    
    private func showDummyViewIfNeeded() {
        
        if self.userPostsSection.items.count == 0 {
            
            self.showDummyView(imageName: "empty-personal-feed",
                               title: "profile_page_empty_personal_posts_title".localized,
                               subTitle: "profile_page_empty_personal_posts_message".localized)
        }
        else {
            
            self.hideDummyView()
        }
    }
}
