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
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.analytics.endTimeEvent(eventName: st_eNewPostStep1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        self.analytics.endTimeEvent(eventName: st_eCloseNewPost)
    }
    
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
        self.tableView.register(nibClass: STTextFieldsCell.self)
        self.tableView.register(nibClass: STTextViewCell.self)
        self.tableView.register(headerFooterNibClass: STContactHeaderCell.self)
        
        self.dataSource.sections.append(self.requiredFieldsSection)
        self.dataSource.sections.append(self.optionalFieldsSection)
        
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        
        setCustomBackButton()
        createDataSource()
        
        self.title = !self.postObject.title.isEmpty ? self.postObject.title : "post_page_title".localized
        
        let tapRecognaizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler))
        tapRecognaizer.numberOfTapsRequired = 1
        tapRecognaizer.numberOfTouchesRequired = 1
        
        self.view.addGestureRecognizer(tapRecognaizer)
    }
    
    // MARK: - Private methods
    
    @objc private func tapGestureHandler(tapRecognizer: UITapGestureRecognizer) {
        
        if tapRecognizer.state != .recognized {
            
            return
        }
        
        self.view.endEditing(true)
    }
    
    @objc private func cancel() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func nextAction() {
        
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
    
    private func setupOptionalSection() {
        
        self.optionalFieldsSection.add(cellStyle: .default) { (cell, item) in
            
            cell.heightAnchor.constraint(equalToConstant: 10).isActive = true
            cell.backgroundColor = UIColor.stLightBlueGrey
            cell.selectionStyle = .none
        }
        
        self.optionalFieldsSection.add(cellClass: STTextFieldsCell.self) { (cell, item) in
            
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
        
        self.optionalFieldsSection.add(cellStyle: .default) { (cell, item) in
            
            self.configureDummyCell(cell: cell)
            cell.textLabel?.text = "post_page_post_duration_description_explanation".localized
        }
    }
    
    private func setupRequiredSection() {
        
        self.requiredFieldsSection.add(cellStyle: .default) { (cell, item) in
            
            cell.heightAnchor.constraint(equalToConstant: 20).isActive = true
            cell.backgroundColor = UIColor.stLightBlueGrey
            cell.selectionStyle = .none
        }
        
        self.requiredFieldsSection.add(cellClass: STTextFieldCell.self) { (cell, item) in
            
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
        
        self.requiredFieldsSection.add(cellClass: STTextViewCell.self) { (cell, item) in
            
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
        
        self.requiredFieldsSection.add(cellStyle: .default) { (cell, item) in
            
            self.configureDummyCell(cell: cell)
            cell.textLabel?.text = "post_page_post_description_explanation".localized
        }
    }
    
    private func configureDummyCell(cell: UITableViewCell) {
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 11)
        cell.textLabel?.textColor = UIColor.stSteelGrey
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = UIColor.stLightBlueGrey
        cell.selectionStyle = .none
    }
    
    private func createDataSource() {
        
        self.dataSource.onDidSelectRowAtIndexPath = { (tableView, indexPath, item) in
            
            if let cell = tableView.cellForRow(at: item.indexPath) as? STTextFieldCell {
                
                cell.value.becomeFirstResponder()
            }
        }
        
        setupRequiredSection()
        setupOptionalSection()
    }
    
    private func showValidationAlert() {
        
        self.showOkAlert(title: "alert_title_error".localized, message: "post_page_error_validation_message".localized)
    }
    
    private func refreshTableView() {
        
        let currentOffset = tableView.contentOffset
        
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        
        tableView.setContentOffset(currentOffset, animated: false)
    }
}
