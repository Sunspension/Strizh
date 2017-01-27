//
//  STSingUpViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 23/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import SHSPhoneComponent
import NVActivityIndicatorView

enum STSignUpStateEnum {
    
    case signupFirstStep
    
    case signupSecondStep
    
    case signupThirdStep
}

class STSingUpTableViewController: UITableViewController, NVActivityIndicatorViewable {
    
    private let dataSource = TableViewDataSource()
    
    private let logo = UIImageView(image: #imageLiteral(resourceName: "logo"))
    
    private var contentInset: UIEdgeInsets?
    
    private var signupStep: STSignUpStateEnum = .signupFirstStep
    
    private var phoneNumber: String?
    
    
    init(signupStep: STSignUpStateEnum) {
        
        self.signupStep = signupStep
        
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "photo"))
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsSelection = false;
        self.tableView.dataSource = dataSource
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        
        self.setCustomBackButton()
        
        self.tableView.register(nibClass: STLoginTableViewCell.self)
        self.tableView.register(nibClass: STLoginLogoTableViewCell.self)
        
        let rigthItem = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(self.actionNext))
        rigthItem.tintColor = UIColor.white
        rigthItem.isEnabled = false
        
        self.navigationItem.rightBarButtonItem = rigthItem
        
        let section = self.createDataSection()
        self.dataSource.sections.append(section)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        var naviHeight = UIApplication.shared.statusBarFrame.height
        
        if let barHeight = self.navigationController?.navigationBar.frame.size.height {
            
            naviHeight += barHeight
        }
        
        let offset = (self.tableView.frame.height - self.tableView.contentSize.height) / 2 - naviHeight
        
        self.tableView.contentInset = UIEdgeInsets(top: offset, left: 0, bottom: 0, right: 0)
    }
    
    
    // MARK: Private methods
    
    func actionNext() {
        
        self.view.endEditing(true)
        
        switch self.signupStep {
            
        case .signupFirstStep:
            
            if let phone = self.phoneNumber {
            
                startAnimating()
                
                api.registration(phoneNumber: phone, deviceType: deviceType, deviceToken: "xxxxxxxxxxxxxxxx")
                    .onSuccess(callback: {[unowned self] registration in
                        
                        self.stopAnimating()
                        
                        AppDelegate.appSettings.lastSessionPhoneNumber = phone
                        self.st_Router_SigUpStepTwo()
                        
                    })
                    .onFailure(callback: { error in
                        
                        print(error)
                    })
            }
            
            break
            
        case .signupSecondStep:
            
            self.st_Router_SigUpStepThree()
            break
            
        default:
            break
        }
    }
    
    func createDataSection() -> CollectionSection {
        
        var section = CollectionSection()
        
        switch self.signupStep {
            
        case .signupFirstStep:
            
            section.addItem(nibClass: STLoginLogoTableViewCell.self)
            
            section.addItem(nibClass: STLoginTableViewCell.self) { (cell, item) in
                
                let viewCell = cell as! STLoginTableViewCell
                viewCell.contentView.backgroundColor = UIColor.stWhite20Opacity
                viewCell.title.textColor = UIColor.white
                viewCell.value.textColor = UIColor.white
                viewCell.value.formatter.setDefaultOutputPattern(" (###) ### ## ##")
                viewCell.value.formatter.prefix = "+7"
                
                let phoneNumberLength = 18
                
                viewCell.value.textDidChangeBlock = {[unowned self] textfield in
                    
                    guard textfield!.text!.characters.count == phoneNumberLength else {
                        
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        return
                    }
                    
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.phoneNumber = viewCell.value.phoneNumber()
                }
            }
            
            section.addItem(cellStyle: .default, bindingAction: { (cell, item) in
                
                cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
                cell.textLabel?.text = "На ваш телефон будет оправлен пароль"
                cell.textLabel?.textColor = UIColor.stWhite70Opacity
                cell.backgroundColor = UIColor.clear
            })
            
            break
            
        case .signupSecondStep:
            
            section.addItem(nibClass: STLoginLogoTableViewCell.self)
            
            section.addItem(nibClass: STLoginTableViewCell.self) { (cell, item) in
                
                let viewCell = cell as! STLoginTableViewCell
                viewCell.title.textColor = UIColor.stWhite70Opacity
                viewCell.value.textColor = UIColor.stWhite70Opacity
                viewCell.value.formatter.setDefaultOutputPattern(" (###) ### ## ##")
                viewCell.value.formatter.prefix = "+7"
                
                if let phone = AppDelegate.appSettings.lastSessionPhoneNumber {
                    
                    viewCell.value.setFormattedText(String(phone.characters.dropFirst()))
                }
            }
            
            section.addItem(nibClass: STLoginTableViewCell.self) { (cell, item) in
                
                let viewCell = cell as! STLoginTableViewCell
                viewCell.contentView.backgroundColor = UIColor.stWhite20Opacity
                viewCell.title.textColor = UIColor.white
                viewCell.value.textColor = UIColor.white
                viewCell.title.text = "Пароль"
                viewCell.value.attributedPlaceholder = NSAttributedString(string: "Введите пароль из SMS", attributes: [NSForegroundColorAttributeName : UIColor.stWhite70Opacity])
                viewCell.value.isSecureTextEntry = true
            }
            
            break
            
        default:
            break
        }
        
        return section
    }
}
