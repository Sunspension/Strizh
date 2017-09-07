//
//  STMessage.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 25/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
import Realm

final class STMessage: Object, Mappable, Copying {
    
    dynamic var id: Int64 = 0
    
    dynamic var userId = 0
    
    dynamic var message = ""
    
    dynamic var createdAt = Date()
    
    dynamic var dialogId = 0
    
    dynamic var objectId = 0
    
    dynamic var objectType = 0
    
    dynamic var lastMessageId: Int64 = 0
    
    var fileIds = List<RealmInt64>()
    
    var imageIds = List<RealmInt64>()
    
    var locationIds = List<RealmInt>()
    
    var audioIds = List<RealmInt64>()
    
    
    convenience init(message: String, createdAt: Date, userId: Int) {
        
        self.init()
        
        self.message = message
        self.createdAt = createdAt
        self.userId = userId
    }
    
    required convenience public init?(map: Map) {
        
        self.init()
    }
    
    override public static func primaryKey() -> String? {
        
        return "id"
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        
        if let other = object as? STMessage {
            
            return self.id == other.id
        }
        else {
            
            return false
        }
    }
    
    required convenience public init(original: STMessage) {
        
        self.init()
        
        self.id = original.id
        self.userId = original.userId
        self.message = original.message
        self.createdAt = original.createdAt
        self.dialogId = original.dialogId
        self.objectId = original.objectId
        self.objectType = original.objectType
        self.lastMessageId = original.lastMessageId
        
        self.fileIds = List<RealmInt64>()
        self.fileIds.append(objectsIn: original.fileIds)
        
        self.imageIds = List<RealmInt64>()
        self.imageIds.append(objectsIn: original.imageIds)
        
        self.locationIds = List<RealmInt>()
        self.locationIds.append(objectsIn: original.locationIds)
        
        self.audioIds = List<RealmInt64>()
        self.audioIds.append(objectsIn: original.audioIds)
    }
    
    public func mapping(map: Map) {
        
        id <- map["id"]
        userId <- map["user_id"]
        message <- map["message"]
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: AppDelegate.appSettings.defaultFormatter))
        dialogId <- map["dialog_id"]
        objectId <- map["object_id"]
        objectType <- map["object_type"]
        lastMessageId <- (map["last_message_id"], NSNumberToInt64Transform())
        fileIds <- (map["file_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt64>())
        imageIds <- (map["image_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt64>())
        locationIds <- (map["location_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt>())
        audioIds <- (map["audio_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt64>())
    }
}
