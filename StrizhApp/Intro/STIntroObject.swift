//
//  STIntroObject.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/05/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

struct STIntroObject: Equatable {
    
    fileprivate var id = UUID()
    
    var imageName = ""
    
    var title = ""
    
    var subtitle = ""
    
    var nextTitle = ""
    
    public static func == (lhs: STIntroObject, rhs: STIntroObject) -> Bool {
        
        return lhs.id == rhs.id
    }
}
