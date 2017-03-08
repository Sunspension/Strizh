//
//  DatePickerPresentationController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 08/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class DatePickerPresentationController: UIPresentationController {

    lazy var dimmingView: UIView = {
        
        let view = UIView(frame: self.containerView!.bounds)
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.alpha = 0
        
        return view
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        guard let containerView = containerView else {
            
            return CGRect()
        }
        
        let frame = containerView.bounds
        
        let width: CGFloat = frame.size.width
        let height: CGFloat = 200
        let x: CGFloat = 0
        let y: CGFloat = frame.height - height;
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func presentationTransitionWillBegin() {
        
        guard
            
            let containerView = containerView,
            let presentedView = presentedView else {
                
                return
        }
        
        dimmingView.frame = containerView.bounds
        containerView.addSubview(dimmingView)
        containerView.addSubview(presentedView)
        
        // fade
        if let coordinator = self.presentingViewController.transitionCoordinator {
            
            coordinator.animate(alongsideTransition: { context in
                
                self.dimmingView.alpha = 1
                
            }, completion: nil)
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        
        if !completed {
            
            self.dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        
        if let coordinator = self.presentingViewController.transitionCoordinator {
            
            coordinator.animate(alongsideTransition: { context in
                
                self.dimmingView.alpha = 0
                
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
        if completed {
            
            self.dimmingView.removeFromSuperview()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let containerView = containerView else {
            
            return
        }
        
        coordinator.animate(alongsideTransition: { context in
            
            self.dimmingView.frame = containerView.bounds
            
        }, completion: nil)
    }
}
