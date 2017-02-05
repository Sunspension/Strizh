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

class STPost : Object, Mappable {
    
    dynamic var id = 0
    
    dynamic var title = ""
    
    dynamic var postDescription = ""
    
    dynamic var price = ""
    
    dynamic var dateFrom: String?
    
    dynamic var dateTo: String?
    
    dynamic var type = 0
    
    dynamic var isArchived = false
    
    dynamic var userId = 0
    
    dynamic var createdAt = "" // "2015-05-07 23:36:38.907042",
    
    dynamic var updatedAt = "" // "2016-10-18 19:55:26.952469",
    
    dynamic var deleted = false
    
    dynamic var deletedAt: String?
    
    dynamic var dialogCount = 0
    
    dynamic var isFavorite = false
    
    var imageIds = List<RealmInt>()
    
    var userIds = List<RealmInt>()
    
    var fileIds = List<RealmInt>()
    
    var locationIds = List<RealmInt>()
    
    var imageUrls = List<RealmString>()
    
    
    required convenience init?(map: Map) {
        
        self.init()
    }
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        title <- map["title"]
        postDescription <- map["description"]
        price <- map["price"]
        dateFrom <- map["date_from"]
        dateTo <- map["date_to"]
        type <- map["type"]
        isArchived <- map["is_archived"]
        userId <- map["user_id"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
        deleted <- map["deleted"]
        deletedAt <- map["deleted_at"]
        dialogCount <- map["dialog_count"]
        isFavorite <- map["is_favorite"]
        imageIds <- (map["image_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt>())
        userIds <- (map["user_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt>())
        fileIds <- (map["file_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt>())
        locationIds <- (map["location_ids"], ArrayOfCustomRealmObjectsTransform<RealmInt>())
        imageUrls <- (map["image_urls"], ArrayOfCustomRealmObjectsTransform<RealmString>())
        
//        imageIds.append(objectsIn: imIds.map({ RealmInt(value: [$0]) }))
        
//        let transform = TransformOf(fromJSON: { (value: [Int]?) -> List<RealmInt>? in
//            
//            let list = List<RealmInt>()
//            
//            list.append(value.map({ RealmInt(value: $0) })!)
//            
//            return list
//            
//        }, toJSON: { (value: List<RealmInt>?) -> [Int]? in
//            
//            if let value = value {
//                
//                let ids = Array(value.map({ $0.value }))
//                return ids
//            }
//            return nil
//        })
//        
//        imageIds <- (map["image_ids"], transform)
    }
}
