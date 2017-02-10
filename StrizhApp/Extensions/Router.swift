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
    
    func st_router_onLogout() {
        
        appDelegate?.onLogout()
    }
    
    func st_router_openPostDetails(post: STPost) -> Void {
        
        let controller = storyBoard.instantiateViewController(withIdentifier: String(describing: STFeedDetailsTableViewController.self)) as! STFeedDetailsTableViewController
        controller.post = post
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
