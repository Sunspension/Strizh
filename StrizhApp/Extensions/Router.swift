//
//  Router.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 27/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func st_Router_SigUpStepOne() {
        
        let controller = STSingUpTableViewController(signupStep: .signupFirstStep)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_Router_SigUpStepTwo() {
        
        let controller = STSingUpTableViewController(signupStep: .signupSecondStep)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_Router_SigUpFinish() {
        
        let controller = STSingUpTableViewController(signupStep: .signupThirdStep)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_Router_OpenMainController() {
        
        if let controller = appSettings.storyBoard.instantiateInitialViewController() {
            
            self.changeRootViewController(controller)
        }
    }
    
    func st_Router_OnLogout() {
        
        api.logout()
            .onSuccess { session in
         
                print("logout")
                print(session)
            }
        
        let controller = STSingUpTableViewController(signupStep: .signupFirstStep)
        self.changeRootViewController(controller)
    }
}
