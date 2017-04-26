//
// Created by Vladimir Kokhanevich on 31/08/16.
// Copyright (c) 2016 iConto LLC. All rights reserved.
//

import Foundation
import UIKit

class STIntroPageController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var imagesName: [String] = []

    var scrollCallbackAction: ((_ index:Int) -> Void)?

    var completeCallbackAction: (() -> Void)?


    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        if let controller = self.viewControllerAtIndex(0) {

            self.setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        }
    }


    func viewControllerAtIndex(_ index: Int) -> UIViewController? {

//        if let controller = self.instantiateViewControllerWithIdentifierOrNibName("IntroImageController") as? STIntroImageViewController {
//            
//            controller.imageName = imagesName[index]
//            return controller
//        }

        return nil
    }


    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        if let controller = viewController as? STIntroImageViewController , controller.imageName != nil {

            var index = imagesName.index(of: controller.imageName!)!

            index -= 1

            guard index >= 0 else {

                return nil
            }

            return self.viewControllerAtIndex(index)
        }
        else {

            return nil
        }
    }


    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        if let controller = viewControllers!.last as? STIntroImageViewController , controller.imageName != nil {

            var index = imagesName.index(of: controller.imageName!)!

            index += 1

            guard index < imagesName.count else {

                return nil
            }

            return self.viewControllerAtIndex(index)
        }

        return nil;
    }


    func scrollToViewController(index newIndex: Int, completionAction: ((Bool) -> Void)?) {
        
        let direction: UIPageViewControllerNavigationDirection = newIndex >= self.viewControllers!.count ? .forward : .reverse
        
        if let viewController = self.viewControllerAtIndex(newIndex) {
            
            self.setViewControllers([viewController], direction: direction, animated: true, completion: completionAction)
        }
    }


    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {

        if let controller = viewControllers!.first as? STIntroImageViewController {

            let index = imagesName.index(of: controller.imageName!)!
            self.scrollCallbackAction?(index)
        }
    }


    func nextAction() {

        if let controller = viewControllers!.last as? STIntroImageViewController, controller.imageName != nil {

            var index = imagesName.index(of: controller.imageName!)!

            index += 1

            guard index < imagesName.count else {

                self.completeCallbackAction?()
                return
            }

            self.scrollToViewController(index: index, completionAction: nil)
            self.scrollCallbackAction?(index)
        }
    }
}
