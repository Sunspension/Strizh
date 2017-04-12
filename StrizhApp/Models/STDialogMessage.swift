//
//  STDialogMessage.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 13/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import ObjectMapper

struct STDialogMessage: Mappable {

    var dialog: STDialog?
    
    var message: STMessage?
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        dialog <- map["data"]
        message <- map["message"]
    }
}
