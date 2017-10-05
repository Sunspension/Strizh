//
//  CountdownTimer.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 02/11/2016.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

class CountdownTimer: NSObject {

    fileprivate var timer: Timer?
    
    fileprivate var startDate: Date?
    
    fileprivate var callBack: (String?) -> Void
    
    fileprivate var seconds: TimeInterval
    
    var preStartSetup: (() -> Void)?
    
    var dateFormatter: DateFormatter?
    
    
    init(seconds: TimeInterval, callBack: @escaping (_ time: String?) -> Void) {
        
        self.callBack = callBack
        self.seconds = seconds
        super.init()
    }
    
    func stopTimer() {
        
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func startTimer() {
        
        self.preStartSetup?()
        
        self.startDate = Date()
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5,
                                          target: self,
                                          selector: #selector(self.updateTimer),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    @objc func updateTimer() {
        
        let now = Date()
        
        let timeInterval = now.timeIntervalSince(self.startDate!)
        
        if Int(timeInterval) >= Int(self.seconds) {
            
            self.stopTimer()
            self.callBack(nil)
            return
        }
        
        let intervalCountDown = self.seconds - timeInterval
        let timerDate = Date(timeIntervalSince1970: intervalCountDown)
        
        if dateFormatter == nil {
            
            dateFormatter = DateFormatter()
            dateFormatter!.dateFormat = "mm:ss"
            dateFormatter!.timeZone = TimeZone(secondsFromGMT: 0)
        }
        
        self.callBack(dateFormatter!.string(from: timerDate))
    }
}
