//
//  ISICIntroContainerViewController.swift
//  iConto
//
//  Created by Vladimir Kokhanevich on 01/09/16.
//  Copyright © 2016 iConto LLC. All rights reserved.
//

import UIKit

class STIntroContainerViewController: UIViewController {
    
    fileprivate var pageViewController: STIntroPageController?
    
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var cancel: UIButton!
    
    
    class func controllerInstance() -> STIntroContainerViewController {
        
        return UIViewController.loadFromStoryBoard(STIntroContainerViewController.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cancel.addTarget(self, action: #selector(self.skipAction), for: .touchUpInside)
        self.pageControl.addTarget(self, action: #selector(self.didChangePageControlValue), for: .valueChanged)
        
        self.analytics.logEvent(eventName: st_eIntro, timed: true)
    }
    
    func didChangePageControlValue() {
        
        self.pageViewController?.scrollToViewController(index: self.pageControl.currentPage, completionAction: nil)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let pageViewController = segue.destination as? STIntroPageController {
            
            var intro1 = STIntroObject()
            intro1.imageName = "intro-1"
            intro1.title = "Добро пожаловать!"
            intro1.subtitle = "Упрощайте рабочий процесс, договаривайтесь о сделках в 3 шага."
            intro1.nextTitle = "Далее"
            
            var intro2 = STIntroObject()
            intro2.imageName = "intro-2"
            intro2.title = "Шаг 1"
            intro2.subtitle = "Описывайте свое деловое предложение или запрос."
            intro2.nextTitle = "Далее"
            
            var intro3 = STIntroObject()
            intro3.imageName = "intro-3"
            intro3.title = "Шаг 2"
            intro3.subtitle = "Выбирайте получателей из своей контактной книги."
            intro3.nextTitle = "Далее"

            var intro4 = STIntroObject()
            intro4.imageName = "intro-4"
            intro4.title = "Шаг 3"
            intro4.subtitle = "Обсуждайте и договаривайтесь о сделке в персональном чате."
            intro4.nextTitle = "Начать"
            
            let dataSource = [intro1, intro2, intro3, intro4]
            
            self.pageControl.numberOfPages = dataSource.count

            pageViewController.itemsSource = dataSource

            pageViewController.scrollCallbackAction = { index in

                self.pageControl.currentPage = index
            }

            pageViewController.completeCallbackAction = self.skipAction
            self.pageViewController = pageViewController
        }
    }

    func nextAction() {

        self.pageViewController!.nextAction()
    }
    
    func skipAction() {
        
        self.analytics.logEvent(eventName: st_eSkipIntro)
        
        NotificationCenter.default.post(Notification(name: Notification.Name(kIntroHasEndedNotification),
                                                     object: nil))
    }
}
