//
//  GenericCollectionSectionItem.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 15/08/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class GenericCollectionSectionItem<TItem>: NSObject {
    
    var item: TItem?
    
    var itemType: Any?
    
    var selected = false
    
    var hasError = false
    
    var indexPath: IndexPath!
    
    var cellHeight: CGFloat?
    
    
    init(item: TItem?) {
        
        self.item = item
        super.init()
    }
}
