//
//  CollectionSection.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class CollectionSection {
    
    var title: String?
    
    var items: [CollectionSectionItem] = []
    
    var selectedItems: [CollectionSectionItem] = []
    
    var headerItem: CollectionSectionHeaderFooter?
    
    var footerItem: CollectionSectionHeaderFooter?
    
    var sectionType: Any?
    
    var selected = false
    
    subscript(index: Int) -> CollectionSectionItem {
        
        get {
            
            return items[index]
        }
        
        set {
            
            items.insert(newValue, at: index)
        }
    }
    
    
    init(title: String? = "") {
        
        self.title = title;
    }
    
    func addItem(cellClass: AnyClass, item: Any? = nil,
                          itemType: Any? = nil, bindingAction: BindingAction? = nil) {
        
        let item = CollectionSectionItem(cellClass: cellClass,
                                         item: item,
                                         itemType: itemType,
                                         bindingAction: bindingAction)
        self.items.append(item)
    }
    
    func addItem(cellStyle: UITableViewCellStyle, item: Any? = nil,
                          itemType: Any? = nil, bindingAction: BindingAction? = nil) {
        
        let item = CollectionSectionItem(cellStyle: cellStyle,
                                         item: item,
                                         itemType: itemType,
                                         bindingAction: bindingAction)
        self.items.append(item)
        
    }
    
    func header(headerClass: AnyClass,  item: Any? = nil, bindingAction: BindingHeaderFooterAction? = nil) {
        
        let header = CollectionSectionHeaderFooter()
        header.item = item
        header.bindingAction = bindingAction
        
        self.headerItem = header
    }
    
    func footer(headerClass: AnyClass,  item: Any? = nil, bindingAction: BindingHeaderFooterAction? = nil) {
        
        let footer = CollectionSectionHeaderFooter()
        footer.item = item
        footer.bindingAction = bindingAction
        
        self.footerItem = footer
    }
}
