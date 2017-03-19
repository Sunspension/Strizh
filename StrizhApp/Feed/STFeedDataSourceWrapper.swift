//
//  STFeedDataSource.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 07/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import BrightFutures
import AlamofireImage
import ReactiveKit

class STFeedDataSourceWrapper {
    
    
    private var status = STLoadingStatusEnum.idle
    
    private var page = 1
    
    private var searchPage = 1
    
    private var pageSize: Int
    
    private let section = GenericCollectionSection<STPost>()
    
    private var filter: STFeedFilter?
    
    private var hasMore = false
    
    private var onDataSourceChanged:((_ animation: Bool) -> Void)?
    
    private var isFavorite: Bool

    private var isPersonal: Bool
    
    private var canLoadNext: Bool {
        
        return hasMore && status != .loading
    }
    
    var dataSource: GenericTableViewDataSource<STPostTableViewCell, STPost>?
    
    var users = Set<STUser>()
    
    var locations = [STLocation]()
    
    var images = Set<STImage>()
    
    var files = Set<STFile>()
    
    var posts = [STPost]()
    
    var onStartLoading:(() -> Void)?
    
    var onStopLoading:(() -> Void)?
    
    var bag = DisposeBag()
    
    
    deinit {
        
        bag.dispose()
    }
    
    
    init(pageSize: Int = 20, isFavorite: Bool = false,
         isPersonal: Bool = false, onDataSourceChanged:((_ animation: Bool) -> Void)? = nil) {
        
        self.pageSize = pageSize
        self.isFavorite = isFavorite
        self.isPersonal = isPersonal
        self.onDataSourceChanged = onDataSourceChanged
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kItemFavoriteNotification), object: nil)
            .observeNext { [unowned self] notification in
            
            let post = notification.object as! STPost
            
            if self.isFavorite {
                
                if post.isFavorite {
                    
                    self.section.insert(at: 0, item: post)
                }
                else {
                    
                    self.section.items = self.section.items.filter({ $0.item.id != post.id })
                }
                
                self.onDataSourceChanged?(false)
            }
            else {
                
                if let item = self.section.items.filter({ $0.item.id == post.id }).first {
                    
                    item.item.isFavorite = post.isFavorite
                    self.onDataSourceChanged?(false)
                }
            }
            
        }.dispose(in: self.bag)
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kPostDeleteFromDetailsNotification),
                                                         object: nil)
            .observeNext { [unowned self] notification in
                
                let post = notification.object as! STPost
                
                let count = self.section.items.count
                
                self.section.items = self.section.items
                    .filter({ $0.item.id != post.id })
                
                if count != self.section.items.count {
                    
                    self.onDataSourceChanged?(false)
                }
                
            }.dispose(in: bag)
        
        NotificationCenter.default.reactive.notification(name: NSNotification.Name(kPostDeleteNotification),
                                                         object: nil)
            .observeNext { [unowned self] notification in
                
                let post = notification.object as! STPost
                
                let count = self.section.items.count
                
                self.section.items = self.section.items
                    .filter({ $0.item.id != post.id })
                
                if count != self.section.items.count {
                    
                    self.onDataSourceChanged?(false)
                }
                
            }.dispose(in: bag)
    }
    
    func initialize() {
        
        self.dataSource = GenericTableViewDataSource(cellClass: STPostTableViewCell.self) { [unowned self] (cell, item) in
            
            if item.indexPath.row + 10 > self.section.items.count && self.canLoadNext {
                
                self.loadFeed()
            }
            
            let post = item.item
            
            cell.selectionStyle = .none
            cell.postTitle.text = post.title
            cell.postDetails.text = post.postDescription
            cell.iconFavorite.isSelected = post.isFavorite
            cell.postType.isSelected = post.type == 2 ? true : false
            cell.postTime.text = post.createdAt?.elapsedInterval()
            
            cell.iconFavorite.reactive.tap.observe {_ in
                
                let favorite = !cell.iconFavorite.isSelected
                cell.iconFavorite.isSelected = favorite
                
                AppDelegate.appSettings.api.favorite(postId: post.id, favorite: favorite)
                    .onSuccess(callback: { postResponse in
                        
                        post.isFavorite = postResponse.isFavorite
                        
                        NotificationCenter.default.post(name: NSNotification.Name(kItemFavoriteNotification), object: postResponse)
                    })
                
            }.dispose(in: cell.bag)
            
            if post.dateFrom != nil && post.dateTo != nil {
                
                cell.durationDate.isHidden = false
                let period = post.dateFrom!.shortLocalizedFormat + " - " + post.dateTo!.shortLocalizedFormat
                cell.durationDate.setTitle(period , for: .normal)
            }
            else {
                
                cell.durationDate.isHidden = true
            }
            
            if post.fileIds.count > 0 {
                
                cell.documents.isEnabled = true
                cell.documents.setTitle("\(post.fileIds.count)", for: .normal)
            }
            else {
                
                cell.documents.isEnabled = false
                cell.documents.setTitle("\(0)", for: .normal)
            }
            
            if post.imageIds.count > 0 {
                
                cell.images.isEnabled = true
                cell.images.setTitle("\(post.imageIds.count)", for: .normal)
            }
            else {
                
                cell.images.isEnabled = false
                cell.images.setTitle("\(0)", for: .normal)
            }
            
            if post.locationIds.count > 0 {
                
                cell.locations.isEnabled = true
                cell.locations.setTitle("\(post.locationIds.count)", for: .normal)
            }
            else {
                
                cell.locations.isEnabled = false
                cell.locations.setTitle("\(0)", for: .normal)
            }
            
            if let user = self.users.first(where: { $0.id == post.userId }) {
                
                cell.userName.text = user.lastName + " " + user.firstName
                
                guard !user.imageUrl.isEmpty else {
                    
                    return
                }
                
                let width = Int(cell.userIcon.bounds.size.width * UIScreen.main.scale)
                let height = Int(cell.userIcon.bounds.size.height * UIScreen.main.scale)
                
                let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                
                let urlString = user.imageUrl + queryResize
                
                let filter = RoundedCornersFilter(radius: cell.userIcon.bounds.size.width)
                cell.userIcon.af_setImage(withURL: URL(string: urlString)!,
                                          filter: filter,
                                          completion: nil)
            }
        }
        
        self.dataSource!.sections.append(self.section)
        
        self.filter = AppDelegate.appSettings.feedFilter
    }
    
    func userBy(post: STPost) -> STUser? {
        
        return self.users.first(where: { $0.id == post.userId })
    }
    
    func imagesBy(post: STPost) -> [STImage]? {
        
        return self.images.filter { image -> Bool in
            
            return post.imageIds.contains(where: { $0.value == image.id })
        }
    }
    
    func locationsBy(post: STPost) -> [STLocation]? {
        
        return self.locations.filter({ location -> Bool in
            
            return post.locationIds.contains(where: { $0.value == location.id })
        })
    }
    
    func filesBy(post: STPost) -> [STFile]? {
        
        return self.files.filter({ file -> Bool in
            
            return post.fileIds.contains(where: { $0.value == file.id })
        })
    }
    
    func loadFeedIfNotYet() {
        
        if self.section.items.count == 0 && self.status == .idle {
            
            loadFeed()
        }
    }
    
    func reloadFilter(notify: Bool) {
        
        self.filter = AppDelegate.appSettings.feedFilter
        self.section.items.removeAll()
        self.page = 1
        self.loadFeed(notify: notify)
    }
    
    func reset() {
        
        self.page = 1
        self.posts.removeAll()
        self.section.items.removeAll()
    }
    
    func loadFeed(isRefresh: Bool = false, notify: Bool = true, searchString: String? = nil) {
        
        self.onStartLoading?()
        
        self.status = .loading
        
        if isRefresh {
            
            self.page = 1
        }
        
        AppDelegate.appSettings.api.loadFeed(filter: self.filter!, page: page,
                                             pageSize: pageSize, isFavorite: self.isFavorite, searchString: searchString)
            
            .onSuccess { [unowned self] feed in
                
                self.onStopLoading?()
                
                feed.users.forEach({ user in
                    
                    self.users.insert(user)
                })
                
                if isRefresh {
                    
                    self.posts.removeAll()
                    self.section.items.removeAll()
                }
                
                self.posts.append(contentsOf: feed.posts)
                
                feed.posts.forEach { post in
                    
                    self.section.add(item: post)
                }
                
                feed.images.forEach({ image in
                    
                    self.images.insert(image)
                })
                
                feed.files.forEach({ file in
                    
                    self.files.insert(file)
                })
                
                self.locations.append(contentsOf: feed.locations)
                
                self.hasMore = feed.posts.count == self.pageSize
                
                self.page += 1
                
                self.status = .loaded
                
                if notify {
                    
                    self.onDataSourceChanged?(false)
                }
            }
            .onFailure { [unowned self] error in
                
                self.onStopLoading?()
                
                print(error.localizedDescription)
                
                if notify {
                    
                    self.onDataSourceChanged?(false)
                }
                
                self.status = .failed
            }
    }
}
