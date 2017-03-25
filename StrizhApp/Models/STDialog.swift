//
//  STDialog.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 25/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class STDialog: Object, Mappable {
    
    dynamic var id = 0
    
    dynamic var objectType = 0
    
    dynamic var objectId = 0
    
    dynamic var createdAt = Date()
    
    dynamic var messageId = 0
    
    dynamic var title = ""
    
    dynamic var ownerUserId = 0
    
    dynamic var postId = 0
    
    dynamic var lastReadMessageId = 0
    
    dynamic var maxLastReadMessageId = 0
    
    dynamic var unreadMessageCount = 0
    
    var userIds = List<RealmInt>()
    
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        objectType <- map["object_type"]
        objectId <- map["object_id"]
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: AppDelegate.appSettings.defaultFormatter))
        messageId <- map["message_id"]
        title <- map["title"]
        ownerUserId <- map["owner_user_id"]
        postId <- map["post_id"]
        lastReadMessageId <- map["last_read_message_id"]
        maxLastReadMessageId <- map["max_last_read_message_id"]
        unreadMessageCount <- map["unread_message_count"]
        userIds <- (map["user_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt>())
    }
}
