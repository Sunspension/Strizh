//
//  GenericCollectionSection.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class GenericCollectionSection<TItem>: NSObject {

    var title: String
    
    var items: [GenericCollectionSectionItem<TItem>] = []
    
    var headerItem: CollectionSectionHeaderFooter?
    
    var footerItem: CollectionSectionHeaderFooter?
    
    var sectionType: Any?
    
    subscript(index: Int) -> GenericCollectionSectionItem<TItem> {
        
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
        
        let item = GenericCollectionSectionItem<TItem>(item: item)
        item.itemType = itemType
        
        self.items.append(item)
    }
    
    func insert(at index: Int, item: TItem, itemType: Any? = nil) {
        
        let item = GenericCollectionSectionItem<TItem>(item: item)
        item.itemType = itemType
        
        self.items.insert(item, at: index)
    }
    
    func header(headerNibClass: AnyClass, item: Any? = nil, bindingAction: BindingHeaderFooterAction? = nil) {
        
        let header = CollectionSectionHeaderFooter(headerFooterNibClass: headerNibClass, item: item, binding: bindingAction)
        self.headerItem = header
    }
    
    func footer(footerNibClass: AnyClass, item: Any? = nil, bindingAction: BindingHeaderFooterAction? = nil) {
        
        let footer = CollectionSectionHeaderFooter(headerFooterNibClass: footerNibClass, item: item, binding: bindingAction)
        self.footerItem = footer
    }
}
