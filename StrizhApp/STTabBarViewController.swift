//
//  STTabBarViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 01/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    private var newPostButton: UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }

    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController is STDummyNavigationController {
            
            self.st_router_openNewPostController()
            return false
        }
        
        return true
    }
}
