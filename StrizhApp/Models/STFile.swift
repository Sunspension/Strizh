//
//  STFile.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 11/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper

struct STFile: Mappable, Hashable, Equatable {
    
    var id: Int64 = 0
    
    var createdAt = Date()
    
    var deleted = false
    
    var deletedAt: Date?
    
    var md5 = ""
    
    var mimeType = ""
    
    var title = ""
    
    var updatedAt: Date?
    
    var url = ""
    
    var path = ""
    
    var type = 0
    
    var hashValue: Int {
        
        return id.hashValue ^ title.hashValue
    }
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
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
    
    static func ==(lhs: STFile, rhs: STFile) -> Bool {
        
        return lhs.id == rhs.id
    }
    
    private func formatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
}

