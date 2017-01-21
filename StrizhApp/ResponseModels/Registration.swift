//
//  Auth.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper

struct Registration: Mappable {
    
    var phone = ""
    
    var device_type = ""
    
    var device_token = ""
    
    var type = 0
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        phone <- map["phone"]
        device_token <- map["device_token"]
        device_type <- map["device_type"]
        type <- map["type"]
    }
}
