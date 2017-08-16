//
//  TableSection.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class TableSection: Equatable {
    
    var id = UUID()
    
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
    
    public static func == (lhs: TableSection, rhs: TableSection) -> Bool {
        
        return lhs.id == rhs.id
    }
    
    @discardableResult
    func add(item: Any? = nil, itemType: Any? = nil,
                 cellClass: AnyClass, bindingAction: TableCellBindingAction? = nil) -> Int {
        
        let item = TableSectionItem(cellClass: cellClass,
                                         item: item,
                                         itemType: itemType,
                                         bindingAction: bindingAction)
        self.items.append(item)
        return self.items.index(of: item)!
    }
    
    func add(item: Any? = nil, itemType: Any? = nil,
                 cellStyle: UITableViewCellStyle, bindingAction: TableCellBindingAction? = nil) {
        
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
    
    func header(item: Any? = nil, headerClass: AnyClass, bindingAction: BindingHeaderFooterAction? = nil) {
        
        let header = TableSectionHeaderFooter(headerFooterNibClass: headerClass, item: item, binding: bindingAction)
        self.headerItem = header
    }
    
    func footer(item: Any? = nil, footerClass: AnyClass, bindingAction: BindingHeaderFooterAction? = nil) {
        
        let footer = TableSectionHeaderFooter(headerFooterNibClass: footerClass, item: item, binding: bindingAction)
        self.footerItem = footer
    }
}
