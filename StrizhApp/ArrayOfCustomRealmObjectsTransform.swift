//
//  ArrayOfCustomRealmObjectsTransform.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 04/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class ArrayOfCustomRealmObjectsTransform<T: RealmSwift.Object>: TransformType where T: RealmCustomObject {
    
    typealias Object = List<T>
    
    typealias JSON = Array<Any>
    
    
    func transformFromJSON(_ value: Any?) -> Object? {
        
        let list = List<T>()
        
        if let jsonArray = value as? Array<Any> {
            
            let objects = jsonArray.flatMap({ item -> T? in
                
                let t = T()
                t["value"] = item
                return t
            })
            
            list.append(objectsIn: objects)
        }
        
        return list
    }
    
    func transformToJSON(_ value: List<T>?) -> JSON? {
        
        guard let realmList = value, realmList.count > 0 else { return nil }
        
        var resultArray = Array<T.ObjectType>()
        
        for entry in realmList {
            
            resultArray.append(entry["value"] as! T.ObjectType)
        }
        
        return resultArray
    }
}
