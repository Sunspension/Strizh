//
//  CollectionSection.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class CollectionSection: NSObject {
    
    var title: String?
    
    var items: [CollectionSectionItem] = []
    
    var selectedItems: [CollectionSectionItem] = []
    
    var sectionType: Any?
    
    var selected = false
    
    
    init(title: String? = "") {
        
        self.title = title;
    }
    
    func initializeItem(reusableIdentifier identifier: String? = nil,
                        cellStyle: UITableViewCellStyle,
                        item: Any? = nil,
                        itemType: Any? = nil,
                        bindingAction: @escaping (_ cell:UITableViewCell, _ item: CollectionSectionItem) -> Void) {
        
        let item = CollectionSectionItem(reusableIdentifier: identifier, cellStyle: cellStyle, item: item)
        item.bindingAction = bindingAction
        item.itemType = itemType
        self.items.append(item)
    }
    
    func initializeItem(reusableIdentifierOrNibName identifier: String,
                        item: Any? = nil,
                        itemType: Any? = nil,
                        bindingAction: @escaping (_ cell:UITableViewCell, _ item: CollectionSectionItem) -> Void) {
        
        let item = CollectionSectionItem(reusableIdentifier: identifier, item: item)
        item.itemType = itemType
        item.bindingAction = bindingAction
        self.items.append(item)
    }
    
    func initializeItem(cellClass: AnyClass,
                        item: Any? = nil,
                        itemType: Any? = nil,
                        bindingAction: @escaping (_ cell:UITableViewCell, _ item: CollectionSectionItem) -> Void) {
        
        let item = CollectionSectionItem(cellClass: cellClass, item: item)
        item.itemType = itemType
        item.bindingAction = bindingAction
        self.items.append(item)
    }
    
    func initializeItem(nibClass: AnyClass,
                        item: Any? = nil,
                        itemType: Any? = nil,
                        bindingAction: @escaping (_ cell:UITableViewCell, _ item: CollectionSectionItem) -> Void) {
        
        let item = CollectionSectionItem(nibClass: nibClass, item: item)
        item.itemType = itemType
        item.bindingAction = bindingAction
        self.items.append(item)
    }
    
    func initializeSwappableItem(firstIdentifierOrNibName firstIdentifier: String,
                                 secondIdentifierOrNibName secondIdentifier: String,
                                 item: Any? = nil,
                                 itemType: Any? = nil,
                                 bindingAction: @escaping (_ cell:UITableViewCell, _ item: CollectionSectionItem) -> Void) {
        
        let item = CollectionSectionItem(firstReusableIdentifierOrNibName: firstIdentifier,
                                         secondReusableIdentifierOrNibName: secondIdentifier, item: item)
        item.bindingAction = bindingAction
        item.itemType = itemType
        self.items.append(item)
    }
}

