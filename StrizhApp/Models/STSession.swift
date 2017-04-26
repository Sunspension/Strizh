//
//  Session.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import ObjectMapper
import RealmSwift

class STSession: Object, Mappable {

    dynamic var sid = ""
    
    dynamic var userId = 0
    
    dynamic var type = ""
    
    var isFacebook: Bool {
        
        return type == "fb_code"
    }
    
    var isExpired: Bool {
        
        return userId == 0
    }
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    override static func primaryKey() -> String? {
        
        return "sid"
    }
    
    func mapping(map: Map) {
        
        sid <- map["sid"]
        userId <- map["user_id"]
        type <- map["type"]
    }
}
