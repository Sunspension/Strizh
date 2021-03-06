//
//  STUser.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 30/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

final class STUser: Object, Mappable {

    dynamic var id = 0
    
    dynamic var phone = ""
    
    dynamic var firstName = ""
    
    dynamic var lastName = ""
    
    dynamic var createdAt = ""
    
    dynamic var updatedAt = ""
    
    dynamic var deleted = false
    
    dynamic var deletedAt: String?
    
    dynamic var status = 0
    
    dynamic var sendEmail = false
    
    dynamic var sendPush = false
    
    dynamic var sendSMS = false
    
    dynamic var alias = ""
    
    dynamic var email = ""
    
    dynamic var isEmailConfirmed = false
    
    dynamic var imageId = 0
    
    dynamic var imageUrl = ""
    
    dynamic var imageData: Data?
    
    // available in schema version 17
    dynamic var notificationSettings: STUserNotificationSettings!
    
    override public var hash: Int {
        
        return id.hashValue ^ firstName.hashValue
    }

    
    required convenience public init?(map: Map) {
        
        self.init()
    }
    
    override public static func primaryKey() -> String? {
        
        return "id"
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        
        if let other = object as? STUser {
            
            return self.id == other.id
        }
        else {
            
            return false
        }
    }
    
    public func mapping(map: Map) {
        
        id <- map["id"]
        phone <- map["phone"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        deleted <- map["deleted"]
        deletedAt <- map["deleted_at"]
        status <- map["status"]
        sendEmail <- map["send_email"]
        sendPush <- map["send_push"]
        sendSMS <- map["send_sms"]
        alias <- map["alias"]
        email <- map["email"]
        isEmailConfirmed <- map["is_email_confirmed"]
        imageId <- map["image_id"]
        imageUrl <- map["image_url"]
        notificationSettings <- map["notification"]
    }
}
