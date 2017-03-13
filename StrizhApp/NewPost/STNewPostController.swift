//
//  STNewPostController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import Bond

class STNewPostController: UITableViewController {

    
    private var dataSource = TableViewDataSource()
    
    private var requiredFieldsSection = CollectionSection()
    
    private var optionalFieldsSection = CollectionSection()
    
    private var postObject: STNewPostObject?
    
    private var fromDate: Date?
    
    private var tillDate: Date?
    
    private var fromDateError: Bool = false
    
    private var tillDateError: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let leftItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(self.nextAction))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.title = "Новая тема"
    
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        self.tableView.register(nibClass: STTextFieldCell.self)
        self.tableView.register(nibClass: STPostButtonsCell.self)
        self.tableView.register(nibClass: STTextFieldsCell.self)
        self.tableView.register(nibClass: STTextViewCell.self)
        self.tableView.register(headerFooterNibClass: STContactHeaderCell.self)
        
        self.dataSource.sections.append(self.requiredFieldsSection)
        self.dataSource.sections.append(self.optionalFieldsSection)
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
        setCustomBackButton()
        
        self.createDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let navi = self.navigationController as? STNewPostNavigationController {
            
            self.postObject = navi.postObject
        }
    }
    
    func cancel() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func nextAction() {
        
        self.view.endEditing(true)
        
        var error = false
        
        self.requiredFieldsSection.items.forEach { item in
            
            if let valid = item.validation {
                
                let result = valid().valid
                
                if result == false && error == false {
                    
                    error = true
                }
            }
        }
        
        if error {
            
            return
        }
        
        self.st_router_openPostAttachmentsController()
    }
    
    private func createDataSource() {
        
        // set by default
        self.postObject?.type = 1
        
        self.dataSource.onDidSelectRowAtIndexPath = { (tableView, indexPath, item) in
            
            if let cell = tableView.cellForRow(at: item.indexPath) as? STTextFieldCell {
                
                cell.value.becomeFirstResponder()
            }
        }
        
        self.requiredFieldsSection.header(headerClass: STContactHeaderCell.self) { (view, section) in
            
            let header = view as! STContactHeaderCell
            
            header.title.text = "ОБЯЗАТЕЛЬНЫЕ ПОЛЯ:"
            header.title.font = UIFont.systemFont(ofSize: 12)
            header.title.textColor = UIColor.stSteelGrey
            header.topSpace.constant = 16
        }
        
        self.requiredFieldsSection.headerItem?.cellHeight = 46
        
        self.requiredFieldsSection.addItem(cellClass: STPostButtonsCell.self) { (cell, item) in
            
            let viewCell = cell as! STPostButtonsCell
            
            viewCell.offerButtonSelected(selected: true)
            viewCell.title.text = "Вид темы"
            
            viewCell.offer.reactive.tap.observe { [unowned viewCell, unowned self] _ in
                
                self.postObject?.type = 1
                viewCell.offerButtonSelected(selected: !viewCell.offer.isSelected)
                
                }.dispose(in: viewCell.bag)
            
            viewCell.search.reactive.tap.observe {[unowned viewCell] _ in
                
                self.postObject?.type = 2
                viewCell.searchButtonSelected(selected: !viewCell.search.isSelected)
                
                }.dispose(in: viewCell.bag)
        }
        
        self.requiredFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldCell
            
            viewCell.title.text = "Название"
            viewCell.value.placeholder = "Введите название темы"
            viewCell.value.reactive.text.observeNext { [unowned viewCell, unowned self] text in
                
                if self.postObject != nil {
                    
                    self.postObject!.title = text ?? ""
                    viewCell.hideError()
                }
                
            }.dispose(in: viewCell.bag)
            
            viewCell.onErrorHandler = { [unowned self] in
                
                self.showValidationAlert()
            }
            
            if item.hasError {
                
                viewCell.showError()
            }
            
            item.validation = { [unowned item] in
                
                if !self.postObject!.title.isEmpty {
                    
                    item.hasError = false
                    return ValidationResult.onSuccess
                }
                else {
                    
                    viewCell.showError()
                    item.hasError = true
                    return ValidationResult.onError(errorMessage: "")
                }
            }
        }
        
        self.requiredFieldsSection.addItem(cellClass: STTextViewCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextViewCell
            
            viewCell.title.text = "Описание"
            viewCell.value.attributedText = NSAttributedString(string: "Введите описание темы", attributes: [NSForegroundColorAttributeName : UIColor.lightGray, NSFontAttributeName : UIFont.systemFont(ofSize: 14)]);
            
            viewCell.value.reactive.text.observeNext { [unowned viewCell, unowned self] text in
                
                let offset = self.tableView.contentOffset
                
                UIView.setAnimationsEnabled(false)
                
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                
                UIView.setAnimationsEnabled(true)
                
                self.tableView.contentOffset = offset
                
                if self.postObject != nil {
                    
                    self.postObject!.title = text ?? ""
                    //                    viewCell.hideError()
                }
                
                }.dispose(in: viewCell.bag)
            
            //            viewCell.onErrorHandler = { [unowned self] in
            //
            //                self.showValidationAlert()
            //            }
            
            if item.hasError {
                
                //                viewCell.showError()
            }
            
            item.validation = { [unowned item] in
                
                if !self.postObject!.title.isEmpty {
                    
                    item.hasError = false
                    return ValidationResult.onSuccess
                }
                else {
                    
                    //                    viewCell.showError()
                    item.hasError = true
                    return ValidationResult.onError(errorMessage: "")
                }
            }
        }
        
