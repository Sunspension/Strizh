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

extension UITableView {
    
    func register(cellClass: AnyClass) {
        
        self.register(cellClass, forCellReuseIdentifier: String(describing: cellClass.self))
    }
    
    func register(nibClass: AnyClass) {
        
        self.register(UINib(nibName: String(describing: nibClass), bundle: nil), forCellReuseIdentifier: String(describing: nibClass))
    }
}

extension UIColor {
    
    class var stBrightBlue: UIColor {
        
        return UIColor(red: 0.0, green: 114.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    
    class var stLightNavy: UIColor {
        
        return UIColor(red: 15.0 / 255.0, green: 77.0 / 255.0, blue: 158.0 / 255.0, alpha: 1.0)
    }
    
    class var stMango: UIColor {
        
        return UIColor(red: 251.0 / 255.0, green: 183.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
    }
    
    class var stCoolGrey: UIColor {
        
        return UIColor(red: 148.0 / 255.0, green: 148.0 / 255.0, blue: 149.0 / 255.0, alpha: 1.0)
    }
    
    class var stDarkMint: UIColor {
        
        return UIColor(red: 84.0 / 255.0, green: 207.0 / 255.0, blue: 124.0 / 255.0, alpha: 1.0)
    }
    
    class var stIris: UIColor {
        
        return UIColor(red: 118.0 / 255.0, green: 105.0 / 255.0, blue: 192.0 / 255.0, alpha: 1.0)
    }
    
    class var stLightBlueGrey: UIColor {
        
        return UIColor(red: 211.0 / 255.0, green: 218.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0)
    }
    
    class var stWhite: UIColor { 
        
        return UIColor(white: 228.0 / 255.0, alpha: 1.0)
    }
}

