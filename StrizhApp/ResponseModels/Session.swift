//
//  Session.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import ObjectMapper

struct Session: Mappable {

    var sid = ""
    
    var userId = 0
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        sid <- map["sid"]
        userId <- map["user_id"]
    }
}
