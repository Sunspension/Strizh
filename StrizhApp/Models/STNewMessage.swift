//
//  STNewMessage.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/06/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper

struct STNewMessage: Mappable {
    
    var title = ""
    
    var message = ""
    
    var objectId = 0
    
    var objectType = 0
    
    var dialogId = 0
    
    var messageId = 0
    
    var type = ""
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        title <- map["title"]
        message <- map["message"]
        objectId <- map["object_id"]
        objectType <- map["object_type"]
        dialogId <- map["dialog_id"]
        messageId <- map["message_id"]
        type <- map["type"]
    }
}
