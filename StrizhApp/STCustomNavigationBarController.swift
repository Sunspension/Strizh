//
//  STCustomNavigationBarController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 11/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STCustomNavigationBarController: UINavigationController {
    
    let navBar = UINavigationBar()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        navBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navBar.isUserInteractionEnabled = false
        navBar.clipsToBounds = true
        
        var bounds = self.navigationBar.bounds
        
        bounds.origin.y -= 20
        bounds.size.height = bounds.height + 20
        
        self.navigationBar.addSubview(navBar)
        navBar.frame = bounds
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
    }
}
