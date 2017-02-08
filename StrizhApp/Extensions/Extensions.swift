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
        
        return AppDelegate.appSettings.api
    }
    
    var appSettings: AppSettings {
        
        return AppDelegate.appSettings
    }
    
    var appDelegate: AppDelegate? {
        
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    func setCustomBackButton() {
        
        let back = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        back.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = back
    }
    
    func showOkAlert(title: String?, message: String?) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showOkCancellAlert(title: String?, message: String?,
                            okTitle: String?, okAction: ((UIAlertAction) -> Void)?,
                            cancelTitle: String?, cancelAction: ((UIAlertAction) -> Void)? ) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: okTitle ?? "Ok", style: .default, handler: okAction)
        
        let cancelAction = UIAlertAction(title: cancelTitle ?? "Cancel", style: .cancel, handler: cancelAction)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showError(error: Error) {
        
        showOkAlert(title: "Ошибка", message: error.localizedDescription)
    }
    
    func changeRootViewController(_ viewController: UIViewController) {
        
        self.appDelegate?.changeRootViewController(viewController)
    }
}

extension UIView {
    
    func makeCircular() {
        
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.clipsToBounds = true
    }
}

extension UITableView {
    
    func register(cellClass: AnyClass) {
        
        self.register(cellClass, forCellReuseIdentifier: String(describing: cellClass.self))
    }
    
    func register(cell: AnyClass) {
        
        self.register(UINib(nibName: String(describing: cell), bundle: nil), forCellReuseIdentifier: String(describing: cell))
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
    
    class var stWhite20Opacity: UIColor {
        
        return UIColor(white: 1, alpha: 0.2)
    }
    
    class var stWhite70Opacity: UIColor {
        
        return UIColor(white: 1, alpha: 0.7)
    }
}


extension Date {

    var mediumLocalizedFormat: String {
        
        return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
    }
    
    var shortLocalizedFormat: String {
        
        return DateFormatter.localizedString(from: self, dateStyle: .short, timeStyle: .none)
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
            
            var min = ""
            
            switch minutes {
                
            case 1, 21, 31, 41, 51:
                
                min = "минута"
                break
                
            case 2, 3, 4, 22, 23, 24, 32, 33, 34, 42, 43, 44, 52, 53, 54:
                
                min = "минуты"
                break
                
            default:
                min = "минут"
            }
            
            result = "\(minutes)" + " " + min
        }
        
        if let hours = componets.hour {
            
            var h = ""
            
            switch hours {
                
            case 1, 21:
                
                h = "час"
                break
                
            case 2, 3, 4, 22, 23:
                
                h = "часа"
                break
                
            default:
                h = "часов"
            }
            
            result += "\(hours)" + " " + h + " " + result
        }

        return result
    }
}
