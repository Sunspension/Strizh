//
//  SectionItem.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

class SectionItem: Equatable, Hashable {
    
    let id = UUID()
    
    var item: Any?
    
    var itemType: Any?
    
    var userData: Any?
    
    var validation: (() -> ValidationResult)?
    
    var hasError = false
    
    var selected = false
    
    var allowAction = true
    
    var indexPath: IndexPath!

    var cellClass: AnyClass?
    
    var hashValue: Int {
        
        return id.hashValue ^ 344
    }
    
    public static func == (lhs: SectionItem, rhs: SectionItem) -> Bool {
        
        return lhs.id == rhs.id
    }
}
