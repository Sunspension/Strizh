//
//  STSocketPayLoad.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 03/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

private enum PayLoadParametersEnum : String {
    
    case path = "path"
    case method = "method"
    case body = "body_params"
    case query = "query_params"
    case requestId = "request_id"
}

enum STSocketRequestBuilder {
    
    case loadUser(id: Int)
    
    
    var request: STSocketRequest {
        
        var payLoad = [String : Any]()
        
        switch self {
            
        case .loadUser(let id):
            
            self.add(&payLoad, type: .path, value: "/api/user/\(id)")
            self.add(&payLoad, type: .method, value: "GET")
        }
     
        let requestId = UUID().uuidString
        self.add(&payLoad, type: .requestId, value: requestId)
        
        return STSocketRequest(payLoad: payLoad, requestId: requestId)
    }
    
    private func add(_ params: inout [String : Any], type: PayLoadParametersEnum, value: Any) {
        
        params[type.rawValue] = value
    }
}
