//
//  File.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

class CollectionSection {
    
    var items: [CollectionSectionItem] = []
    
    var selectedItems: [CollectionSectionItem] = []
    
    var sectionType: Any?
    
    
    subscript(index: Int) -> CollectionSectionItem {
        
        get {
            
            return items[index]
        }
        
        set {
            
            items.insert(newValue, at: index)
        }
    }
    
    func addItem(cellClass: AnyClass, item: Any? = nil,
                 itemType: Any? = nil, bindingAction: CollectionCellBindingAction? = nil) {
        
        let item = CollectionSectionItem(cellClass: cellClass,
                                         item: item,
                                         itemType: itemType,
                                         bindingAction: bindingAction)
        self.items.append(item)
    }
}
