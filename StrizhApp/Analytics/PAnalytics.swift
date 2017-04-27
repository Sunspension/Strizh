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


protocol PAnalytics {
    
    func logEvent(eventName: String, params: Dictionary<String, Any>?, timed: Bool?)
    
    func endTimeEvent(eventName: String, params: Dictionary<String, Any>?)
}
