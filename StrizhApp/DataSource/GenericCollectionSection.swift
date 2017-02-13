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
