//
//  STAuthorizationError.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

enum STAuthorizationError: Error {

    case undefinedError(error: Error)

    case requiredParameters(json: [String : Any])
    
    case toManyRequests
    
    case codeNotFound
    
    
    var localizedDescription: String {
        
        switch self {
            
        case .undefinedError(let error):
            
            return error.localizedDescription
            
        case .requiredParameters(let json):
            
            if let errors = json["errors"] as? [String : Any] {
                
                return errors["message"] as? String ?? ""
            }
            
            return "Неизвестная ошибка"
            
        case .toManyRequests:
            
            return "Слишком много запросов на получение кода"
            
        case .codeNotFound:
            
            return "Не верный код"
        }
    }
}
