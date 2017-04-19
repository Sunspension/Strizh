//
//  UICollectionView.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 19/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func register(cellClass: AnyClass) {
        
        self.register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass.self))
    }
    
    func register(nib: AnyClass) {
        
        self.register(UINib(nibName: String(describing: nib), bundle: nil), forCellWithReuseIdentifier: String(describing: nib))
    }
}
