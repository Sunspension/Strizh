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
    
    func writeToDB(update: Bool = true) {
        
        let realm = try! Realm()
        
        try! realm.write({
            
            realm.add(self, update: update)
        })
    }
}
