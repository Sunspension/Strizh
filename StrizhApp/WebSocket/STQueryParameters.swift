//
//  STQueryParameters.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 03/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

class STQueryParameters {
    
    var params: [String : Any] = [:]
    
    @discardableResult
    func add<T>(type: STQueryParametersEnum, params: T) -> STQueryParameters {
        
        self.params[type.describing] = params
        return self
    }
}
