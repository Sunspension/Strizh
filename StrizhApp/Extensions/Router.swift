//
//  Router.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 27/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func st_router_sigUpStepOne() {
        
        let controller = STSingUpTableViewController(signupStep: .signupFirstStep)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_router_sigUpStepTwo() {
        
        let controller = STSingUpTableViewController(signupStep: .signupSecondStep)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_router_sigUpFinish() {
        
        let controller = STSingUpTableViewController(signupStep: .signupThirdStep)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_router_openMainController() {
        
        appDelegate?.onLogin()
    }
    
    func st_router_logout() {
        
        appDelegate?.onLogout()
    }
    
    func st_router_openPostDetails(post: STPost, user: STUser, images: [STImage]?, files: [STFile]?, locations: [STLocation]?) -> Void {
        
        let controller = storyBoard.instantiateViewController(withIdentifier: String(describing: STFeedDetailsTableViewController.self)) as! STFeedDetailsTableViewController
        controller.post = post
        controller.user = user
        controller.images = images
        controller.files = files
        controller.locations = locations
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_router_openSettings() {
        
        let controller = STSettingsController()
        
        let navi = STNavigationController(rootViewController: controller)
        self.navigationController?.present(navi, animated: true, completion: nil)
    }
}
