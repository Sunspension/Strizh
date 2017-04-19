//
//  Int.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 19/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

extension Int {
    
    func ending(yabloko: String, yabloka: String, yablok: String) -> String {
        
        let number = self % 100
        
        if number >= 11 && number <= 19 {
            
            return yablok
        }
        
        switch number % 10 {
            
        case 1:
            return yabloko
            
        case 2...4:
            return yabloka
            
        default:
            return yablok
        }
    }
}
