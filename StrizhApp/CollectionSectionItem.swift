//
//  CollectionSectionItem.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

typealias BindingAction = ((_ cell: UITableViewCell, _ item: CollectionSectionItem) -> Void)

struct CollectionSectionItem {
    
    var item: Any?
    
    var itemType: Any?
    
    var userData: Any?
    
    var validation: (() -> Bool)?
    
    var selected = false
    
    var indexPath: IndexPath!
    
    var bindingAction: BindingAction?
    
    var cellHeight: CGFloat?
    
    var cellClass: AnyClass?
    
    var nibClass: AnyClass?
    
    
    init(nibClass: AnyClass,
         item: Any? = nil,
         itemType: Any? = nil,
         bindingAction: BindingAction? = nil) {
        
        self.nibClass = nibClass
        self.item = item
        self.itemType = itemType
        self.bindingAction = bindingAction
    }
}
