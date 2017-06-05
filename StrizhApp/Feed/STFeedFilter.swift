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
    
    var isOffer: Bool {
        
        return self.filterItems[0].isSelected
    }
    
    var isSearch: Bool {
        
        return self.filterItems[1].isSelected
    }

    override static func ignoredProperties() -> [String] {
        
        return ["isOffer", "isSearch"]
    }
    
    required init() {
        
        super.init()
        
        let offer = STFilterItem()
        offer.itemIconName = "feed_filter_page_offer_text".localized
        offer.itemIconName = "icon-offer"
        offer.isSelected = true
        
        let search = STFilterItem()
        search.itemName = "feed_filter_page_search_text".localized
        search.itemIconName = "icon-search"
        search.isSelected = true
        
        self.filterItems.append(objectsIn: [offer, search])
    }
    
    required init(value: Any, schema: RLMSchema) {
        
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        
        super.init(realm: realm, schema: schema)
    }
}
