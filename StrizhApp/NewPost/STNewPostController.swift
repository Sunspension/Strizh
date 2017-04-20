//
//  STNewPostController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 02/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import Bond
import Dip

class STNewPostController: UITableViewController, UITextViewDelegate {

    
    fileprivate var dataSource = TableViewDataSource()
    
    fileprivate var requiredFieldsSection = TableSection()
    
    fileprivate var optionalFieldsSection = TableSection()
    
    fileprivate lazy var postObject: STUserPostObject = {
       
        return try! self.dependencyContainer.resolve(STUserPostObject.self) as! STUserPostObject
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let leftItem = UIBarButtonItem(title: "action_cancel".localized, style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem = UIBarButtonItem(title: "action_next".localized, style: .plain, target: self, action: #selector(self.nextAction))
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 60
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
        
        self.title = !self.postObject.title.isEmpty ? self.postObject.title : "post_page_title".localized
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
    
    fileprivate func createDataSource() {
        
        // set by default
        self.postObject.type = 1
        
        self.dataSource.onDidSelectRowAtIndexPath = { (tableView, indexPath, item) in
            
            if let cell = tableView.cellForRow(at: item.indexPath) as? STTextFieldCell {
                
                cell.value.becomeFirstResponder()
            }
        }
        
        self.requiredFieldsSection.header(headerClass: STContactHeaderCell.self) { (view, section) in
            
            let header = view as! STContactHeaderCell
            
            header.title.text = "post_page_required_fields_text".localized
            header.title.font = UIFont.systemFont(ofSize: 12)
            header.title.textColor = UIColor.stSteelGrey
            header.topSpace.constant = 16
        }
        
        self.requiredFieldsSection.headerItem?.cellHeight = 46
        
        self.requiredFieldsSection.addItem(cellClass: STPostButtonsCell.self) { (cell, item) in
            
            let viewCell = cell as! STPostButtonsCell
            
            self.postObject.type = 1
            
            viewCell.offerButtonSelected(true)
            viewCell.title.text = "post_page_topic_type_text".localized
            viewCell.setType(type: self.postObject.type)
            
            
            viewCell.offer.reactive.tap.observe { [unowned viewCell, unowned self] _ in
                
                self.postObject.type = 1
                viewCell.offerButtonSelected(true)
                
                }.dispose(in: viewCell.bag)
            
            viewCell.search.reactive.tap.observe {[unowned viewCell] _ in
                
                self.postObject.type = 2
                viewCell.searchButtonSelected(true)
                
                }.dispose(in: viewCell.bag)
        }
        
        self.requiredFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldCell
            
            viewCell.title.text = "post_page_name_text".localized
            viewCell.value.placeholder = "post_page_enter_topic_name_text".localized
            viewCell.value.text = self.postObject.title
            
            viewCell.onTextDidChange = { [unowned viewCell, unowned self] text in
                
                self.postObject.title = text
                viewCell.hideError()
            }
            
            viewCell.onErrorHandler = { [unowned self] in
                
                self.showValidationAlert()
            }
            
            if item.hasError {
                
                viewCell.showError()
            }
            
            item.validation = { [unowned item] in
                
                if !self.postObject.title.isEmpty {
                    
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
            
            viewCell.title.text = "post_page_description_text".localized
            viewCell.placeHolder.placeholder = "post_page_enter_topic_description_text".localized
            viewCell.textValue = self.postObject.details
            
            viewCell.onReturn = { [unowned self] in
                
                self.view.endEditing(true)
            }
            
            viewCell.onTextViewDidChange = { [unowned self] textView in
                
                self.postObject.details = textView.text ?? ""
                viewCell.hideError()
                
                self.refreshTableView()
            }
            
            
            viewCell.onErrorHandler = { [unowned self] in

                self.showValidationAlert()
            }
            
            if item.hasError {
                
                viewCell.showError()
            }
            
            item.validation = { [unowned item] in
                
                if !self.postObject.details.isEmpty {
                    
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
        
        // optional
        self.optionalFieldsSection.header(headerClass: STContactHeaderCell.self) { (view, section) in
            
            let header = view as! STContactHeaderCell
            
            header.title.text = "post_page_additional_fields_text".localized
            header.title.font = UIFont.systemFont(ofSize: 12)
            header.title.textColor = UIColor.stSteelGrey
            header.topSpace.constant = 16
        }
        
        self.optionalFieldsSection.headerItem?.cellHeight = 46
        
        self.optionalFieldsSection.addItem(cellClass: STTextFieldsCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldsCell
            
            viewCell.title.text = "post_page_duration".localized
            viewCell.leftValue.placeholder = "post_page_time_to_begin_text".localized
            viewCell.rightValue.placeholder = "post_page_time_to_end_text".localized
            
            viewCell.leftValue.text = self.postObject.fromDate?.mediumLocalizedFormat
            viewCell.rightValue.text = self.postObject.tillDate?.mediumLocalizedFormat
            
            viewCell.onLeftValueShouldBeginEditing = { [unowned viewCell] in
                
                let controller = DatePickerViewController.instance()
                controller.navigationTitle = "post_page_time_to_begin_text".localized
                controller.onDidSelectDate = { [unowned viewCell, unowned self] selectedDate in
                    
                    self.postObject.fromDate = selectedDate
                    viewCell.leftValue.text = self.postObject.fromDate!.mediumLocalizedFormat
                }
                
                self.present(controller, animated: true, completion: nil)
            }
            
            viewCell.onRightValueShouldBeginEditing = { [unowned viewCell, unowned self] in
                
                let controller = DatePickerViewController.instance()
                controller.navigationTitle = "post_page_time_to_end_text".localized
                
                controller.onDidSelectDate = { [unowned viewCell, unowned self] selectedDate in
                    
                    self.postObject.tillDate = selectedDate
                    viewCell.rightValue.text = self.postObject.tillDate?.mediumLocalizedFormat
                }
                
                self.present(controller, animated: true, completion: nil)
            }
        }
        
        self.optionalFieldsSection.addItem(cellClass: STTextFieldCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextFieldCell
            
            viewCell.title.text = "post_page_price_text".localized
            viewCell.value.placeholder = "post_page_price_details_placeholder".localized
            viewCell.value.keyboardType = .numbersAndPunctuation
            
            viewCell.value.text = self.postObject.price
            
            viewCell.value.reactive.text.observeNext { text in
                
                self.postObject.price = text ?? ""
                
            }.dispose(in: viewCell.bag)
        }
        
        self.optionalFieldsSection.addItem(cellClass: STTextViewCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextViewCell
            
            viewCell.title.text = "post_page_price_comment_text".localized
            viewCell.placeHolder.placeholder = "post_page_price_comment_placeholder".localized
            viewCell.textValue = self.postObject.priceDescription
            
            viewCell.onReturn = { [unowned self] in
                
                self.view.endEditing(true)
            }
            
            viewCell.onTextViewDidChange = { [unowned self] textView in
                
                self.postObject.priceDescription = textView.text ?? ""
                self.refreshTableView()
            }
        }
        
        self.optionalFieldsSection.addItem(cellClass: STTextViewCell.self) { (cell, item) in
            
            let viewCell = cell as! STTextViewCell
            
            viewCell.title.text = "post_page_agency_profit_text".localized
            viewCell.placeHolder.placeholder = "post_page_agency_profit_placeholder".localized
            viewCell.textValue = self.postObject.profitDescription
            
            viewCell.onReturn = { [unowned self] in
                
                self.view.endEditing(true)
            }
            
            viewCell.onTextViewDidChange = { [unowned self] textView in
                
                self.postObject.profitDescription = textView.text ?? ""
                self.refreshTableView()
            }
        }
    }
    
    fileprivate func showValidationAlert() {
        
        self.showOkAlert(title: "alert_title_error".localized, message: "post_page_error_validation_message".localized)
    }
    
    func refreshTableView() {
        
        let currentOffset = tableView.contentOffset
        
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        
        tableView.setContentOffset(currentOffset, animated: false)
    }
}
