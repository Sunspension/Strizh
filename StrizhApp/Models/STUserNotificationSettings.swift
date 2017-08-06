//
//  STNotificationFilter.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 06/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class STUserNotificationSettings: Object, Mappable {
    
    dynamic var id = 1
    
    dynamic var isTopics = true
    
    dynamic var isMessages = true
    
    
    override static func primaryKey() -> String {
        
        return "id"
    }
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    func mapping(map: Map) {
        
        isTopics <- map["post"]
        isMessages <- map["message"]
    }
}
