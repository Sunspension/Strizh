//
//  STLocation.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 11/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class STLocation: Object, Mappable {
    
    dynamic var id = 0
    
    dynamic var deleted = false
    
    dynamic var createdAt = Date()
    
    dynamic var deletedAt: Date?
    
    dynamic var updatedAt: Date?
    
    dynamic var lat = 0.0
    
    dynamic var lon = 0.0
    
    dynamic var title = ""
    
    dynamic var userId = 0
    
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        
        if let other = object as? STLocation {
            
            return self.id == other.id
        }
        else {
            
            return false
        }
    }
    
    func mapping(map: Map) {
        
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
