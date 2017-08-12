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
    
    func st_router_singUpPersonalInfo() {
        
        let controller = STSingUpTableViewController(signupStep: .signupThirdStep)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_router_onAuthorized() {
        
        appDelegate?.onAuthorized()
    }
    
    func st_router_openMainController() {
        
        appDelegate?.openMainController()
    }
    
    func st_router_logout() {
        
        appDelegate?.onLogout()
    }
    
    func st_router_openPostDetails(personal: Bool = false, post: STPost, user: STUser,
                                   images: [STImage]?, files: [STFile]?, locations: [STLocation]?) -> Void {
        
        let controller = storyBoard.instantiateViewController(withIdentifier: String(describing: STFeedDetailsTableViewController.self))
            as! STFeedDetailsTableViewController
        controller.post = post
        controller.user = user
        controller.images = images
        controller.files = files
        controller.locations = locations
        controller.reason = personal ? .personalPostDetails : .feedDetails
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_router_openPostDetails(postId: Int, presented: Bool = true) {
        
        let controller = storyBoard.instantiateViewController(withIdentifier: String(describing: STFeedDetailsTableViewController.self))
            as! STFeedDetailsTableViewController
        
        controller.postId = postId
        controller.reason = .fromChat
        
        if presented {
            
            let navi = STNavigationController(rootViewController: controller)
            self.present(navi, animated: true, completion: nil)
            
            return
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_router_openSettings() {
        
        let controller = STSettingsController()
        
        let navi = STNavigationController(rootViewController: controller)
        self.navigationController?.present(navi, animated: true, completion: nil)
    }
    
    func st_router_openProfileEditing() {
        
        let controller = STEditProfileController()
        
        let navi = STNavigationController(rootViewController: controller)
        self.navigationController?.present(navi, animated: true, completion: nil)
    }
    
    func st_router_openPostController(postObject: STUserPostObject? = nil) {
        
        self.dependencyContainer.register(.singleton) { postObject ?? STUserPostObject() }

        let navi = STNewPostNavigationController(rootViewController: STNewPostController())
        self.present(navi, animated: true, completion: nil)
    }
    
    func st_router_openPostAttachmentsController() {
        
        let controller = STPostAttachmentsController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_router_openContactsController() {
    
        let controller = STContactsController()
        controller.reason = .newPost
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func st_router_openChatController(dialog: STDialog, users: [STUser]) {
        
        let chatController = storyBoard.instantiateViewController(withIdentifier: String(describing: STChatViewController.self)) as! STChatViewController
        
        chatController.dialog = dialog
        chatController.users = users
        chatController.title = dialog.title
        
        self.navigationController?.pushViewController(chatController, animated: true)
    }
    
    func st_router_openChatController(post: STPost) {
        
        let chatController = storyBoard.instantiateViewController(withIdentifier: String(describing: STChatViewController.self)) as! STChatViewController
        
        chatController.postId = post.id
        chatController.objectType = 1
        chatController.title = post.title
        
        self.navigationController?.pushViewController(chatController, animated: true)
    }
    
    func st_router_openDialogsController(postId: Int) {
        
        let chatController = storyBoard.instantiateViewController(withIdentifier: String(describing: STDialogsController.self)) as! STDialogsController
        chatController.postId = postId
        
        self.navigationController?.pushViewController(chatController, animated: true)
    }
    
    func st_router_openDocumentController(url: URL, title: String, present: Bool = true) {
        
        let controller = STDocumentViewController(url: url, title: title)
        
        if present {
            
            let navi = STNewPostNavigationController(rootViewController: controller)
            
            let presentationController = self.navigationController ?? self
            presentationController.present(navi, animated: true, completion: nil)
        }
        else {
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func st_router_openPhotoViewer(images: [STImage], index:Int) {
        
        let controller = storyBoard.instantiateViewController(withIdentifier: String(describing: STPhotoViewController.self.self)) as! STPhotoViewController
        
        controller.images = images
        controller.photoIndex = index
        
        let navi = STNewPostNavigationController(rootViewController: controller)
        self.present(navi, animated: true, completion: nil)
    }
    
    func st_router_openUserProfile(user: STUser) {
        
        let controller = STAnyUserProfileController(user: user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
