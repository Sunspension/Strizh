//
//  STSingUpSecondStepController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 9/23/17.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

class STSingUpSecondStepController: STSingUpBaseController {

    private var password: String?
    
    private var countDownTimer: CountdownTimer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(nibClass: STLoginLogoTableViewCell.self)
        self.tableView.register(nibClass: STLoginTableViewCell.self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        let item = self.dataSource.item(by: indexPath)
        
        guard item.itemType as? Int == 99, item.allowAction == true else {
            
            return
        }
        
        self.analytics.logEvent(eventName: st_eGetCodeAgain)
        
        let phone = AppDelegate.appSettings.lastSessionPhoneNumber!
        self.makeCodeRequest(phone: phone)
    }
    
    override func actionNext() {
        
        super.actionNext()
        
        let phone = AppDelegate.appSettings.lastSessionPhoneNumber!
        
        let deviceToken = AppDelegate.appSettings.deviceToken
        let type = AppDelegate.appSettings.type
        let bundleId = AppDelegate.appSettings.bundleId!
        let systemVersion = AppDelegate.appSettings.systemVersion
        let appVersion  = AppDelegate.appSettings.applicationVersion!
        
        self.startAnimating()
        
        api.authorization(phoneNumber: phone,
                          deviceToken: deviceToken,
                          code: self.password!,
                          type: type,
                          application: bundleId,
                          systemVersion: systemVersion,
                          applicationVersion: appVersion)
            
            .onSuccess(callback: { [unowned self] session in
                
                // analytics
                self.analytics.setUserId(userId: session.userId)
                
                // write session
                session.writeToDB()
                self.st_router_onAuthorized()
                
                // check user
                self.api.loadUser(transport: .http, userId: session.userId)
                    
                    .onSuccess(callback: { [unowned self] user in
                        
                        self.stopAnimating()
                        
                        if user.firstName.isEmpty {
                            
                            self.analytics.logEvent(eventName: st_eWelcomeProfile, timed: true)
                            self.st_router_singUpPersonalInfo()
                            return
                        }
                        
                        user.writeToDB()
                        self.st_router_openMainController()
                    })
                    .onFailure(callback: { error in
                        
                        self.stopAnimating()
                        self.showError(error: error)
                    })
            })
            .onFailure(callback: { [unowned self] error in
                
                self.stopAnimating()
                self.showError(error: error)
            })
    }
    
    override func createDataSection() -> TableSection {
        
        let section = TableSection()
        
        section.add(cellClass: STLoginLogoTableViewCell.self)
        
        section.add(cellClass: STLoginTableViewCell.self) { (cell, item) in
            
            let viewCell = cell as! STLoginTableViewCell
            viewCell.selectionStyle = .none
            viewCell.title.textColor = UIColor.stWhite70Opacity
            viewCell.value.textColor = UIColor.stWhite70Opacity
            viewCell.value.formatter.setDefaultOutputPattern(" (###) ### ## ##")
            viewCell.value.formatter.prefix = "+7"
            viewCell.value.isUserInteractionEnabled = false
            
            if let phone = AppDelegate.appSettings.lastSessionPhoneNumber {
                
                viewCell.value.setFormattedText(String(phone.characters.dropFirst()))
            }
        }
        
        section.add(cellClass: STLoginTableViewCell.self) { [unowned self] (cell, item) in
            
            let viewCell = cell as! STLoginTableViewCell
            viewCell.selectionStyle = .none
            viewCell.contentView.backgroundColor = UIColor.stWhite20Opacity
            viewCell.title.textColor = UIColor.white
            viewCell.title.text = "login_page_password_text".localized
            
            viewCell.value.textColor = UIColor.white
            viewCell.value.formatter.setDefaultOutputPattern("######")
            
            let phoneNumberLength = 6
            
            let wcell = viewCell
            
            viewCell.value.textDidChangeBlock = {[unowned self] textfield in
                
                guard textfield!.text!.characters.count == phoneNumberLength else {
                    
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    return
                }
                
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.password = wcell.value.phoneNumber()
            }
            
            viewCell.value.attributedPlaceholder = NSAttributedString(string: "login_page_enter_password_from_text_messsage_text".localized, attributes: [NSForegroundColorAttributeName : UIColor.stWhite70Opacity])
            viewCell.value.isSecureTextEntry = true
        }
        
        section.add(itemType: 99, cellStyle: .default) { [unowned self] (cell, item) in
            
            cell.selectionStyle = .none
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
            cell.textLabel?.text = "login_page_resend_password_text".localized + "00:05"
            cell.textLabel?.textColor = UIColor.stWhite70Opacity
            cell.textLabel?.numberOfLines = 0
            cell.backgroundColor = UIColor.clear
            
            self.countDownTimer = CountdownTimer(seconds: 6) { time in
                
                guard time != nil else {
                    
                    item.allowAction = true
                    cell.textLabel?.text = "login_page_action_send_password_text".localized
                    cell.textLabel?.textColor = UIColor.white
                    return
                }
                
                item.allowAction = false
                cell.textLabel?.text = "login_page_resend_password_text".localized + "\(time!)"
            }
            
            self.countDownTimer?.preStartSetup = {
                
                cell.textLabel?.textColor = UIColor.stWhite70Opacity
                cell.textLabel?.text = "login_page_resend_password_text".localized + "00:05"
            }
            
            self.countDownTimer?.startTimer()
        }
        
        return section
    }
    
    // MARK: Private methods
    
    private func makeCodeRequest(phone: String) {
        
        self.analytics.logEvent(eventName: st_eCode)
        startAnimating()
        
        let deviceToken = AppDelegate.appSettings.deviceToken
        let deviceType = AppDelegate.appSettings.deviceType
        
        api.registration(phoneNumber: phone, deviceType: deviceType, deviceToken: deviceToken)
            .onSuccess(callback: { [unowned self] registration in
                
                self.stopAnimating()
                self.countDownTimer?.startTimer()
            })
            .onFailure(callback: { [unowned self] error in
                
                self.stopAnimating()
                
                self.showError(error: error)
                print(error)
        })
    }
}
