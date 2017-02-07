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
    
    var sectionType: Any?
    
    
    init(title: String? = nil) {
        
        self.title = title ?? ""
    }
    
    func add(item: TItem, itemType: Any? = nil) {
        
        let item = GenericCollectionSectionItem<TItem>(item: item)
        item.itemType = itemType
        
        self.items.append(item)
    }
}

//class GenericCollectionSection<TItem, UCell: UITableViewCell>: NSObject {
//    
//    var title: String
//    
//    var items: [GenericCollectionSectionItem<TItem>] = []
//    
//    var sectionType: Any?
//    
//    var cellClass: UCell?
//    
//    var nibClass: UCell?
//    
//    var binding: ((_ item: GenericCollectionSectionItem<TItem>, _ cell: UCell) -> Void)?
//    
//    
//    init(title: String? = nil, nibClass: UCell,
//         binding: ((_ item: GenericCollectionSectionItem<TItem>, _ cell: UCell) -> Void)?) {
//        
//        self.title = title ?? ""
//        self.nibClass = nibClass
//        self.binding = binding
//    }
//    
//    init(title: String? = nil, cellClass: UCell,
//         binding: ((_ item: GenericCollectionSectionItem<TItem>, _ cell: UCell) -> Void)?) {
//        
//        self.title = title ?? ""
//        self.cellClass = cellClass
//        self.binding = binding
//    }
//    
//    func addItem(item: TItem? = nil, itemType: Any? = nil) {
//        
//        let item = GenericCollectionSectionItem<TItem>(item: item)
//        item.itemType = itemType
//        
//        self.items.append(item)
//    }
//}

