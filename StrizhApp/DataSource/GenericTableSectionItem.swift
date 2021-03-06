//
//  GenericTableSectionItem.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 15/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class GenericTableSectionItem<TItem>: Equatable {
    
    let id = UUID()
    
    var item: TItem
    
    var itemType: Any?
    
    var selected = false
    
    var hasError = false
    
    var indexPath: IndexPath!
    
    var cellHeight: CGFloat?
    
    var validation: (() -> Bool)?
    
    var allowAction = true
    
    
    init(item: TItem) {
        
        self.item = item
    }
    
    public static func ==(lhs: GenericTableSectionItem<TItem>, rhs: GenericTableSectionItem<TItem>) -> Bool {
        
        return lhs.id == rhs.id
    }
}
