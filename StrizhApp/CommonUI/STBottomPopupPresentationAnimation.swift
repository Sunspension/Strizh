//
//  STBottomPopupPresentationAnimationController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 08/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STBottomPopupPresentationAnimation: NSObject, UIViewControllerAnimatedTransitioning, UINavigationControllerDelegate {
    
    private let isPresenting: Bool
    
    init(isPresenting: Bool) {
        
        self.isPresenting = isPresenting
        
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if isPresenting {
            
            animatePresenation(with: transitionContext)
        }
        else {
            
            animateDismissal(with: transitionContext)
        }
    }
    
    private func animatePresenation(with transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            
            let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
                
                return
        }
        
        let containerView = transitionContext.containerView
        
        presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
        presentedControllerView.center.y += containerView.bounds.size.height
        
        containerView.addSubview(presentedControllerView)
        
        // Animate the presented view to it's final position
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 10,
                       initialSpringVelocity: 20,
                       options: .allowUserInteraction,
                       animations: {
                        
                        presentedControllerView.center.y -= containerView.bounds.size.height
        },
                       completion: { completed in
                        
                        transitionContext.completeTransition(completed)
        })
    }
    
    private func animateDismissal(with transitionContext: UIViewControllerContextTransitioning) {
        
        guard let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
            
            return
        }
        
        let containerView = transitionContext.containerView
        
        // Animate the presented view off the bottom of the view
        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .allowUserInteraction,
                       animations: {
                        
                        presentedControllerView.center.y += containerView.bounds.size.height
        },
                       completion: { completed in
                        
                        transitionContext.completeTransition(completed)
        })
    }
}
