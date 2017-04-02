//
//  GenericTableSection.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class GenericTableSection<TItem>: NSObject {

    var title: String
    
    var items: [GenericTableSectionItem<TItem>] = []
    
    var headerItem: TableSectionHeaderFooter?
    
    var footerItem: TableSectionHeaderFooter?
    
    var sectionType: Any?
    
    var sectionChanged: (() -> Void)?
    
    subscript(index: Int) -> GenericTableSectionItem<TItem> {
        
        get {
            
            return items[index]
        }
        
        set {
            
            items.insert(newValue, at: index)
        }
    }
    
    init(title: String? = nil) {
        
        self.title = title ?? ""
    }
    
    func add(item: TItem, itemType: Any? = nil) {
        
        let item = GenericTableSectionItem<TItem>(item: item)
        item.itemType = itemType
        
        self.items.append(item)
    }
    
    func insert(at index: Int, item: TItem, itemType: Any? = nil) {
        
        let item = GenericTableSectionItem<TItem>(item: item)
        item.itemType = itemType
        
        self.items.insert(item, at: index)
    }
    
    func header(headerNibClass: AnyClass, item: Any? = nil, bindingAction: BindingHeaderFooterAction? = nil) {
        
        let header = TableSectionHeaderFooter(headerFooterNibClass: headerNibClass, item: item, binding: bindingAction)
        self.headerItem = header
    }
    
    func footer(footerNibClass: AnyClass, item: Any? = nil, bindingAction: BindingHeaderFooterAction? = nil) {
        
        let footer = TableSectionHeaderFooter(headerFooterNibClass: footerNibClass, item: item, binding: bindingAction)
        self.footerItem = footer
    }
}
