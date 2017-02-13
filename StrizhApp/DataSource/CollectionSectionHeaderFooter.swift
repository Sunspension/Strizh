//
//  CollectionSectionHeaderFooter.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 13/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

typealias BindingHeaderFooterAction = ((_ cell: UITableViewHeaderFooterView, _ item: CollectionSectionHeaderFooter) -> Void)

class CollectionSectionHeaderFooter {

    var item: Any?
    
    var cellHeight: CGFloat?
    
    var bindingAction: BindingHeaderFooterAction?
    
    var headerClass: AnyClass?
}
