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

class STFile: Object, Mappable {
    
    dynamic var id: Int64 = 0
    
    dynamic var createdAt = Date()
    
    dynamic var deleted = false
    
    dynamic var deletedAt: Date?
    
    dynamic var md5 = ""
    
    dynamic var mimeType = ""
    
    dynamic var title = ""
    
    dynamic var updatedAt: Date?
    
    dynamic var url = ""
    
    dynamic var path = ""
    
    dynamic var type = 0
    
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
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
    
    fileprivate func formatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
}

