//
//  AppSettings.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 23/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RealmSwift

let deviceType = "ios"
let kSTLastSessionPhone = "kSTLastSessionPhone"
let kSTDeviceToken = "kSTDeviceToken"

struct AppSettings {
    
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    var dbConfig: PDBConfiguration
    
    var api: PRemoteServerApi
    
    var lastSessionPhoneNumber: String? {
        
        get {
            
            let defaults = UserDefaults.standard
            return defaults.object(forKey: kSTLastSessionPhone) as? String
        }
        
        set (newValue) {
            
            let defauls = UserDefaults.standard
            defauls.setValue(newValue, forKey: kSTLastSessionPhone)
            defauls.synchronize()
        }
    }
    
    var deviceToken: String? {
        
        get {
            
            let defaults = UserDefaults.standard
            return defaults.object(forKey: kSTDeviceToken) as? String
        }
        
        set(newValue) {
            
            let defauls = UserDefaults.standard
            defauls.setValue(newValue, forKey: kSTDeviceToken)
            defauls.synchronize()
        }
    }
    
    init(dbConfig: PDBConfiguration, serverApi: PRemoteServerApi) {
        
        self.dbConfig = dbConfig
        self.api = serverApi
    }
}
