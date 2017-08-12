//
//  TItem.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

final class TItem: Equatable, Hashable {
    
    let id = UUID()
    
    var model: Any?
    
    var type: Any?
    
    var hashValue: Int {
        
        return id.hashValue ^ 344
    }
    
    public static func == (lhs: TItem, rhs: TItem) -> Bool {
        
        return lhs.id == rhs.id
    }
    
    init(model: Any) {
        
        self.model = model
    }
}
