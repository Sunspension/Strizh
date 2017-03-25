//
//  AppSettings.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 23/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import RealmSwift
import AlamofireImage
import Dip

let kSTLastSessionPhone = "kSTLastSessionPhone"
let kSTDeviceToken = "kSTDeviceToken"
let kUserUpdatedNotification = "kUserUpdatedNotification"
let kItemFavoriteNotification = "kItemFavoriteNotification"
let kPostAddedToArchiveNotification = "kPostAddedToArchiveNotification"
let kPostDeleteFromDetailsNotification = "kPostDeleteFromDetailsNotification"
let kPostCreatedNotification = "kPostCreatedNotification"
let kPostDeleteNotification = "kPostDeleteNotification"

struct AppSettings {
    
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    var dbConfig: PDBConfiguration
    
    var api: PRemoteServerApi
    
    var type = "code"
    
    var deviceType = "ios"
    
    let systemVersion = UIDevice.current.systemVersion;
    
    let bundleId = Bundle.main.bundleIdentifier
    
    let applicationVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var feedFilter: STFeedFilter {
        
        var filter = STFeedFilter.objects(by: STFeedFilter.self).first
        
        if filter == nil {
            
            filter = STFeedFilter()
            filter!.writeToDB()
        }
        
        return filter!
    }
    
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
    
    var defaultFormatter: DateFormatter {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
    
    lazy var imageDownloader: ImageDownloader = {
        
        return ImageDownloader()
        
    }()
    
    lazy var dependencyContainer: DependencyContainer = {
        
        return DependencyContainer()
        
    }()
    
    init(dbConfig: PDBConfiguration, serverApi: PRemoteServerApi) {
        
        self.dbConfig = dbConfig
        self.api = serverApi
    }
}
