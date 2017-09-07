//
//  STImageResponse.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 30/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

final class STImage: Object, Mappable {

    dynamic var id: Int64 = 0
    
    dynamic var userId = 0
    
    dynamic var path = ""
    
    dynamic var url = ""
    
    
    required convenience public init?(map: Map) {
    
        self.init()
    }
    
    override public static func primaryKey() -> String? {
        
        return "id"
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        
        if let other = object as? STImage {
            
            return self.id == other.id
        }
        else {
            
            return false
        }
    }
    
    public func mapping(map: Map) {
        
        id <- (map["id"], NSNumberToInt64Transform())
        userId <- map["user_id"]
        path <- map["path"]
        url <- map["url"]
    }
}
