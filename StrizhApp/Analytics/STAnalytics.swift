//
//  STAnalytics.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 27/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

struct STAnalytics {
    
    fileprivate var analyticsContainer: [PAnalytics]
    
    
    init(analytics: [PAnalytics]) {
        
        self.analyticsContainer = analytics
    }
    
    func logEvent(eventName: String, params: Dictionary<String, Any>? = nil, timed: Bool? = nil) {
    
        for analytics in self.analyticsContainer {
            
            analytics.logEvent(eventName: eventName, params: params, timed: timed)
        }
    }
    
    func endTimeEvent(eventName: String, params: Dictionary<String, Any>? = nil) {
        
        for analytics in self.analyticsContainer {
            
            analytics.endTimeEvent(eventName: eventName, params: params)
        }
    }
    
    func setUserId(userId: Int) {
        
        for analytics in self.analyticsContainer {
            
            analytics.setUserId(userId: userId)
        }
    }
}
