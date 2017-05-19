//
//  STExtendedDialog.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 19/05/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper

struct STExtendedDialog: Mappable {

    var dialog: STDialog?
    
    var images: [STImage]?
    
    var files: [STFile]?
    
    var locations: [STLocation]?
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        dialog <- map["data"]
        images <- map["image"]
        files <- map["file"]
        locations <- map["location"]
    }
}
