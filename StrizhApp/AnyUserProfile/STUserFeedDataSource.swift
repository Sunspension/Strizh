//
//  STUserFeedDataSource.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

final class STUserFeedDataSource: STDealsDataSourceBase {
    
    fileprivate var userId = 0
    
    
    init(userId: Int) {
        
        super.init()
        
        self.userId = userId
    }
    
    func loadFeed() {
        
        self.status = .loading
        
        AppDelegate.appSettings.api.loadFeed(userId: self.userId, page: self.page, pageSize: self.pageSize)
            .onSuccess { feed in
            
                self.status = .loaded
                self.hasMore = feed.posts.count == self.pageSize
                self.page += 1
                
                feed.images.forEach({ image in
                    
                    self.images.insert(image)
                })
                
                feed.files.forEach({ file in
                    
                    self.files.insert(file)
                })
                
                feed.locations.forEach({ location in
                    
                    self.locations.insert(location)
                })
                
                self.onNextItems?(feed.posts)
                self.posts.append(contentsOf: feed.posts)
                self.onDataSourceChanged?()
                
            }.onFailure { error in
            
                self.status = .failed
            }
    }
}
