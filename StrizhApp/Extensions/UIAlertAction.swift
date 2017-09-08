//
//  UIAlertAction.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 18/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

extension UIAlertAction {
    
    @objc class var cancel: UIAlertAction {
        
        return UIAlertAction(title: "action_cancel".localized, style: .cancel, handler: nil)
    }
    
    @objc class func defaultAction(title: String, handler: @escaping (UIAlertAction) -> Void) -> UIAlertAction {
        
        return UIAlertAction(title: title, style: .default, handler: handler)
    }
    
    @objc class func destructiveAction(title: String, handler: @escaping (UIAlertAction) -> Void) -> UIAlertAction {
        
        return UIAlertAction(title: title, style: .destructive, handler: handler)
    }
}
