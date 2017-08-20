//
//  Actions.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 17/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func st_action_repostActionSheet(postObject: STUserPostObject) {
        
        let cancel = UIAlertAction.cancel
        
        let edit = UIAlertAction.defaultAction(title: "action_edit".localized) { action in
            
            self.analytics.logEvent(eventName: st_ePostEdit, params: ["post_id" : postObject.id])
            
            postObject.parentId = postObject.post!.id
            postObject.userIds.removeAll()
            self.st_router_openPostController(postObject: postObject)
        }
        
        let resend = UIAlertAction.defaultAction(title: "action_resend".localized) { action in
            
            postObject.parentId = postObject.post!.id
            postObject.userIds.removeAll()
            self.st_router_openContactsController(postObject)
        }
        
        let message = "action_resent_message".localized
        self.showActionController(message: message, actions: [cancel, resend, edit])
    }
    
    func st_action_showMoreActionSheet(postObject: STUserPostObject) {
        
        let cancel = UIAlertAction.cancel
        
        let delete = UIAlertAction.destructiveAction(title: "action_delete".localized) { action in
            
            self.api.deletePost(postId: postObject.id)
                .onSuccess(callback: { [unowned self] _ in
                    
                    self.analytics.logEvent(eventName: st_ePostDelete, params: ["post_id" : postObject.id])
                    NotificationCenter.default.post(name: NSNotification.Name(kPostDeleteNotification), object: postObject.post!)
                })
                .onFailure(callback: { [unowned self] error in
                    
                    self.showError(error: error)
                })
        }
        
        let edit = UIAlertAction.defaultAction(title: "action_edit".localized) { action in
            
            self.analytics.logEvent(eventName: st_ePostEdit,
                                    params: ["post_id" : postObject.id])
            
            self.st_router_openPostController(postObject: postObject)
        }
        
        self.showActionController(actions: [cancel, edit, delete])
    }
}
