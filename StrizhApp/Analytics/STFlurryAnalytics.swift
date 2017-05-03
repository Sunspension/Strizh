//
//  STFlurryAnalytics.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 27/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import Flurry_iOS_SDK

struct STFlurryAnalytics: PAnalytics {
    
    func logEvent(eventName: String, params: Dictionary<String, Any>? = nil, timed: Bool? = nil) {
        
        Flurry.logEvent(eventName, withParameters: params, timed: timed ?? false)
    }
    
    func endTimeEvent(eventName: String, params: Dictionary<String, Any>? = nil) {
        
        Flurry.endTimedEvent(eventName, withParameters: params)
    }
    
    func setUserId(userId: Int) {
        
        Flurry.setUserID("\(userId)")
    }
}
