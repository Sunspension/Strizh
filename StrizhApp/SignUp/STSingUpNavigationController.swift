//
//  STSingUpNavigationController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 26/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STSingUpNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = UIColor.white
    }
}
