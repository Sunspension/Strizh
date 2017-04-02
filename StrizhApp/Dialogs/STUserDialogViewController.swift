//
//  STUserDialogViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/04/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STUserDialogViewController: UIViewController {

    fileprivate var dialog: STDialog!
    
    fileprivate var chatController: STChatViewController!
    
    fileprivate var users: [STUser]!
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    init(dialog: STDialog, users: [STUser], chatController: STChatViewController) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.chatController = chatController
        self.dialog = dialog
        self.users = users
        
        self.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.dialog.title
        
        self.addChildViewController(self.chatController!)
        self.view.addSubview(self.chatController!.view)
        self.chatController!.didMove(toParentViewController: self)
        
        api.loadDialogMessages(dialog: dialog, pageSize: 20, lastId: nil)
            
            .onSuccess { messages in
                
                let reverse = Array(messages.reversed())
                self.chatController.users = self.users
                self.chatController.itemsSource = reverse
                
            }.onFailure { error in
                
                self.showError(error: error)
        }
    }
}
