//
// Created by Vladimir Kokhanevich on 31/08/16.
// Copyright (c) 2016 iConto LLC. All rights reserved.
//

import Foundation
import UIKit

class STIntroPageController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var itemsSource: [STIntroObject] = []

    var scrollCallbackAction: ((_ index:Int) -> Void)?

    var completeCallbackAction: (() -> Void)?

    required init?(coder: NSCoder) {
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : 20])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        self.setViewControllers([self.viewControllerAtIndex(0)],
                                direction: .forward, animated: false, completion: nil)
    }


    func viewControllerAtIndex(_ index: Int) -> UIViewController {

        let controller = UIViewController.loadFromStoryBoard(STIntroImageViewController.self)
        controller.introObject = self.itemsSource[index]
        controller.nextActionClosure = self.nextAction
        return controller
    }


    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        if
            let controller = viewController as? STIntroImageViewController,
            let introObject = controller.introObject {

            var index = itemsSource.index(of: introObject)!

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

        if
            let controller = viewControllers!.last as? STIntroImageViewController,
            let introObject = controller.introObject {

            var index = itemsSource.index(of: introObject)!

            index += 1

            guard index < itemsSource.count else {

                return nil
            }

            return self.viewControllerAtIndex(index)
        }

        return nil
    }

    func scrollToViewController(index newIndex: Int, completionAction: ((Bool) -> Void)?) {
        
        let direction: UIPageViewControllerNavigationDirection = newIndex >= self.viewControllers!.count ? .forward : .reverse
        
        let viewController = self.viewControllerAtIndex(newIndex)
        self.setViewControllers([viewController], direction: direction, animated: true, completion: completionAction)
    }


    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {

        if
            let controller = viewControllers!.first as? STIntroImageViewController,
            let introObject = controller.introObject {
            let index = self.itemsSource.index(of: introObject)!
            self.scrollCallbackAction?(index)
        }
    }

    func nextAction() {

        if
            let controller = viewControllers!.last as? STIntroImageViewController,
            let introObject = controller.introObject {

            var index = self.itemsSource.index(of: introObject)!

            index += 1

            guard index < self.itemsSource.count else {

                self.completeCallbackAction?()
                return
            }

            self.scrollToViewController(index: index, completionAction: nil)
            self.scrollCallbackAction?(index)
        }
    }
}
