//
//  STDealsDataSource.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

class STDealsDataSourceBase {
    
    var status = STLoadingStatusEnum.idle {
        
        willSet {
            
            self.onLoadingStatusChanged?(newValue)
        }
    }
    
    var page = 1
    
    var pageSize = 20
    
    var hasMore = false
    
    var canLoadNext: Bool {
        
        return hasMore && status != .loading
    }
    
    var posts = [STPost]()
    
    var locations = Set<STLocation>()
    
    var images = Set<STImage>()
    
    var files = Set<STFile>()
    
    var onDataSourceChanged:(() -> Void)?
    
    var onNextItems:((_ items: [STPost]) -> Void)?
    
    var onLoadingStatusChanged: ((_ status: STLoadingStatusEnum) -> Void)?
    
    
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
}
