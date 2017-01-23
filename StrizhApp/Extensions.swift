//
//  Extensions.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 23/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    var api: PRemoteServerApi {
        
        get {
            
            return AppDelegate.appSettings.api
        }
    }
}
