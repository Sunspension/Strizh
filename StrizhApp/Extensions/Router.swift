//
//  Router.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 27/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func st_Router_SigUpStepTwo() {
        
        let controller = STSingUpTableViewController(signupStep: .signupSecondStep)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_Router_SigUpFinish() {
        
        let controller = AppDelegate.appSettings.storyBoard.instantiateViewController(withIdentifier:
            String(describing: STSingUpPersonalInfoViewController.self))
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_Router_OpenMainController() {
        
        
    }
}
