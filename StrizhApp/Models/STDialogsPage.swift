//
//  STDialogsPage.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 25/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper

struct STDialogsPage: Mappable {
    
    var dialogs: [STDialog] = []
    
    var users: [STUser] = []
    
    var messages: [STMessage] = []
    
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        
        users <- map["user"]
        dialogs <- map["dialog"]
        messages <- map["message"]
    }
}
