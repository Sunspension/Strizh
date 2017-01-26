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
        
        let controller = STSingUpTableViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
