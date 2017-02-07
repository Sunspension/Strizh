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

private enum QueryParametersEnum : String {
    
    case page = "page"
    case pageSize = "page_size"
    case sortingOrder = "order"
    case conditions = "conditions"
    case filters = "filters"
    case extend = "extend"
}

enum STSocketRequestBuilder {
    
    case loadUser(id: Int)
    
    case loadFeed(page: Int, pageSize: Int)
    
    
    var request: STSocketRequest {
        
        var payLoad = [String : Any]()
        
        var query = [String : Any]()
        
        
        switch self {
            
        case .loadUser(let id):
            
            self.addToPayload(&payLoad, type: .path, value: "/api/user/\(id)")
            self.addToPayload(&payLoad, type: .method, value: "GET")
            
            break
            
        case .loadFeed(let page, let pageSize):
            
            // query
            self.addToQuery(&query, type: .page, value: page)
            self.addToQuery(&query, type: .pageSize, value: pageSize)
            self.addToQuery(&query, type: .sortingOrder, value: ["id" : "desc"])
            self.addToQuery(&query, type: .filters, value: ["feed" : "true"])
            self.addToQuery(&query, type: .extend, value: "user")
//            self.addToQuery(&query, type: .conditions, value: ["id" : [">" : 0]])
            
            // payload
            self.addToPayload(&payLoad, type: .path, value: "/api/post")
            self.addToPayload(&payLoad, type: .method, value: "GET")
            self.addToPayload(&payLoad, type: .query, value: query)
            
            break
        }
     
        let requestId = UUID().uuidString
        self.addToPayload(&payLoad, type: .requestId, value: requestId)
        
        return STSocketRequest(payLoad: payLoad, requestId: requestId)
    }
    
    private func addToQuery(_ params: inout [String : Any], type: QueryParametersEnum, value: Any) {
        
        params[type.rawValue] = value
    }
    
    private func addToPayload(_ params: inout [String : Any], type: PayLoadParametersEnum, value: Any) {
        
        params[type.rawValue] = value
    }
}
