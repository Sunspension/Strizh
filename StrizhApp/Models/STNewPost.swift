//
//  STNewPost.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/07/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper

struct STNewPost: Mappable {
    
    var title = ""
    
    var body = ""
    
    var postId = 0
    
    var imageUrl = ""
    
    var type = ""
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        title <- map["title"]
        body <- map["body"]
        postId <- map["post_id"]
        imageUrl <- map["image_url"]
        type <- map["type"]
    }
}
