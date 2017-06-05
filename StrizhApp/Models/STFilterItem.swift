//
//  STFilterItem.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 03/06/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class STFilterItem: Object {
    
    dynamic var id = 0
    
    dynamic var itemName = ""
    
    dynamic var itemIconName = ""
    
    dynamic var isSelected = false
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
}
