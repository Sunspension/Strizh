//
//  STRealmDB.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RealmSwift

struct STRealmConfiguration: PDBConfiguration {
    
    let realm = try! Realm()
    
    func configure() {
        
        var config = Realm.Configuration()
        config.schemaVersion = 1
        config.migrationBlock = { (migration: Migration, oldSchemaVersion: UInt64) in
            
            if oldSchemaVersion < 1 {
                
            }
        }
        
        Realm.Configuration.defaultConfiguration = config;
    }
}