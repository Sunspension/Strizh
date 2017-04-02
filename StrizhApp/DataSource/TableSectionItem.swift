//
//  TableSectionItem.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

typealias TableCellBindingAction = ((_ cell: UITableViewCell, _ item: TableSectionItem) -> Void)


class TableSectionItem: SectionItem {
    
    
    var bindingAction: TableCellBindingAction?
    
    var cellHeight: CGFloat?
    
    var cellStyle: UITableViewCellStyle?
    
    
    init(cellClass: AnyClass,
         item: Any? = nil,
         itemType: Any? = nil,
         bindingAction: TableCellBindingAction? = nil) {
        
        super.init()
        
        self.cellClass = cellClass
        self.item = item
        self.itemType = itemType
        self.bindingAction = bindingAction
    }
    
    init(cellStyle: UITableViewCellStyle,
         item: Any? = nil,
         itemType: Any? = nil,
         bindingAction: TableCellBindingAction? = nil) {
        
        super.init()
        
        self.cellStyle = cellStyle
        self.item = item
        self.itemType = itemType
        self.bindingAction = bindingAction
    }
}
