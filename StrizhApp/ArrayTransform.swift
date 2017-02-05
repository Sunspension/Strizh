//
//  ArrayTransform.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 04/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class ArrayTransform<T:RealmSwift.Object> : TransformType where T:Mappable {
    
    typealias Object = List<T>
    typealias JSON = Array<Any>
    
    func transformFromJSON(_ value: Any?) -> Object? {
        
        let realmList = List<T>()
        
        if let jsonArray = value as? Array<Any> {
        
            for item in jsonArray {
            
                if let realmModel = Mapper<T>().map(JSONObject: item) {
                
                    realmList.append(realmModel)
                }
            }
        }
        
        return realmList
    }
    
    func transformToJSON(_ value: List<T>?) -> JSON? {
        
        guard let realmList = value, realmList.count > 0 else { return nil }
        
        var resultArray = Array<T>()
        
        for entry in realmList {
            
            resultArray.append(entry)
        }
        
        return resultArray
    }
}
