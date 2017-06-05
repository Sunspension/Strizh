//
//  STBaseFilter.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 03/06/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RealmSwift

class STBaseFilter : Object {
    
    dynamic var id = 0
    
    let filterItems = List<STFilterItem>()
    
    override static func primaryKey() -> String? {
        
        return "id"
    }
}
