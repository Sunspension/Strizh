//
//  STDialogFilter.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 05/06/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

import Foundation
import RealmSwift
import Realm

class STDialogFilter: STBaseFilter {
    
    var isAll: Bool {
        
        return self.filterItems[0].isSelected
    }
    
    var isIncoming: Bool {
        
        return self.filterItems[1].isSelected
    }
    
    var isOutgoing: Bool {
        
        return self.filterItems[2].isSelected
    }
    
    override static func ignoredProperties() -> [String] {
        
        return ["isAll", "isIncoming", "isOutgoing"]
    }
}
