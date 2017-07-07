//
//  NSMutableAttributedString.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 07/07/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    
    func addAttributes(_ attrs: [String : Any], for text: String) {
        
        let range = self.mutableString.range(of: text, options: .caseInsensitive)
        
        if range.location == NSNotFound {
            
            return
        }
        
        self.addAttributes(attrs, range: range)
    }
}
