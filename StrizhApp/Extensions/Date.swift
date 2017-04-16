//
//  Date.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 31/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

extension Date {
    
    var mediumLocalizedFormat: String {
        
        return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
    }
    
    var shortLocalizedFormat: String {
        
        return DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .none)
    }
    
    var defaultFormat: String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.string(from: self)
    }
    
    var dayMonthFormat: String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"
        
        return formatter.string(from: self)
    }
    
    var time: String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: self)
    }
    
    var day: Int {
        
        return Calendar.current.component(.day, from: self)
    }
    
    var month: Int {
        
        return Calendar.current.component(.month, from: self)
    }
    
    var year: Int {
        
        return Calendar.current.component(.year, from: self)
    }
    
    func isTheSameDay(date: Date) -> Bool {
        
        if self.year == date.year
            && self.month == date.month
            && self.day == date.day {
            
            return true
        }
        
        return false
    }
    
    func elapsedInterval() -> String {
        
        let componets = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())
        
        guard componets.year == nil || componets.month == nil else {
            
            return mediumLocalizedFormat
        }
        
        if let days = componets.day {
            
            switch days {
                
            case 1:
                
                return "вчера"
                
            case 2:
                
                return "позавчера"
                
            default:
                
                return mediumLocalizedFormat
            }
        }
        
        var result = "только что"
        
        if let minutes = componets.minute {
            
            let ending = minutes.ending(yabloko: "минута", yabloka: "минуты", yablok: "минут")
            result = "\(minutes)" + " " + ending
        }
        
        if let hours = componets.hour {
            
            let ending = hours.ending(yabloko: "час", yabloka: "часа", yablok: "часов")
            result += "\(hours)" + " " + ending + " " + result
        }
        
        return result
    }
}
