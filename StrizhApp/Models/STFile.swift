//
//  STFile.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 11/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

final class STFile: Object, Mappable {
    
    @objc dynamic var id: Int64 = 0
    
    @objc dynamic var createdAt = Date()
    
    @objc dynamic var deleted = false
    
    @objc dynamic var deletedAt: Date?
    
    @objc dynamic var md5 = ""
    
    @objc dynamic var mimeType = ""
    
    @objc dynamic var title = ""
    
    @objc dynamic var updatedAt: Date?
    
    @objc dynamic var url = ""
    
    @objc dynamic var path = ""
    
    @objc dynamic var type = 0
    
    
    required convenience public init?(map: Map) {
        
        self.init()
    }
    
    override public static func primaryKey() -> String? {
        
        return "id"
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        
        if let other = object as? STFile {
            
            return self.id == other.id
        }
        else {
            
            return false
        }
    }
    
    public func mapping(map: Map) {
        
        id <- (map["id"], NSNumberToInt64Transform())
        deleted <- map["deleted"]
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: formatter()))
        deletedAt <- (map["deleted_at"], DateFormatterTransform(dateFormatter: formatter()))
        updatedAt <- (map["updated_at"], DateFormatterTransform(dateFormatter: formatter()))
        md5 <- map["md5"]
        mimeType <- map["mime_type"]
        title <- map["title"]
        url <- map["url"]
        path <- map["path"]
        type <- map["type"]
    }
    
    private func formatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
}

