//
//  STImageUploadError.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 30/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

enum STImageUploadError: Error {
    
    case encodingError(message: String)
    
    case invalidJSON(json: [String : Any])
    
    
    var localizedDescription: String {
        
        switch self {
            
        case .encodingError(let message):
            
            return message
            
        case .invalidJSON(let json):
            
            if let errors = json["errors"] as? [String : Any] {
                
                return errors["message"] as? String ?? "Неизвестная ошибка"
            }
            
            return "Неизвестная ошибка"
        }
    }
}
