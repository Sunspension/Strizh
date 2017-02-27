//
//  STContact.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 25/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper

struct STContact: Mappable {
    
    var id = 0
    
    var phone = ""
    
    var userId = 0
    
    var contactUserId = 0
    
    var isRegistered = false
    
    var firstName = ""
    
    var lastName = ""
    
    var createdAt = Date()
    
    var updatedAt: Date?
    
    var deleted = false
    
    var deletedAt: Date?
    
    var isInvited = false
    
    var userFirstName = ""
    
    var userLastName = ""
    
    var imageId = 0
    
    var imageUrl = ""
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        id <- map["id"]
        phone <- map["phone"]
        userId <- map["user_id"]
        contactUserId <- map["contact_user_id"]
        isRegistered <- map["is_registered"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: formatter()))
        updatedAt <- (map["updated_at"], DateFormatterTransform(dateFormatter: formatter()))
        deleted <- map["deleted"]
        deletedAt <- (map["deleted_at"], DateFormatterTransform(dateFormatter: formatter()))
        isInvited <- map["is_invited"]
        userFirstName <- map["user_first_name"]
        userLastName <- map["user_last_name"]
        imageId <- map["image_id"]
        imageUrl <- map["image_url"]
    }
    
    private func formatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
}
