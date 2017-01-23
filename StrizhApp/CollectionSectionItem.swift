//
//  CollectionSectionItem.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 10/07/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class CollectionSectionItem: NSObject {

    fileprivate (set) var defaultcell: Bool = false
    
    fileprivate (set) var cellStyle: UITableViewCellStyle?
    
    fileprivate (set) var firstReusableIdentifier: String?
    
    fileprivate (set) var secondReusableIdentifier: String?
    
    
    var item: Any?
    
    var itemType: Any?
    
    var userData: Any?
    
    var validation: (() -> Bool)?
    
    var reusableIdentifier: String? {
        
        get {
            
            return swappable ? (selected ? secondReusableIdentifier : firstReusableIdentifier) : firstReusableIdentifier
        }
    }
    
    var selected = false
    
    var hasError = false
    
    var indexPath: IndexPath!
    
    var bindingAction: ((_ cell: UITableViewCell, _ item: CollectionSectionItem) -> Void)?
    
    var swappable = false
    
    var cellHeight: CGFloat?
    
    var cellClass: AnyClass?
    
    var nibClass: AnyClass?
    
    
    init(cellClass: AnyClass, item: Any?) {
        
        self.cellClass = cellClass
        self.item = item
        
        super.init()
    }
    
    init(nibClass: AnyClass, item: Any?) {
        
        self.nibClass = nibClass
        self.item = item
        
        super.init()
    }
    
    init(reusableIdentifier: String? = nil, item: Any?) {
        
        self.firstReusableIdentifier = reusableIdentifier
        self.item = item
        
        super.init()
    }
    
    init(firstReusableIdentifierOrNibName: String? = nil, secondReusableIdentifierOrNibName: String? = nil, item: Any?) {
        
        self.firstReusableIdentifier = firstReusableIdentifierOrNibName
        self.secondReusableIdentifier = secondReusableIdentifierOrNibName
        self.item = item
        self.swappable = true
        
        super.init()
    }
    
    init(reusableIdentifier: String?, cellStyle: UITableViewCellStyle, item: Any?) {
        
        self.item = item
        self.cellStyle = cellStyle
        self.defaultcell = true;
        self.firstReusableIdentifier = reusableIdentifier
        
        super.init()
    }
}
