//
//  STFeedFilter.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class STFeedFilter: STBaseFilter {
    
    var isAll: Bool {
        
        return self.filterItems[0].isSelected
    }
    
    var isOffer: Bool {
        
        return self.filterItems[1].isSelected
    }
    
    var isSearch: Bool {
        
        return self.filterItems[2].isSelected
    }

    override static func ignoredProperties() -> [String] {
        
        return ["isAll", "isOffer", "isSearch"]
    }    
}
