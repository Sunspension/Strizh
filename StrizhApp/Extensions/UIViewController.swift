//
//  UIViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 19/04/2017.
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
    
    var analytics: STAnalytics {
        
        return try! self.dependencyContainer.resolve(STAnalytics.self) as! STAnalytics
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
    
    func showDummyView(imageName: String, title: String, subTitle: String, setupView: ((_ dummyView: UIView) -> Void)? = nil) {
        
        self.hideDummyView()
        
        guard let dummy = UIView.loadFromNib(view: STDummyView.self) else {
            
            return
        }
        
        dummy.imageView.image = UIImage(named: imageName)
        dummy.title.text = title
        dummy.subTitle.text = subTitle
        
        setupView?(dummy)
        
        dummy.sizeToFit()
        
        self.view.addSubview(dummy)
        
        var center = self.view.center
        
        if let bar = self.navigationController?.navigationBar {
            
            center.y = center.y - (bar.isHidden ? 0 : bar.frame.size.height)
        }
        
        dummy.center = center
    }
    
    func hideDummyView() {
        
        self.view.subviews.forEach { view in
            
            if view.self is STDummyView {
                
                view.removeFromSuperview()
            }
        }
    }
    
    func dummyView() -> UIView? {
        
        return self.view.subviews.first(where: { $0.self is STDummyView })
    }
}
