//
//  STFeedFilter.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RealmSwift

class STFeedFilter: Object {
    
    dynamic var id = 0
    
    dynamic var offer = true
    
    dynamic var search = true
    
    dynamic var showArchived = false
    
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
}
