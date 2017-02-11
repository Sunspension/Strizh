//
//  STFeed.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 11/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper

struct STFeed : Mappable {
    
    var posts: [STPost] = []
    
    var users: [STUser] = []
    
    var images: [STImage] = []
    
    var locations: [STLocation] = []
    
    var files: [STFile] = []
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        posts <- map["post"]
        users <- map["user"]
        images <- map["user"]
        locations <- map["location"]
        files <- map["file"]
    }
}
