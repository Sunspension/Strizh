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

final class STDialog: Object, Mappable {
    
    @objc dynamic var id = 0
    
    @objc dynamic var objectType = 0
    
    @objc dynamic var objectId = 0
    
    @objc dynamic var createdAt = Date()
    
    @objc dynamic var updatedAt: Date?
    
    @objc dynamic var messageId: Int64 = 0
    
    @objc dynamic var title = ""
    
    @objc dynamic var ownerUserId = 0
    
    @objc dynamic var postId = 0
    
    @objc dynamic var lastReadMessageId = 0
    
    @objc dynamic var maxLastReadMessageId = 0
    
    @objc dynamic var unreadMessageCount = 0
    
    var userIds = List<RealmInt>()
    
    @objc dynamic var message: STMessage?
    
    
    required convenience public init?(map: Map) {
        
        self.init()
    }
    
    override public static func primaryKey() -> String? {
        
        return "id"
    }
    
    public func mapping(map: Map) {
        
        id <- map["id"]
        objectType <- map["object_type"]
        objectId <- map["object_id"]
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: AppDelegate.appSettings.defaultFormatter))
        updatedAt <- (map["updated_at"], DateFormatterTransform(dateFormatter: AppDelegate.appSettings.defaultFormatter))
        messageId <- map["message_id"]
        title <- map["title"]
        ownerUserId <- map["owner_user_id"]
        postId <- map["post_id"]
        lastReadMessageId <- map["last_read_message_id"]
        maxLastReadMessageId <- map["max_last_read_message_id"]
        unreadMessageCount <- map["unread_message_count"]
        userIds <- (map["user_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt>())
        message <- map["message"]
    }
}
