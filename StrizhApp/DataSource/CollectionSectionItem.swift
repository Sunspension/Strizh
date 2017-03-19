//
//  CollectionSectionItem.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

typealias BindingAction = ((_ cell: UITableViewCell, _ item: CollectionSectionItem) -> Void)


enum ValidationResult {
    
    case onSuccess
    
    case onError(errorMessage: String)
    
    var valid: Bool {
        
        switch self {
            
        case .onSuccess:
            
            return true
            
        default:
            return false
        }
    }
    
    var errorDescription: String? {
        
        switch self {
            
        case .onError(let errorMessage):
            
            return errorMessage
            
        default:
            return nil
        }
    }
}


class CollectionSectionItem: Equatable {
    
    let id = UUID()
    
    var item: Any?
    
    var itemType: Any?
    
    var userData: Any?
    
    var validation: (() -> ValidationResult)?
    
    var hasError = false
    
    var selected = false
    
    var allowAction = true
    
    var indexPath: IndexPath!
    
    var bindingAction: BindingAction?
    
    var cellHeight: CGFloat?
    
    var cellClass: AnyClass?
    
    var cellStyle: UITableViewCellStyle?
    
    
    public static func ==(lhs: CollectionSectionItem, rhs: CollectionSectionItem) -> Bool {
        
        return lhs.id == rhs.id
    }
    
    init(cellClass: AnyClass,
         item: Any? = nil,
         itemType: Any? = nil,
         bindingAction: BindingAction? = nil) {
        
        self.cellClass = cellClass
        self.item = item
        self.itemType = itemType
        self.bindingAction = bindingAction
    }
    
    init(cellStyle: UITableViewCellStyle,
         item: Any? = nil,
         itemType: Any? = nil,
         bindingAction: BindingAction? = nil) {
        
        self.cellStyle = cellStyle
        self.item = item
        self.itemType = itemType
        self.bindingAction = bindingAction
    }
}
