//
//  PAnalytics.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 27/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

let st_eIntro = "pIntro"
let st_eAuth = "pAuth"
let st_ePostDetails = "pPostDetails"
let st_eCode = "bGetCode"
let st_eSkipIntro = "bSkipIntro"
let st_eGetCodeAgain = "bGetCodeAgain"
let st_eWelcomeProfile = "pWelcomeProfile"
let st_eSaveWelcomeProfile = "bSaveWelcomeProfile"
let st_eFeed = "pFeed"
let st_eFeedScroll = "aFeedScroll"
let st_eFeedRefresh = "aFeedRefresh"
let st_eFeedSearch = "aFeedSearch"
let st_eFeedFilter = "aFeedFilter"
let st_eFavoriteAdd = "aFavoriteAdd"
let st_eFavoriteRemove = "aFavoriteRemove"

protocol PAnalytics {
    
    func logEvent(eventName: String, params: Dictionary<String, Any>?, timed: Bool?)
    
    func endTimeEvent(eventName: String, params: Dictionary<String, Any>?)
    
    func setUserId(userId: Int)
}
