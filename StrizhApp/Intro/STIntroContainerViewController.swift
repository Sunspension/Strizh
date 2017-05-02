//
//  ISICIntroContainerViewController.swift
//  iConto
//
//  Created by Vladimir Kokhanevich on 01/09/16.
//  Copyright © 2016 iConto LLC. All rights reserved.
//

import UIKit

class STIntroContainerViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var cancel: UIButton!
    
    
    var imagesName: [String]!
    
    
    var pageViewController: STIntroPageController?
    
    class func controllerInstance() -> STIntroContainerViewController {
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TIntroController")
            as! STIntroContainerViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cancel.setTitle("action_skip".localized, for: UIControlState())
//        self.buttonNext.setTitle("action_next".localized, for: UIControlState())
        
//        self.buttonNext.addTarget(self, action: #selector(self.nextAction), for: .touchUpInside)
        self.cancel.addTarget(self, action: #selector(self.skipAction), for: .touchUpInside)
        
        self.pageControl.addTarget(self, action: #selector(self.didChangePageControlValue), for: .valueChanged)
    }
    
    func didChangePageControlValue() {
        
        self.pageViewController?.scrollToViewController(index: self.pageControl.currentPage, completionAction: nil)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let pageViewController = segue.destination as? STIntroPageController {

            self.imagesName = ["intro-1", "intro-2", "intro-3", "intro-4", "intro-5"]

            self.pageControl.numberOfPages = self.imagesName.count

            pageViewController.imagesName = self.imagesName

            pageViewController.scrollCallbackAction = { index in

                self.pageControl.currentPage = index

                if index == self.imagesName.count - 1 {

//                    self.buttonNext.setTitle("action_done".localized, for: UIControlState())
                }
                else  {

//                    self.buttonNext.setTitle("action_next".localized, for: UIControlState())
                }
            }

            pageViewController.completeCallbackAction = {

                NotificationCenter.default.post(Notification(name: Notification.Name(kIntroHasEndedNotification),
                                                             object: nil))
            }

            self.pageViewController = pageViewController
        }
    }

    func nextAction() {

        self.pageViewController!.nextAction()
    }
    
    func skipAction() {
        
        NotificationCenter.default.post(Notification(name: Notification.Name(kIntroHasEndedNotification),
                                                     object: nil))
    }
}
