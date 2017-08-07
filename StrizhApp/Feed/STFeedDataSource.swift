//
//  STFeedDataSource.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 07/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

class STFeedDataSource {
    
    fileprivate var status = STLoadingStatusEnum.idle {
        
        willSet {
            
            self.onLoadingStatusChanged?(newValue)
        }
    }
    
    fileprivate var page = 1
    
    fileprivate var searchPage = 1
    
    fileprivate var pageSize: Int = 0
    
    fileprivate var hasMore = false
    
    fileprivate var filter: STFeedFilter {
        
        return AppDelegate.appSettings.feedFilter
    }
    
    fileprivate lazy var analytics: STAnalytics = {
        
        return try! AppDelegate.appSettings.dependencyContainer.resolve()
    }()
    
    private(set) var isFavorite: Bool
    
    var canLoadNext: Bool {
        
        return hasMore && status != .loading
    }
    
    var users = Set<STUser>()
    
    var locations = Set<STLocation>()
    
    var images = Set<STImage>()
    
    var files = Set<STFile>()
    
    var posts = [STPost]()
    
    var onDataSourceChanged:((_ animation: Bool) -> Void)?
    
    var onLoadingStatusChanged: ((_ status: STLoadingStatusEnum) -> Void)?
    
    var disableAddToFavoriteHadler = false
    
    
    init(pageSize: Int = 20, isFavorite: Bool = false) {
        
        self.pageSize = pageSize
        self.isFavorite = isFavorite
        
        
        if !self.disableAddToFavoriteHadler {
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.onItemFavoriteNotification),
                                                   name: NSNotification.Name(kItemFavoriteNotification), object: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onPostDeleteNotification),
                                               name: NSNotification.Name(kPostDeleteFromDetailsNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onPostDeleteNotification),
                                               name: NSNotification.Name(kPostDeleteNotification), object: nil)
    }
    
    @objc func onPostDeleteNotification(_ notification: Notification) {
        
        let post = notification.object as! STPost
        let count = self.posts.count
        
        self.posts.remove(object: post)
        
        if count != self.posts.count {
            
            self.onDataSourceChanged?(false)
        }
    }
    
    @objc func onItemFavoriteNotification(_ notification: Notification) {
        
        let post = notification.object as! STPost
        
        if self.isFavorite {
            
            if post.isFavorite {
                
                // analytics
                self.analytics.logEvent(eventName: st_eFavoriteAdd, params: ["post_id" : post.id])
                self.posts.insert(post, at: 0)
            }
            else {
                
                // analytics
                self.analytics.logEvent(eventName: st_eFavoriteRemove, params: ["post_id" : post.id])
                self.posts.remove(object: post)
            }
            
            self.onDataSourceChanged?(false)
        }
        else {
            
            if let item = posts.filter({ $0.id == post.id }).first {
                
                item.isFavorite = post.isFavorite
                self.onDataSourceChanged?(false)
            }
        }
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
        
        if (self.posts.count == 0 && self.status != .loaded) || self.status == .idle {
            
            loadFeed()
        }
    }
    
    func reloadFilter(notify: Bool) {
        
        reset()
        self.loadFeed(notify: notify)
    }
    
    func reset() {
        
        self.page = 1
        self.posts.removeAll()
        self.files.removeAll()
        self.locations.removeAll()
        self.images.removeAll()
        self.users.removeAll()
    }
    
    func loadFeed(isRefresh: Bool = false, notify: Bool = true,
                  searchString: String? = nil, complete: (() -> Void)? = nil) {
        
        guard self.status != .loading else {
            
            return
        }
        
        self.status = .loading
        
        if isRefresh {
            
            reset()
            
            // analytics
            self.analytics.logEvent(eventName: st_eFeedRefresh)
        }
        
        if searchString != nil {
            
            // analytics
            self.analytics.logEvent(eventName: st_eFeedSearch, params: ["query" : searchString!])
        }
        
        AppDelegate.appSettings.api.loadFeed(filter: self.filter, page: page,
                                             pageSize: pageSize, isFavorite: self.isFavorite, searchString: searchString)
            
            .onSuccess { [unowned self] feed in
                
                feed.users.forEach({ user in
                    
                    self.users.insert(user)
                })
                
                if isRefresh {
                    
                    self.posts.removeAll()
                }
                
                for post in feed.posts {
                    
                    if self.isFavorite && self.posts.contains(post) {
                        
                        continue
                    }
                    
                    self.posts.append(post)
                }
                
                feed.images.forEach({ image in
                    
                    self.images.insert(image)
                })
                
                feed.files.forEach({ file in
                    
                    self.files.insert(file)
                })
                
                feed.locations.forEach({ location in
                    
                    self.locations.insert(location)
                })
                
                self.hasMore = feed.posts.count == self.pageSize
                
                self.page += 1
                
                // analytics
                self.analytics.logEvent(eventName: st_eFeedScroll, params: ["page" : self.page])
                
                self.status = .loaded
                
                complete?()
                
                if notify {
                    
                    self.onDataSourceChanged?(false)
                }
            }
            .onFailure { [unowned self] error in
                
                self.status = .failed
                
                if notify {
                    
                    self.onDataSourceChanged?(false)
                }
        }
    }
}
