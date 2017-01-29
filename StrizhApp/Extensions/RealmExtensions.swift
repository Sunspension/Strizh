//
//  RealmExtensions.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 27/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RealmSwift

protocol AppDBObject {
    
    func writeToDB(update: Bool)
}


extension Object: AppDBObject {
    
    static let realm = try! Realm()
    
    func writeToDB(update: Bool = true) {
        
        try! Object.realm.write({
            
            Object.realm.add(self, update: update)
        })
    }
    
    static func objects<T: Object>(by: T.Type) -> Results<T> {
        
        return realm.objects(T.self)
    }
}
