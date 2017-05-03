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
import EmitterKit
import BrightFutures
import Bond

enum STSignUpStateEnum {
    
    case signupFirstStep
    
    case signupSecondStep
    
    case signupThirdStep
}

class STSingUpTableViewController: UITableViewController, NVActivityIndicatorViewable, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    fileprivate let dataSource = TableViewDataSource()
    
    fileprivate let logo = UIImageView(image: #imageLiteral(resourceName: "logo-login"))
    
    fileprivate var contentInset: UIEdgeInsets?
    
    fileprivate var signupStep: STSignUpStateEnum = .signupFirstStep
    
    fileprivate var phoneNumber: String?
    
    fileprivate var password: String?
    
    fileprivate var countDownTimer: CountdownTimer?
    
    fileprivate var observableImage = Observable(UIImage())
    
    fileprivate var textFieldEmitter = Event<Bool>()
    
    fileprivate var textFieldListener: EventListener<Bool>?
    
    fileprivate var userImage: UIImage?
    
    fileprivate var userFirstName = ""
    
    fileprivate var userLastName = ""

    
    deinit {
        
        print("deinit")
    }
    
    init(signupStep: STSignUpStateEnum) {
        
        super.init(style: .plain)
        
        self.signupStep = signupStep
        
        if signupStep == .signupThirdStep {
            
            self.navigationItem.hidesBackButton = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.signupStep == .signupFirstStep {
            
            self.analytics.logEvent(eventName: st_eAuth, timed: true)
        }
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = dataSource
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        
        self.tableView.register(nibClass: STLoginLogoTableViewCell.self)
        self.tableView.register(nibClass: STLoginTableViewCell.self)
        self.tableView.register(nibClass: STLoginAvatarTableViewCell.self)
        self.tableView.register(nibClass: STLoginTextTableViewCell.self)
        self.tableView.register(nibClass: STLoginSeparatorTableViewCell.self)
        
        let text = self.signupStep == .signupThirdStep ? "action_done".localized : "action_next".localized
        let rigthItem = UIBarButtonItem(title: text, style: .plain, target: self, action: #selector(self.actionNext))
        rigthItem.tintColor = UIColor.white
        rigthItem.isEnabled = false
        
        self.navigationItem.rightBarButtonItem = rigthItem
        
        self.setCustomBackButton()
        
        let section = self.createDataSection()
        self.dataSource.sections.append(section)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        var naviHeight = UIApplication.shared.statusBarFrame.height
        
        if let barHeight = self.navigationController?.navigationBar.frame.size.height {
            
            naviHeight += barHeight
        }
        
        let offset = (self.tableView.frame.height - (self.tableView.contentSize.height + naviHeight)) / 2
        
        guard offset > 64 else {
            
            return
        }
        
        self.tableView.contentInset = UIEdgeInsets(top: offset, left: 0, bottom: 0, right: 0)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        switch signupStep {
            
        case .signupSecondStep:
            
            let item = self.dataSource.item(by: indexPath)
            
            guard item.itemType as? Int == 99, item.allowAction == true else {
                
                return
            }
            
            self.analytics.logEvent(eventName: st_eGetCodeAgain)
            
            let phone = AppDelegate.appSettings.lastSessionPhoneNumber!
            self.makeCodeRequest(phone: phone)
            
        default:
            return
        }
    }
    
    // MARK: UITextFieldDelegate implementation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch self.signupStep {
            
        case .signupThirdStep:
            
            if textField.tag == 1 {
                
                self.textFieldEmitter.emit(true)
            }
            else {
                
                self.view.endEditing(true)
            }
            
            break
            
        default:
            break
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "" {
            
            if textField.tag == 2 {
                
                self.userLastName = String(self.userLastName.characters.dropLast())
            }
            
            if textField.tag == 1 {
                
                self.userFirstName = String(self.userFirstName.characters.dropLast())
            }
            
            if range.location == 0 {
                
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
            
            return true
        }
        
        if !string.trimmingCharacters(in: .whitespaces).isEmpty {
            
            if textField.tag == 2 {
                
                self.userLastName += string
            }
            
            if textField.tag == 1 {
                
                self.userFirstName += string
            }
            
            if self.userFirstName.characters.count > 0 && self.userLastName.characters.count > 0  {
                
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
            return true
        }
        
        return false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let croppedImage = info["UIImagePickerControllerEditedImage"] as! UIImage
        
        self.userImage = croppedImage
        self.observableImage.value = croppedImage
        
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Internal methods
    
    func actionNext() {
        
        self.view.endEditing(true)
        
        switch self.signupStep {
            
        case .signupFirstStep:
            
            if let phone = self.phoneNumber {
                
                self.startAnimating()
                self.makeCodeRequest(phone: phone)
            }
            
            break
            
        case .signupSecondStep:
            
            let phone = AppDelegate.appSettings.lastSessionPhoneNumber!
            
            let deviceToken = AppDelegate.appSettings.deviceToken ?? "xxxxxxxxxxxxxxxx"
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
                    
                    // check user
                    self.api.loadUser(transport: .http, userId: session.userId)
                        
                        .onSuccess(callback: { [unowned self] user in
                            
                            self.stopAnimating()
                            self.st_router_onAuthorized()
                            
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
                    
                    self.showError(error: error)
                })
            
            break
            
        case .signupThirdStep:
            
            self.startAnimating()
            
            self.analytics.endTimeEvent(eventName: st_eWelcomeProfile)
            self.analytics.logEvent(eventName: st_eSaveWelcomeProfile)
            
            self.submitUserInfo() { error in
                
                self.stopAnimating()
                
                guard error == nil else {
                    
                    self.showError(error: error!)
                    return
                }
                
                self.analytics.endTimeEvent(eventName: st_eAuth)
                self.st_router_openMainController()
            }
            
            break
        }
    }
    
    func choosePhoto(_ sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "action_cancel".localized, style: .cancel, handler: nil)
        
        let choosePhotoAction = UIAlertAction(title: "login_page_choose_photo_text".localized, style: .default) { [unowned self] action in
            
            if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                self.showOkAlert(title: "login_page_no_access_photo_title".localized,
                                 message: "login_page_no_access_photo_message".localized)
            }
            
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .photoLibrary
            pickerController.allowsEditing = true
            pickerController.delegate = self
            
            self.present(pickerController, animated: true, completion: nil)
        }
        
        let takePhotoAction = UIAlertAction(title: "login_page_take_photo_title".localized, style: .default) { [unowned self] action in
            
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                self.showOkAlert(title: "login_page_no_access_camera_title".localized,
                                 message: "login_page_no_access_camera_subtitle".localized)
                
            }
            
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .camera
            pickerController.allowsEditing = true
            pickerController.delegate = self
            
            self.present(pickerController, animated: true, completion: nil)
        }
        
        alert.addAction(choosePhotoAction)
        alert.addAction(takePhotoAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Private methods
    
    fileprivate func makeCodeRequest(phone: String) {
        
        self.analytics.logEvent(eventName: st_eCode)
        startAnimating()

        let deviceToken = AppDelegate.appSettings.deviceToken ?? "xxxxxxxxxxxxxxxx"
        let deviceType = AppDelegate.appSettings.deviceType
        
        api.registration(phoneNumber: phone, deviceType: deviceType, deviceToken: deviceToken)
            .onSuccess(callback: { [unowned self] registration in
                
                self.stopAnimating()
                
                switch self.signupStep {
                    
                case .signupFirstStep:
                    
                    AppDelegate.appSettings.lastSessionPhoneNumber = phone
                    self.st_router_sigUpStepTwo()
                    
                    break
                 
                case .signupSecondStep:
                    
                    self.countDownTimer?.startTimer()
                    
                    break
                    
                default:
                    break
                }
            })
            .onFailure(callback: { [unowned self] error in
                
                self.stopAnimating()
                
                self.showError(error: error)
                print(error)
            })
    }
    
    fileprivate func createDataSection() -> TableSection {
        
        let section = TableSection()
        
        switch self.signupStep {
            
        case .signupFirstStep:
            
            section.addItem(cellClass: STLoginLogoTableViewCell.self)
            
            section.addItem(cellClass: STLoginTableViewCell.self) { [unowned self] (cell, item) in
                
                let viewCell = cell as! STLoginTableViewCell
                viewCell.selectionStyle = .none
                viewCell.contentView.backgroundColor = UIColor.stWhite20Opacity
                viewCell.title.textColor = UIColor.white
                viewCell.value.textColor = UIColor.white
                viewCell.value.formatter.setDefaultOutputPattern(" (###) ### ## ##")
                viewCell.value.formatter.prefix = "+7"
                
                let phoneNumberLength = 18
                
                let wcell = viewCell
                
                viewCell.value.textDidChangeBlock = {[unowned self] textfield in
                    
                    guard textfield!.text!.characters.count == phoneNumberLength else {
                        
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        return
                    }
                    
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.phoneNumber = wcell.value.phoneNumber()
                }
            }
            
            section.addItem(cellStyle: .default, bindingAction: { (cell, item) in
                
                cell.selectionStyle = .none
                cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
                cell.textLabel?.text = "login_page_action_send_password_description".localized
                cell.textLabel?.textColor = UIColor.stWhite70Opacity
                cell.backgroundColor = UIColor.clear
            })
            
            break
            
        case .signupSecondStep:
            
            section.addItem(cellClass: STLoginLogoTableViewCell.self)
            
            section.addItem(cellClass: STLoginTableViewCell.self) { (cell, item) in
                
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
            
            section.addItem(cellClass: STLoginTableViewCell.self) { [unowned self] (cell, item) in
                
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
            
            section.addItem(cellStyle: .default, itemType: 99) { [unowned self] (cell, item) in
                
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
            
            break
        
        case .signupThirdStep:
            
            section.addItem(cellStyle: .default) { (cell, item) in
                
                cell.selectionStyle = .none
                cell.textLabel?.numberOfLines = 0
                cell.backgroundColor = UIColor.clear
                cell.textLabel?.textAlignment = .center
                
                let title = NSMutableAttributedString(string: "login_page_last_action_text1".localized,
                                                      attributes: [NSForegroundColorAttributeName : UIColor.white,
                                                                   NSFontAttributeName : UIFont.systemFont(ofSize: 16)])
                
                let text = "login_page_last_action_text2".localized
                
                let subtitle = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont.systemFont(ofSize: 13)])
                
                title.append(subtitle)
                cell.textLabel?.attributedText = title
            }
            
            section.addItem(cellClass: STLoginAvatarTableViewCell.self) { [unowned self] (cell, item) in
                
                let viewCell = cell as! STLoginAvatarTableViewCell
                viewCell.avatarButton.addTarget(self, action: #selector(self.choosePhoto(_:)), for: .touchUpInside)
                
                self.observableImage.observeNext{ image in
                    
                    guard
                        
                        image.cgImage?.width != nil,
                        image.cgImage?.height != nil else {
                        
                        return
                    }
                    
                    viewCell.avatarButton.setImage(image.af_imageRoundedIntoCircle(), for: .normal)
                    
                    }.dispose(in: viewCell.bag)
            }
            
            section.addItem(cellClass: STLoginTextTableViewCell.self) { [unowned self] (cell, item) in
                
                let viewCell = cell as! STLoginTextTableViewCell
                viewCell.selectionStyle = .none
                viewCell.contentView.backgroundColor = UIColor.stWhite20Opacity
                viewCell.title.text = "login_page_name_title".localized
                viewCell.title.textColor = UIColor.white
                viewCell.value.attributedPlaceholder = NSAttributedString(string: "login_page_enter_name_text".localized, attributes: [NSForegroundColorAttributeName : UIColor.stWhite70Opacity])
                viewCell.value.textColor = UIColor.white
                viewCell.value.tag = 1
                viewCell.value.delegate = self
                
                item.validation = { [unowned self] in
                    
                    if let text = viewCell.value.text {
                        
                        if !text.isEmpty {
                            
                            self.userFirstName = text
                            return ValidationResult.onSuccess
                        }
                    }
                    
                    return ValidationResult.onError(errorMessage: "")
                }
            }
            
            section.addItem(cellClass: STLoginSeparatorTableViewCell.self)
            
            section.addItem(cellClass: STLoginTextTableViewCell.self) { [unowned self] (cell, item) in
                
                let viewCell = cell as! STLoginTextTableViewCell
                viewCell.selectionStyle = .none
                viewCell.title.text = "login_page_last_name_title".localized
                viewCell.title.textColor = UIColor.white
                viewCell.value.attributedPlaceholder = NSAttributedString(string: "login_page_last_name_action_text".localized, attributes: [NSForegroundColorAttributeName : UIColor.stWhite70Opacity])
                
                viewCell.value.textColor = UIColor.white
                viewCell.contentView.backgroundColor = UIColor.stWhite20Opacity
                viewCell.value.tag = 2
                viewCell.value.delegate = self
                
                self.textFieldListener = self.textFieldEmitter.on({ [unowned viewCell] _ in
                    
                    viewCell.value.becomeFirstResponder()
                })
                
                item.validation = { [unowned self] in
                    
                    if let text = viewCell.value.text {
                        
                        if !text.isEmpty {
                            
                            self.userLastName = text
                            return ValidationResult.onSuccess
                        }
                    }
                    
                    return ValidationResult.onError(errorMessage: "")
                }
            }
            
            break
        }
        
        return section
    }
    
    fileprivate func submitUserInfo(_ callBack: @escaping (_ error: Error?) -> Void) {
        
        for item in self.dataSource.sections.first!.items {
            
            _ = item.validation?()
        }
        
        self.startAnimating()
        
        if let image = self.userImage, let data = UIImageJPEGRepresentation(image, 1) {
            
            api.uploadImage(image: data, uploadProgress: nil)
                
                .onSuccess(callback: { [unowned self] imageResponse in
                    
                    self.updateUserInfo(firstName: self.userFirstName, lastName: self.userLastName,
                                        imageId: imageResponse.id, callBack: callBack)
                })
                .onFailure(callback: { error in
                    
                    callBack(error)
                })
        }
        else {
            
            self.updateUserInfo(firstName: self.userFirstName, lastName: self.userLastName,
                                callBack: callBack)
        }
    }
    
    fileprivate func updateUserInfo(firstName: String,
                                lastName: String,
                                imageId: Int64? = nil,
                                callBack: @escaping (_ error: Error?) -> Void) {
        
        if let session = STSession.objects(by: STSession.self).first {
            
            api.updateUserInformation(transport: .webSocket, userId: session.userId, firstName: firstName,
                                      lastName: lastName, email: nil, imageId: imageId)
                .onSuccess(callback: { user in
                    
                    if let image = self.userImage {
                        
                        user.updateUserImageInDB(image: image)
                    }
                    
                    user.writeToDB()
                    callBack(nil)
                })
                .onFailure(callback: { error in
                    
                    callBack(error)
                })
        }
        else {
         
            // no session
            fatalError()
        }
    }
}
