//
//  STRealmDB.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RealmSwift

class STRealmConfiguration: PDBConfiguration {
    
    lazy var realm: Realm = {
        
        return try! Realm()
    }()
    
    func configure() {
        
        var config = Realm.Configuration()
        config.schemaVersion = 19
        
        config.migrationBlock = { (migration: Migration, oldSchemaVersion: UInt64) in
            
            if oldSchemaVersion < 17 {
                
                migration.enumerateObjects(ofType: STUser.className(), { (oldObject, newObject) in
                    
                    newObject?["notificationSettings"] = STUserNotificationSettings()
                })
            }
        }
        
        Realm.Configuration.defaultConfiguration = config;
    }
    
    func onLogout() {
        
      try! realm.write {
            
           realm.deleteAll()
        }
    }
}
