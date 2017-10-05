//
//  STSingUpFirstStepController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 9/23/17.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import SHSPhoneComponent

class STSingUpFirstStepController: STSingUpBaseController {
    
    private var phoneNumber: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tableView.register(nibClass: STLoginLogoTableViewCell.self)
        self.tableView.register(nibClass: STLoginTableViewCell.self)
        self.tableView.register(nibClass: STClickableLabelCell.self)
    }
    
    override func actionNext() {
        
        super.actionNext()
        
        if let phone = self.phoneNumber {
            
            self.startAnimating()
            self.makeCodeRequest(phone: phone)
        }
    }
    
    // MARK: Private methods
    
    fileprivate func makeCodeRequest(phone: String) {
        
        self.analytics.logEvent(eventName: st_eCode)
        self.startAnimating()
        
        let deviceToken = AppDelegate.appSettings.deviceToken
        let deviceType = AppDelegate.appSettings.deviceType
        
        api.registration(phoneNumber: phone, deviceType: deviceType, deviceToken: deviceToken)
            .onSuccess(callback: { [unowned self] registration in
                
                self.stopAnimating()
                
                AppDelegate.appSettings.lastSessionPhoneNumber = phone
                self.st_router_sigUpStepTwo()
            })
            .onFailure(callback: { [unowned self] error in
                
                self.stopAnimating()
                
                self.showError(error: error)
                print(error)
            })
    }
    
    override func createDataSection() -> TableSection {
        
        let section = TableSection()
        
        section.add(cellClass: STLoginLogoTableViewCell.self)
        
        section.add(cellClass: STLoginTableViewCell.self) { [unowned self] (cell, item) in
            
            let viewCell = cell as! STLoginTableViewCell
            viewCell.selectionStyle = .none
            viewCell.contentView.backgroundColor = UIColor.stWhite20Opacity
            viewCell.title.textColor = UIColor.white
            viewCell.value.textColor = UIColor.white
            viewCell.value.formatter.setDefaultOutputPattern(" (###) ### ## ##")
            viewCell.value.formatter.prefix = "+7"
            
            let phoneNumberLength = 18
            
            let wcell = viewCell
            
            viewCell.value.textDidChangeBlock = { [unowned self] textfield in
                
                guard textfield!.text!.characters.count == phoneNumberLength else {
                    
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    return
                }
                
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.phoneNumber = wcell.value.phoneNumber()
            }
        }
        
        section.add(cellStyle: .default, bindingAction: { (cell, item) in
            
            cell.selectionStyle = .none
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
            cell.textLabel?.text = "login_page_action_send_password_description".localized
            cell.textLabel?.textColor = UIColor.stWhite70Opacity
            cell.backgroundColor = UIColor.clear
        })
        
        section.add(cellClass: STClickableLabelCell.self, bindingAction: { (cell, item) in
            
            let viewCell = cell as! STClickableLabelCell
            viewCell.backgroundColor = UIColor.clear
            viewCell.selectionStyle = .none
            
            let text = String(format: "login_page_offer_text".localized,
                              "login_policy_text".localized,
                              "login_terms_text".localized,
                              "login_personal_data_processing".localized)
            
            let style = NSNumber(integerLiteral: NSUnderlineStyle.styleSingle.rawValue)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributedText = NSMutableAttributedString(string: text,
                                                           attributes: [ NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11),
                                                                         NSAttributedStringKey.foregroundColor : UIColor.stWhite70Opacity,
                                                                         NSAttributedStringKey.paragraphStyle : paragraphStyle ])
            
            let range1 = attributedText.mutableString.range(of: "login_policy_text".localized, options: .caseInsensitive)
            let range2 = attributedText.mutableString.range(of: "login_terms_text".localized, options: .caseInsensitive)
            let range3 = attributedText.mutableString.range(of: "login_personal_data_processing".localized, options: .caseInsensitive)
            
            let attr: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 11),
                                                       NSAttributedStringKey.foregroundColor : UIColor.stWhite70Opacity,
                                                       NSAttributedStringKey.underlineColor : UIColor.stWhite70Opacity,
                                                       NSAttributedStringKey.underlineStyle : style]
            
            attributedText.setAttributes(attr, range: range1)
            attributedText.setAttributes(attr, range: range2)
            attributedText.setAttributes(attr, range: range3)
            
            viewCell.clickableLabel.attributedText = attributedText
            viewCell.clickableLabel.clikableRanges = [range1, range2, range3]
            viewCell.clickableLabel.onTextClikAction = { range in
                
                switch (range.location, range.length) {
                    
                case (range1.location, range1.length):
                    
                    if let path = Bundle.main.path(forResource: "policy", ofType: "pdf") {
                        
                        self.st_router_openDocumentController(url: URL(fileURLWithPath: path), title: "settings_privacy_policy_text".localized)
                    }
                    
                    break
                    
                case (range2.location, range2.length):
                    
                    print("open terms")
                    
                    if let path = Bundle.main.path(forResource: "terms", ofType: "pdf") {
                        
                        self.st_router_openDocumentController(url: URL(fileURLWithPath: path), title: "settings_terms_&_condictions_text".localized)
                    }
                    
                    break
                    
                case (range3.location, range3.length):
                    
                    if let path = Bundle.main.path(forResource: "agreement", ofType: "pdf") {
                        
                        self.st_router_openDocumentController(url: URL(fileURLWithPath: path),
                                                              title: "settings_processing_personal_data_text".localized)
                    }
                    
                    break
                    
                default:
                    break
                }
            }
        })
        
        return section
    }
}