//        self.requiredFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
//            
//            let viewCell = cell as! STTextFieldCell
//            
//            viewCell.title.text = "Описание"
//            viewCell.value.placeholder = "Введите описание темы"
//            
//            viewCell.value.reactive.text.observeNext { [unowned viewCell] text in
//                
//                if self.postObject != nil {
//                 
//                    viewCell.hideError()
//                    self.postObject!.details = text ?? ""
//                }
//                
//            }.dispose(in: viewCell.bag)
//            
//            viewCell.onErrorHandler = { [unowned self] in
//                
//                self.showValidationAlert()
//            }
//            
//            if item.hasError {
//                
//                viewCell.showError()
//            }
//            
//            item.validation = { [unowned item] in
//                
//                if !self.postObject!.details.isEmpty {
//                    
//                    item.hasError = false
//                    return ValidationResult.onSuccess
//                }
//                else {
//                    
//                    viewCell.showError()
//                    item.hasError = true
//                    return ValidationResult.onError(errorMessage: "")
//                }
//            }
//        }
//        
        self.requiredFieldsSection.addItem(cellClass: STTextFieldsCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldsCell
            
            viewCell.title.text = "Срок действия"
            viewCell.leftValue.placeholder = "Начало"
            viewCell.rightValue.placeholder = "Конец"
            
            if let postObject = self.postObject {
                
                if postObject.fromDate != nil {
                    
                    viewCell.leftValue.text = postObject.fromDate!.mediumLocalizedFormat
                }
                
                if postObject.tillDate != nil {
                    
                    viewCell.rightValue.text = postObject.tillDate!.mediumLocalizedFormat
                }
            }
            
            viewCell.onLeftValueShouldBeginEditing = { [unowned viewCell] in
                
                let controller = DatePickerViewController.instance()
                controller.navigationTitle = "Начало"
                controller.onDidSelectDate = { [unowned viewCell, unowned self] selectedDate in
                    
                    self.postObject!.fromDate = selectedDate
                    self.fromDateError = false
                    
                    viewCell.leftValue.text = self.postObject!.fromDate!.mediumLocalizedFormat
                    viewCell.hideLeftError()
                }
                
                self.present(controller, animated: true, completion: nil)
            }
            
            viewCell.onRightValueShouldBeginEditing = { [unowned viewCell, unowned self] in
                
                let controller = DatePickerViewController.instance()
                controller.navigationTitle = "Конец"
                
                controller.onDidSelectDate = { [unowned viewCell, unowned self] selectedDate in
                    
                    self.postObject!.tillDate = selectedDate
                    self.tillDateError = false
                    
                    viewCell.rightValue.text = self.postObject!.tillDate!.mediumLocalizedFormat
                    viewCell.hideRightError()
                }
                
                self.present(controller, animated: true, completion: nil)
            }
            
            viewCell.onLeftErrorHandler = { [unowned self] in
                
                self.showValidationAlert()
            }
            
            viewCell.onRightErrorHandler = { [unowned self] in
                
                self.showValidationAlert()
            }
            
            item.validation = {
                
                var error = false
                
                if self.postObject!.fromDate == nil {
                    
                    error = true
                    viewCell.showLeftError()
                }
                
                if self.postObject!.tillDate == nil {
                    
                    error = true
                    viewCell.showRightError()
                }
                
                return error == true ? ValidationResult.onError(errorMessage: "") : ValidationResult.onSuccess
            }
        }
        
        // optional
        self.optionalFieldsSection.header(headerClass: STContactHeaderCell.self) { (view, section) in
            
            let header = view as! STContactHeaderCell
            
            header.title.text = "ДОПОЛНИТЕЛЬНЫЕ ПОЛЯ:"
            header.title.font = UIFont.systemFont(ofSize: 12)
            header.title.textColor = UIColor.stSteelGrey
            header.topSpace.constant = 16
        }
        
        self.optionalFieldsSection.headerItem?.cellHeight = 46
        
        self.optionalFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldCell
            
            viewCell.title.text = "Цена руб."
            viewCell.value.placeholder = "0.00"
            viewCell.value.keyboardType = .numberPad
            
            viewCell.value.reactive.text.observeNext { text in
                
                if var postObject = self.postObject {
                    
                    postObject.price = Double(text ?? "") ?? 0.0
                }
                
            }.dispose(in: viewCell.bag)
        }
        
        self.optionalFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldCell
            
            viewCell.title.text = "Комментарий к цене"
            viewCell.value.placeholder = "Торг возможен, ниже рыночной цены и т.д."
            
            viewCell.value.reactive.text.observeNext { text in
                
                if var postObject = self.postObject {
                    
                    postObject.priceDescription = text ?? ""
                }
                
            }.dispose(in: viewCell.bag)
        }
        
        self.optionalFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldCell
            
            viewCell.title.text = "Агентское вознаграждение"
            viewCell.value.placeholder = "Опишите профит для адресатов"
            
            viewCell.value.reactive.text.observeNext { text in
                
                if var postObject = self.postObject {
                    
                    postObject.profitDescription = text ?? ""
                }
                
            }.dispose(in: viewCell.bag)
        }
    }
    
    private func showValidationAlert() {
        
        self.showOkAlert(title: "Ошибка", message: "Это поле не может быть пустым")
    }
}
