//
//  ValidationEnum.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

enum ValidationResult {
    
    case onSuccess
    
    case onError(errorMessage: String)
    
    var valid: Bool {
        
        switch self {
            
        case .onSuccess:
            
            return true
            
        default:
            return false
        }
    }
    
    var errorDescription: String? {
        
        switch self {
            
        case .onError(let errorMessage):
            
            return errorMessage
            
        default:
            return nil
        }
    }
}
