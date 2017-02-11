//
//  STImageResponse.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 30/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper

struct STImage: Mappable, Hashable, Equatable {

    var id = 0
    
    var userId = 0
    
    var path = ""
    
    var url = ""
    
    var hashValue: Int {
        
        return id.hashValue ^ userId.hashValue
    }
    
    init?(map: Map) {
    
    }
    
    mutating func mapping(map: Map) {
        
        id <- map["id"]
        userId <- map["user_id"]
        path <- map["path"]
        url <- map["url"]
    }
    
    static func ==(lhs: STImage, rhs: STImage) -> Bool {
        
        return lhs.id == rhs.id
    }
}
