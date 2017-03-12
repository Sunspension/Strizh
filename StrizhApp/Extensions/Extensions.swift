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
    
    var storyBoard: UIStoryboard {
        
        return appSettings.storyBoard
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
    
    static func loadFromNib<T: UIView>(view: T.Type) -> T? {
        
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: self, options: nil)?.first as? T
    }
}

extension UITableView {
    
    func register(cellClass: AnyClass) {
        
        self.register(cellClass, forCellReuseIdentifier: String(describing: cellClass.self))
    }
    
    func register(nibClass: AnyClass) {
        
        self.register(UINib(nibName: String(describing: nibClass), bundle: nil), forCellReuseIdentifier: String(describing: nibClass))
    }
    
    func register(headerFooterCellClass: AnyClass) {
        
        self.register(headerFooterCellClass, forHeaderFooterViewReuseIdentifier: String(describing: headerFooterCellClass))
    }
    
    func register(headerFooterNibClass: AnyClass) {
        
        self.register(UINib(nibName: String(describing: headerFooterNibClass), bundle: nil),
                      forHeaderFooterViewReuseIdentifier: String(describing: headerFooterNibClass))
    }
    
    func showBusy() {
        
        // Sometimes it possible to call this method from not UI thread, for example when you asking access to Address Book
        DispatchQueue.main.async {
            
            let busy = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            busy.frame = CGRect(x: 0, y: 0, width: 300, height: 60)
            busy.hidesWhenStopped = true
            busy.startAnimating()
            self.tableFooterView = busy
        }
    }
    
    func hideBusy() {
        
        DispatchQueue.main.async {
            
            self.tableFooterView = UIView()
        }
    }
}

extension UICollectionView {
    
    func register(cellClass: AnyClass) {
        
        self.register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass.self))
    }
    
    func register(nib: AnyClass) {
        
        self.register(UINib(nibName: String(describing: nib), bundle: nil), forCellWithReuseIdentifier: String(describing: nib))
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
    
    class var stGreyblue: UIColor {
        
        return UIColor(red: 124.0 / 255.0, green: 152.0 / 255.0, blue: 191.0 / 255.0, alpha: 1.0)
    }
    
    class var stGreyishBrown: UIColor { 
        
        return UIColor(white: 74.0 / 255.0, alpha: 1.0)
    }
    
    class var stBrick: UIColor {
     
        return UIColor(red: 194.0 / 255.0, green: 41.0 / 255.0, blue: 41.0 / 255.0, alpha: 1.0)
    }
    
    class var stSlateGrey: UIColor {
     
        return UIColor(red: 88.0 / 255.0, green: 89.0 / 255.0, blue: 91.0 / 255.0, alpha: 1.0)
    }
    
    class var stPinkishGrey: UIColor {
        
        return UIColor(white: 201.0 / 255.0, alpha: 1.0)
    }
    
    class var stPinkishGreyTwo: UIColor {

        return UIColor(white: 196.0 / 255.0, alpha: 1.0)
    }

    class var stWhiteTwo: UIColor {
     
        return UIColor(white: 231.0 / 255.0, alpha: 1.0)
    }
    
    class var stSteelGrey: UIColor {
     
        return UIColor(red: 113.0 / 255.0, green: 125.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0)
    }
    
    class var stWhite20Opacity: UIColor {
        
        return UIColor(white: 1, alpha: 0.2)
    }
    
    class var stWhite70Opacity: UIColor {
        
        return UIColor(white: 1, alpha: 0.7)
    }
    
    class var stCloudyBlue: UIColor {
     
        return UIColor(red: 166.0 / 255.0, green: 174.0 / 255.0, blue: 210.0 / 255.0, alpha: 0.9)
    }
    
    class var stBrownish: UIColor {
     
        return UIColor(red: 161.0 / 255.0, green: 101.0 / 255.0, blue: 101.0 / 255.0, alpha: 0.9)
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

extension Int {
    
    func ending(yabloko: String, yabloka: String, yablok: String) -> String {
    
        let number = self % 100
        
        if number >= 11 && number <= 19 {
            
            return yablok
        }
        
        switch number % 10 {
            
        case 1:
            return yabloko
            
        case 2...4:
            return yabloka
            
        default:
            return yablok
        }
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        
        if let index = self.index(of: object) {
            
            self.remove(at: index)
        }
    }
}
