//
//  STQueryParametersEnum.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 03/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

enum STQueryParametersEnum {
    
    case sortingOrder, filters, conditions, page, pageSize
    
    var describing: String {
        
        switch self {
            
        case .sortingOrder:
            return "order"
            
        case .conditions:
            return "conditions"
            
        case .filters:
            return "filters"
            
        case .page:
            return "page"
            
        case .pageSize:
            return "page_size"
        }
    }
}
