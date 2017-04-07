//
//  TableSection.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TableSection {
    
    var title: String?
    
    var items: [TableSectionItem] = []
    
    var selectedItems: [TableSectionItem] = []
    
    var headerItem: TableSectionHeaderFooter?
    
    var footerItem: TableSectionHeaderFooter?
    
    var sectionType: Any?
    
    var selected = false
    
    subscript(index: Int) -> TableSectionItem {
        
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
    
    @discardableResult
    func addItem(cellClass: AnyClass, item: Any? = nil,
                          itemType: Any? = nil, bindingAction: TableCellBindingAction? = nil) -> Int {
        
        let item = TableSectionItem(cellClass: cellClass,
                                         item: item,
                                         itemType: itemType,
                                         bindingAction: bindingAction)
        self.items.append(item)
        return self.items.index(of: item)!
    }
    
    func addItem(cellStyle: UITableViewCellStyle, item: Any? = nil,
                          itemType: Any? = nil, bindingAction: TableCellBindingAction? = nil) {
        
        let item = TableSectionItem(cellStyle: cellStyle,
                                         item: item,
                                         itemType: itemType,
                                         bindingAction: bindingAction)
        self.items.append(item)
        
    }
    
    func insert(item: Any? = nil, itemType: Any? = nil, at index: Int, cellClass: AnyClass,
                  bindingAction: TableCellBindingAction? = nil) {
        
        let item = TableSectionItem(cellClass: cellClass,
                                    item: item,
                                    itemType: itemType,
                                    bindingAction: bindingAction)
        self.items.insert(item, at: index)
    }
    
    func header(headerClass: AnyClass,  item: Any? = nil, bindingAction: BindingHeaderFooterAction? = nil) {
        
        let header = TableSectionHeaderFooter(headerFooterNibClass: headerClass, item: item, binding: bindingAction)
        self.headerItem = header
    }
    
    func footer(footerClass: AnyClass,  item: Any? = nil, bindingAction: BindingHeaderFooterAction? = nil) {
        
        let footer = TableSectionHeaderFooter(headerFooterNibClass: footerClass, item: item, binding: bindingAction)
        self.footerItem = footer
    }
}
