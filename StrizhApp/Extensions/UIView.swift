//
//  View.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 19/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func makeCircular() {
        
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.clipsToBounds = true
    }
    
    static func loadFromNib<T: UIView>(view: T.Type) -> T? {
        
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: self, options: nil)?.first as? T
    }
    
    func queryResizeString() -> String {
        
        let width = Int(self.bounds.width * UIScreen.main.scale)
        let height = Int(self.bounds.height * UIScreen.main.scale)
        
        return "?resize=w[\(width)]h[\(height)]q[100]e[true]"
    }
}
