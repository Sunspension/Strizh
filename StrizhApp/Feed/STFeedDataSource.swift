//
//  STFeedDataSource.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 07/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

class STFeedDataSource: STDealsDataSourceBase {
    
    fileprivate var searchPage = 1
    
    fileprivate var filter: STFeedFilter {
        
        return AppDelegate.appSettings.feedFilter
    }
    
    fileprivate lazy var analytics: STAnalytics = {
        
        return try! AppDelegate.appSettings.dependencyContainer.resolve()
    }()
    
    private(set) var isFavorite = false
    
    var users = Set<STUser>()
    
    var disableAddToFavoriteHadler = false
    
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    init(pageSize: Int = 20, isFavorite: Bool = false) {
        
        super.init()
        
        self.isFavorite = isFavorite
        self.pageSize = pageSize
        
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
            
            self.onDataSourceChanged?()
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
            
            self.onDataSourceChanged?()
        }
        else {
            
            if let item = posts.filter({ $0.id == post.id }).first {
                
                item.isFavorite = post.isFavorite
                self.onDataSourceChanged?()
            }
        }
    }
    
    func userBy(post: STPost) -> STUser? {
        
        return self.users.first(where: { $0.id == post.userId })
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
                    
                    self.onDataSourceChanged?()
                }
            }
            .onFailure { [unowned self] error in
                
                self.status = .failed
                
                if notify {
                    
                    self.onDataSourceChanged?()
                }
        }
    }
}
