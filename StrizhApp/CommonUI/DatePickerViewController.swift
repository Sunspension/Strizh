//
//  DatePickerViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 08/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController, UIViewControllerTransitioningDelegate {

    private var selectedDate: Date?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var navigationTitle: String?
    
    var onDidSelectDate: ((_ date: Date) -> Void)?
    
    
    class func instance() -> DatePickerViewController {
        
        return AppDelegate.appSettings.storyBoard.instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let now = Date()
        
        self.selectedDate = now
        
        self.datePicker.minimumDate = now
        self.navigationBar.topItem?.title = navigationTitle
        self.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(self.close))
        
        self.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Выбрать", style: .plain, target: self, action: #selector(self.selectDate))
     
        self.datePicker.addTarget(self, action: #selector(self.didSelectDate(_:)), for: .valueChanged)
    }
    
    func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func selectDate() {
        
        if let selectedDate = self.selectedDate {
            
            self.onDidSelectDate?(selectedDate)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func didSelectDate(_ sender: UIDatePicker) {
        
        selectedDate = sender.date
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        if presented == self {
            
            return DatePickerPresentationController(presentedViewController: presented, presenting: presenting)
        }
        
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return presented == self ? STBottomPopupPresentationAnimation(isPresenting: true) : nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return dismissed == self ? STBottomPopupPresentationAnimation(isPresenting: false) : nil
    }
}
