//
//  STApplicationInterability.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 9/24/17.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import MessageUI

class STApplicationInterability: UIViewController, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate var smsController: MFMessageComposeViewController?
    
    
    func sendSMS(phoneNumber: String, body: String, inController: UIViewController) {
        
        if MFMessageComposeViewController.canSendText() {
            
            smsController = MFMessageComposeViewController()
            smsController!.body = body
            smsController!.recipients = [phoneNumber]
            smsController?.messageComposeDelegate = self
            
            inController.present(smsController!, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        smsController!.dismiss(animated: true, completion: nil)
    }
}
