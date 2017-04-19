//
//  Array.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 19/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        
        if let index = self.index(of: object) {
            
            self.remove(at: index)
        }
    }
}

//Protocal that copyable class should conform
protocol Copying {
    
    init(original: Self)
}

//Concrete class extension
extension Copying {
    
    func copy() -> Self {
        
        return Self.init(original: self)
    }
}

//Array extension for elements conforms the Copying protocol
extension Array where Element: Copying {
    
    func clone() -> Array {
        
        var copiedArray = Array<Element>()
        
        for element in self {
            
            copiedArray.append(element.copy())
        }
        
        return copiedArray
    }
}
