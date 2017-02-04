//
//  FirstViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import BrightFutures

class FirstViewController: UIViewController {

    @IBAction func logout(_ sender: Any) {
    
//        self.st_Router_OnLogout()
        
        api.loadUser(transport: .webSocket, userId: 1571)
            
            .onSuccess { user in
            
                print(user)
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

