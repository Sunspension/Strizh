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
        
        let controller = storyBoard.instantiateViewController(withIdentifier: String(describing: STFeedDetailsTableViewController.self)) as! STFeedDetailsTableViewController
        controller.post = post
        controller.user = user
        controller.images = images
        controller.files = files
        controller.locations = locations
        controller.reason = personal ? .personalPostDetails : .feedDetails
        
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
}
