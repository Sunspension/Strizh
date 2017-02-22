//
//  SHSPhoneComponentExtensions.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 20/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import SHSPhoneComponent

extension SHSPhoneNumberFormatter {
    
    func formattedPhone(phone: String) -> String? {
        
        if let dictionary = self.values(for: phone) as? [String : Any] {
            
            return dictionary["text"] as! String?
        }
        
        return nil
    }
}
