//
//  STLocation.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 11/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper

struct STLocation: Mappable {
    
    var id = 0
    
    var deleted = false
    
    var createdAt = Date()
    
    var deletedAt: Date?
    
    var updatedAt: Date?
    
    var lat = 0.0
    
    var lon = 0.0
    
    var title = ""
    
    var userId = 0
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        id <- map["id"]
        deleted <- map["deleted"]
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: formatter()))
        deletedAt <- (map["updated_at"], DateFormatterTransform(dateFormatter: formatter()))
        lat <- map["lat"]
        lon <- map["lon"]
        title <- map["title"]
        userId <- map["user_id"]
    }
    
    fileprivate func formatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
}
