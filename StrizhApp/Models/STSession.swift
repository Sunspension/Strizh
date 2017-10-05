//
//  Session.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import ObjectMapper
import RealmSwift

final class STSession: Object, Mappable {

    @objc dynamic var sid = ""
    
    @objc dynamic var userId = 0
    
    @objc dynamic var type = ""
    
    var isFacebook: Bool {
        
        return type == "fb_code"
    }
    
    var isExpired: Bool {
        
        return userId == 0
    }
    
    required convenience public init?(map: Map) {
        
        self.init()
    }
    
    override public static func primaryKey() -> String? {
        
        return "sid"
    }
    
    public func mapping(map: Map) {
        
        sid <- map["sid"]
        userId <- map["user_id"]
        type <- map["type"]
    }
}
