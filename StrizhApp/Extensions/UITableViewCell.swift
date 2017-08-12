//
//  UITableViewCell.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 09/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

protocol ReusableView: class {
    
    static var reuseIdentifier: String {get}
}

extension ReusableView {
    
    static var reuseIdentifier: String {
        
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView {}

extension UITableViewHeaderFooterView : ReusableView {}
