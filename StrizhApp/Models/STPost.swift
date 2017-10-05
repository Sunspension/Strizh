//
//  STPost.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 04/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

final class STPost : Object, Mappable {
    
    @objc dynamic var id = 0
    
    @objc dynamic var parentId = 0
    
    @objc dynamic var title = ""
    
    @objc dynamic var postDescription = ""
    
    @objc dynamic var price = ""
    
    @objc dynamic var priceDescription = ""
    
    @objc dynamic var profitDescription = ""
    
    @objc dynamic var dateFrom: Date?
    
    @objc dynamic var dateTo: Date?
    
    @objc dynamic var type = 0
    
    @objc dynamic var isArchived = false
    
    @objc dynamic var userId = 0
    
    @objc dynamic var createdAt: Date? // "2015-05-07 23:36:38"
    
    @objc dynamic var updatedAt: Date? // "2016-10-18 19:55:26"
    
    @objc dynamic var deleted = false
    
    @objc dynamic var deletedAt: String?
    
    @objc dynamic var dialogCount = 0
    
    @objc dynamic var isFavorite = false
    
    @objc dynamic var user: STUser?
    
    @objc dynamic var isPublic = false
    
    var images = List<STImage>()
    
    var files = List<STFile>()
    
    var locations = List<STLocation>()
    
    var imageIds = List<RealmInt64>()
    
    var userIds = List<RealmInt>()
    
    var fileIds = List<RealmInt64>()
    
    var locationIds = List<RealmInt>()
    
    var imageUrls = List<RealmString>()
    
    
    required convenience public init?(map: Map) {
        
        self.init()
    }
    
    override public static func primaryKey() -> String? {
        
        return "id"
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        
        if let other = object as? STPost {
            
            return self.id == other.id
        }
        else {
            
            return false
        }
    }
    
    public func mapping(map: Map) {
        
        id <- map["id"]
        parentId <- map["parent_id"]
        title <- map["title"]
        postDescription <- map["description"]
        price <- map["price"]
        priceDescription <- map["price_description"]
        profitDescription <- map["profit_description"]
        dateFrom <- (map["date_from"], DateFormatterTransform(dateFormatter: self.fromToFormatter()))
        dateTo <- (map["date_to"], DateFormatterTransform(dateFormatter: self.fromToFormatter()))
        type <- map["type"]
        isArchived <- map["is_archived"]
        userId <- map["user_id"]
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: self.formatter()))
        updatedAt <- (map["updated_at"], DateFormatterTransform(dateFormatter: self.formatter()))
        deleted <- map["deleted"]
        deletedAt <- map["deleted_at"]
        dialogCount <- map["dialog_count"]
        isFavorite <- map["is_favorite"]
        isPublic <- map["is_public"]
        imageIds <- (map["image_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt64>())
        userIds <- (map["user_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt>())
        fileIds <- (map["file_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt64>())
        locationIds <- (map["location_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt>())
        imageUrls <- (map["image_urls"], ArrayOfCustomRealmObjectsTransform<RealmString>())
        user <- map["user"]
        images <- (map["image"], ArrayTransform<STImage>())
        files <- (map["file"], ArrayTransform<STFile>())
        locations <- (map["location"], ArrayTransform<STLocation>())
    }
    
    private func formatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
    
    private func fromToFormatter() -> DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
