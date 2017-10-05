//
//  Strings.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 19/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    var localized: String {
        
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    
    func localizedWithComment(_ comment: String) -> String {
        
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
    
    
    func matchesForRegexInText(_ pattern: String!) -> [String]? {
        
        do {
            
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let result = regex.matches(in: self, options: [], range: NSMakeRange(0, self.characters.count))
            return result.map({ (self as NSString).substring(with: $0.range)})
        }
        catch let error as NSError {
            
            print(error.localizedDescription)
            return nil
        }
    }
    
    func string(with color: UIColor) -> NSAttributedString {
        
        return NSAttributedString(string: self, attributes: [ NSAttributedStringKey.foregroundColor : color])
    }
}
