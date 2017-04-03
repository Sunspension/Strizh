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

class STMessage: Object, Mappable {
    
    dynamic var id = 0
    
    dynamic var userId = 0
    
    dynamic var message = ""
    
    dynamic var createdAt = Date()
    
    dynamic var dialogId = 0
    
    dynamic var objectId = 0
    
    dynamic var objectType = 0
    
    var fileIds = List<RealmInt64>()
    
    var imageIds = List<RealmInt64>()
    
    var locationIds = List<RealmInt>()
    
    var audioIds = List<RealmInt64>()
    
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        userId <- map["user_id"]
        message <- map["message"]
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: AppDelegate.appSettings.defaultFormatter))
        dialogId <- map["dialog_id"]
        objectId <- map["object_id"]
        objectType <- map["object_type"]
        fileIds <- (map["file_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt64>())
        imageIds <- (map["image_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt64>())
        locationIds <- (map["location_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt>())
        audioIds <- (map["audio_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt64>())
    }
}