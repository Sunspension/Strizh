//
//  CollectionSectionItem.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

typealias CollectionCellBindingAction = ((_ cell: UICollectionViewCell, _ item: CollectionSectionItem) -> Void)

class CollectionSectionItem: SectionItem {
    
    var bindingAction: CollectionCellBindingAction?
    
    var cellHeight: CGFloat?
    
    init(cellClass: AnyClass,
         item: Any? = nil,
         itemType: Any? = nil,
         bindingAction: CollectionCellBindingAction? = nil) {
        
        super.init()
        
        self.cellClass = cellClass
        self.item = item
        self.itemType = itemType
        self.bindingAction = bindingAction
    }
}
