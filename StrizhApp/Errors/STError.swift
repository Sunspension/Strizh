//
//  STError.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

enum STError: Error {

    case anyError(error: Error)
    
    
    var localizedDescription: String {
        
        switch self {
            
        case .anyError(let error):
            
            return error.localizedDescription
        }
    }
}
