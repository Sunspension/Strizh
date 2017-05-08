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
let st_eFavoritePostTab = "bFavoritePostTab"
let st_eFeedPostTab = "bFeedPostTab"
let st_eStartDialog = "bStartDialog"
let st_ePostDialogList = "bPostDialogList"
let st_eContacts = "pContacts"
let st_eContactSearch = "aContactSearch"
let st_eContactInvite = "aContactInvite"
let st_eNewPostStep1 = "pNewPostStep1"
let st_eCloseNewPost = "aCloseNewPost"
let st_eNewPostStep2 = "pNewPostStep2"
let st_eAddPostImage = "bAddPostImage"
let st_eFinishAddPostImage = "aFinishAddPostImage"
let st_eAddPostFile = "bAddPostFile"
let st_eBackNewPostStep1 = "bBackNewPostStep1"
let st_eNewPostStep3 = "pNewPostStep3"
let st_eNewPostContactSearch = "aNewPostConstactSearch"
let st_eNewPostContactSelect = "aNewPostContactSelect"
let st_eNewPostCreateFinish = "aNewPostCreateFinish"
let st_eDialogList = "pDialogList"
let st_eDialogListSearch = "aDialogListSearch"
let st_eDialogListScroll = "aDialogListScroll"
let st_eDialogListRefresh = "aDialogListRefresh"
let st_eDialog = "pDialog"
let st_eSendMessage = "bSendMessage"
let st_eDialogScroll = "aDialogScroll"
let st_eDialogReceiveMessage = "aDialogReceiveMessage"
let st_eBackToDialogList = "aBackToDialogList"
let st_eMyProfile = "pMyProfile"
let st_ePostScroll = "aPostScroll"
let st_ePostRefresh = "aPostRefresh"
let st_ePostDelete = "bPostDelete"
let st_ePostEdit = "bPostEdit"
let st_eProfileEdit = "bProfileEdit"
let st_eApplicationSettings = "bApplicationSettings"
let st_eLogout = "bLogout"
let st_eSetAvatar = "aSetAvatar"
let st_eSaveProfile = "bSaveProfile"

protocol PAnalytics {
    
    func logEvent(eventName: String, params: Dictionary<String, Any>?, timed: Bool?)
    
    func endTimeEvent(eventName: String, params: Dictionary<String, Any>?)
    
    func setUserId(userId: Int)
}
