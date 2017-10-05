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

final class STLocation: Object, Mappable {
    
    @objc dynamic var id = 0
    
    @objc dynamic var deleted = false
    
    @objc dynamic var createdAt = Date()
    
    @objc dynamic var deletedAt: Date?
    
    @objc dynamic var updatedAt: Date?
    
    @objc dynamic var lat = 0.0
    
    @objc dynamic var lon = 0.0
    
    @objc dynamic var title = ""
    
    @objc dynamic var userId = 0
    
    
    required convenience public init?(map: Map) {
        
        self.init()
    }
    
    override public static func primaryKey() -> String? {
        
        return "id"
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        
        if let other = object as? STLocation {
            
            return self.id == other.id
        }
        else {
            
            return false
        }
    }
    
    public func mapping(map: Map) {
        
        id <- map["id"]
        deleted <- map["deleted"]
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: formatter()))
        deletedAt <- (map["updated_at"], DateFormatterTransform(dateFormatter: formatter()))
        lat <- map["lat"]
        lon <- map["lon"]
        title <- map["title"]
        userId <- map["user_id"]
    }
    
    private func formatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
}
