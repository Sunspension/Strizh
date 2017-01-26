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

    weak var tableView: UITableView?
    
    var contentInset: UIEdgeInsets?
    
    
    init(tableView: UITableView) {
        
        super.init()
        
        self.tableView = tableView
        self.contentInset = tableView.contentInset
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardNotificationListener.keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardNotificationListener.keyboardWillHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {
            
            let contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            self.tableView?.contentInset = contentInset
            self.tableView?.scrollIndicatorInsets = contentInset
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        self.tableView?.contentInset = self.contentInset ?? UIEdgeInsets.zero
        self.tableView?.scrollIndicatorInsets = self.contentInset ?? UIEdgeInsets.zero
    }
}
