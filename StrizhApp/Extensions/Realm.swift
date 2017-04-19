//
//  RealmExtensions.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 27/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmCustomObject {
    
    associatedtype ObjectType
    
    var value: ObjectType { get set }
}

extension Object {
    
    static let realm = try! Realm()
    
    func writeToDB(_ update: Bool = true) {
        
        try! Object.realm.write({
            
            Object.realm.add(self, update: update)
        })
    }
    
    static func objects<T: Object>(by: T.Type) -> [T] {
        
        return Array(realm.objects(T.self))
    }
    
    static func object<T: Object>(by: T.Type) -> T? {
        
        return realm.object(ofType: T.self, forPrimaryKey: T.primaryKey())
    }
}
