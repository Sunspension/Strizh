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
let kPostUpdateDialogNotification = "kPostUpdateDialogNotification"
let kReceiveMessageNotification = "kReceiveMessageNotification"
let kReceiveDialogBadgeNotification = "kReceiveDialogBadgeNotification"
let kIntroHasEndedNotification = "kIntroHasEndedNotification"
let kNeedIntro = "kNeedIntro"

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
            
            let all = STFilterItem()
            all.itemName = "dialog_filter_page_all_text"
            all.itemIconName = "icon-all-deals"
            all.isSelected = true
            all.id = 1
            
            let offer = STFilterItem()
            offer.itemName = "feed_filter_page_offer_text"
            offer.itemIconName = "icon-offer"
            offer.isSelected = false
            offer.id = 2
            
            let search = STFilterItem()
            search.itemName = "feed_filter_page_search_text"
            search.itemIconName = "icon-search"
            search.isSelected = false
            search.id = 3
            
            filter!.filterItems.append(objectsIn: [all, offer, search])
            filter!.writeToDB()
        }
        
        return filter!
    }
    
    var dialogFilter: STDialogFilter {
        
        var filter = STDialogFilter.objects(by: STDialogFilter.self).first
        
        if filter == nil {
            
            filter = STDialogFilter()
            
            let all = STFilterItem()
            all.itemName = "dialog_filter_page_all_text"
            all.itemIconName = "icon-all-deals"
            all.isSelected = true
            all.id = 4
            
            let incoming = STFilterItem()
            incoming.itemName = "dialog_filter_page_incoming_text"
            incoming.itemIconName = "icon-incoming-deals"
            incoming.isSelected = false
            incoming.id = 5
            
            let outgoing = STFilterItem()
            outgoing.itemName = "dialog_filter_page_outgoing_text"
            outgoing.itemIconName = "icon-outgoing-deals"
            outgoing.isSelected = false
            outgoing.id = 6
            
            filter!.filterItems.append(objectsIn: [all, incoming, outgoing])
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
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
    
    lazy var imageDownloader: ImageDownloader = {
        
        return ImageDownloader()
        
    }()
    
    lazy var dependencyContainer: DependencyContainer = {
        
        return DependencyContainer()
        
    }()
    
    lazy var fbAccountKit: AKFAccountKit = {
        
        return AKFAccountKit(responseType: AKFResponseType.authorizationCode)
    }()
    
    init(dbConfig: PDBConfiguration, serverApi: PRemoteServerApi) {
        
        self.dbConfig = dbConfig
        self.api = serverApi
        
        self.appearanceSetup()
    }
    
    fileprivate func appearanceSetup() {
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.stPaleGreyTwo
    }
}
