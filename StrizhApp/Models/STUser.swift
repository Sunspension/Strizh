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

    @objc dynamic var id = 0
    
    @objc dynamic var phone = ""
    
    @objc dynamic var firstName = ""
    
    @objc dynamic var lastName = ""
    
    @objc dynamic var createdAt = ""
    
    @objc dynamic var updatedAt = ""
    
    @objc dynamic var deleted = false
    
    @objc dynamic var deletedAt: String?
    
    @objc dynamic var status = 0
    
    @objc dynamic var sendEmail = false
    
    @objc dynamic var sendPush = false
    
    @objc dynamic var sendSMS = false
    
    @objc dynamic var alias = ""
    
    @objc dynamic var email = ""
    
    @objc dynamic var isEmailConfirmed = false
    
    @objc dynamic var imageId = 0
    
    @objc dynamic var imageUrl = ""
    
    @objc dynamic var imageData: Data?
    
    // available in schema version 17
    @objc dynamic var notificationSettings: STUserNotificationSettings!
    
    override public var hash: Int {
        
        return id.hashValue ^ firstName.hashValue
    }

    
    required convenience public init?(map: Map) {
        
        self.init()
    }
    
    override public static func primaryKey() -> String? {
        
        return "id"
    }
    
    @objc override public func isEqual(_ object: Any?) -> Bool {
        
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
