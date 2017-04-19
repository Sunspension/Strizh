//
//  UITableView.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 19/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import UIKit

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
