//
//  CollectionSection.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

struct CollectionSection {
    
    var title: String?
    
    var items: [CollectionSectionItem] = []
    
    var selectedItems: [CollectionSectionItem] = []
    
    var sectionType: Any?
    
    var selected = false
    
    
    init(title: String? = "") {
        
        self.title = title;
    }
    
    mutating func addItem(nibClass: AnyClass, item: Any? = nil,
                          itemType: Any? = nil, bindingAction: BindingAction? = nil) {
        
        let item = CollectionSectionItem(nibClass: nibClass,
                                         item: item,
                                         itemType: itemType,
                                         bindingAction: bindingAction)
        self.items.append(item)
    }
    
    mutating func addItem(cellStyle: UITableViewCellStyle, item: Any? = nil,
                          itemType: Any? = nil, bindingAction: BindingAction?) {
        
        let item = CollectionSectionItem(cellStyle: cellStyle,
                                         item: item,
                                         itemType: itemType,
                                         bindingAction: bindingAction)
        self.items.append(item)
        
    }
}
