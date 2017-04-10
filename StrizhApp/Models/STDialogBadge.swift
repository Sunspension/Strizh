//
//  STDialogBadge.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 10/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper

struct STDialogBadge: Mappable {
    
    var dialogId = 0
    
    var messageId = 0
    
    var lastReadMessageId = 0
    
    var unreadMessageCount = 0
    
    var maxLastReadMessageId = 0
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        self.dialogId <- map["dialog_id"]
        self.messageId <- map["message_id"]
        self.lastReadMessageId <- map["last_read_message_id"]
        self.unreadMessageCount <- map["unread_message_count"]
        self.maxLastReadMessageId <- map["max_last_read_message_id"]
    }
}
