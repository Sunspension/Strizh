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
}
