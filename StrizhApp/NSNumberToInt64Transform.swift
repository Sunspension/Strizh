//
//  NSNumberToInt64Transform.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 19/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class NSNumberToInt64Transform: TransformType {
    
    func transformFromJSON(_ value: Any?) -> Int64? {
    
        return value.map({ ($0 as! NSNumber).int64Value })
    }
    
    func transformToJSON(_ value: Int64?) -> NSNumber? {
    
        return value.map({ NSNumber(value: $0) })
    }
}
