//
//  KeyboardNotificationListener.swift
//  Targo
//
//  Created by Vladimir Kokhanevich on 01/09/16.
//  Copyright © 2016 Targo. All rights reserved.
//

import UIKit

// You shoud initialize it in viewWillAppear or viewDidAppear, bacause of navigation controller
class KeyboardNotificationListener: NSObject {

    weak var scrollView: UIScrollView?
    
    var contentInset: UIEdgeInsets?
    
    
    init(scrollView: UIScrollView) {
        
        super.init()
        
        self.scrollView = scrollView
        self.contentInset = scrollView.contentInset
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            
            let contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            self.scrollView?.contentInset = contentInset
            self.scrollView?.scrollIndicatorInsets = contentInset
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        self.scrollView?.contentInset = self.contentInset ?? UIEdgeInsets.zero
        self.scrollView?.scrollIndicatorInsets = self.contentInset ?? UIEdgeInsets.zero
    }
}
