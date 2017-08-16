//
//  STNewPostObject.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

class STUserPostObject {
    
    enum PostObjectType {
        
        case new, old
    }
    
    var id = 0
    
    var type = 0
    
    var title = ""
    
    var details = ""
    
    var fromDate: Date?
    
    var tillDate: Date?
    
    var price = ""
    
    var priceDescription = ""
    
    var profitDescription = ""
    
    var imageIds: [Int64]?
    
    var locationIds: [Int]?
    
    var userIds = [Int]()
    
    var images: Set<STImage>?
    
    var objectType = PostObjectType.new
    
    var isPublic = false
    
    
    init() { }
    

    init(post: STPost) {
        
        self.id = post.id
        self.type = post.type
        self.title = post.title
        self.details = post.postDescription
        self.price = post.price
        self.priceDescription = post.priceDescription
        self.profitDescription = post.profitDescription
        self.fromDate = post.dateFrom
        self.tillDate = post.dateTo
        self.imageIds = post.imageIds.map({ $0.value })
        self.locationIds = post.locationIds.map({ $0.value })
        self.userIds = post.userIds.map({ $0.value })
        self.objectType = .old
        self.isPublic = post.isPublic
    }
}
