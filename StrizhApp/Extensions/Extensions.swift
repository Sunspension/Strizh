//
//  Extensions.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 23/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import UIKit
import Dip

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
    
    var dependencyContainer: DependencyContainer {
        
        return AppDelegate.appSettings.dependencyContainer
    }
    
    func setCustomBackButton() {
        
        let back = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        back.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = back
    }
    
    func showOkAlert(title: String?, message: String?, okAction: ((UIAlertAction) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: okAction)
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
    
    func showBusy() {
        
        self.hideBusy()
        
        let busy = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        busy.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        busy.hidesWhenStopped = true
        busy.startAnimating()
        
        self.view.addSubview(busy)
        busy.center = self.view.center
    }
    
    func hideBusy() {
        
        self.view.subviews.forEach { view in
            
            if view.self is UIActivityIndicatorView {
                
                view.removeFromSuperview()
            }
        }
    }
    
    func showDummyView(imageName: String) {
        
        self.hideDummyView()
        
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 165)
        imageView.contentMode = .scaleAspectFit
        
        self.view.addSubview(imageView)

        var center = self.view.center
        
        if self.view is UITableView {
            
            if let bar = self.navigationController?.navigationBar {
                
                center.y = center.y - (bar.isHidden ? 0 : bar.frame.size.height)
            }
        }
        
        imageView.center = center
    }
    
    func hideDummyView() {
        
        self.view.subviews.forEach { view in
            
            if view.self is UIImageView {
                
                view.removeFromSuperview()
            }
        }
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

extension String {
    
    func string(with color: UIColor) -> NSAttributedString {
        
        return NSAttributedString(string: self, attributes: [ NSForegroundColorAttributeName : color])
    }
}

//Protocal that copyable class should conform
protocol Copying {
    
    init(original: Self)
}

//Concrete class extension
extension Copying {
    
    func copy() -> Self {
       
        return Self.init(original: self)
    }
}

//Array extension for elements conforms the Copying protocol
extension Array where Element: Copying {
    
    func clone() -> Array {
        
        var copiedArray = Array<Element>()
        
        for element in self {
        
            copiedArray.append(element.copy())
        }
        
        return copiedArray
    }
}
