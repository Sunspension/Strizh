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

enum STSignUpStateEnum {
    
    case signupFirstStep
    
    case signupSecondStep
    
    case signupThirdStep
}

class STSingUpTableViewController: UITableViewController, NVActivityIndicatorViewable, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    private let dataSource = TableViewDataSource()
    
    private let logo = UIImageView(image: #imageLiteral(resourceName: "logo-login"))
    
    private var contentInset: UIEdgeInsets?
    
    private var signupStep: STSignUpStateEnum = .signupFirstStep
    
    private var phoneNumber: String?
    
    private var password: String?
    
    private var countDownTimer: CountdownTimer?
    
    private var imageEmitter = Event<UIImage>()
    
    private var imageListener: EventListener<UIImage>?
    
    private var textFieldEmitter = Event<Bool>()
    
    private var textFieldListener: EventListener<Bool>?
    
    private var userImage: UIImage?
    
    private var userFirstName = ""
    
    private var userLastName = ""

    
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
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = dataSource
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        
        self.tableView.register(cell: STLoginLogoTableViewCell.self)
        self.tableView.register(cell: STLoginTableViewCell.self)
        self.tableView.register(cell: STLoginAvatarTableViewCell.self)
        self.tableView.register(cell: STLoginTextTableViewCell.self)
        self.tableView.register(cell: STLoginSeparatorTableViewCell.self)
        
        let text = self.signupStep == .signupThirdStep ? "Готово" : "Далее"
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
        
        let originalImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        let rectValue = info["UIImagePickerControllerCropRect"] as? NSValue
        
        if let cropRect = rectValue?.cgRectValue {
            
            let croppedImage = originalImage.cgImage!.cropping(to: cropRect)
            
            if let cropped = croppedImage {
                
                let image = UIImage(cgImage: cropped)
                self.userImage = image
                self.imageEmitter.emit(image)
            }
        }
        
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
                    
                    // check user
                    self.api.loadUser(transport: .http, userId: session.userId)
                        
                        .onSuccess(callback: { [unowned self] user in
                            
                            self.stopAnimating()
                            
                            session.writeToDB()
                            
                            if user.firstName.isEmpty {
                                
                                self.st_router_sigUpFinish()
                                return
                            }
                            
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
            
            self.submitUserInfo() { error in
                
                self.stopAnimating()
                
                guard error == nil else {
                    
                    self.showError(error: error!)
                    return
                }
                
                self.st_router_openMainController()
            }
            
            break
        }
    }
    
    func choosePhoto(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        let choosePhotoAction = UIAlertAction(title: "Выбрать фото", style: .default) { [unowned self] action in
            
            if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                self.showOkAlert(title: "Нет доступа к Фото",
                                 message: "Не удалось получить доступ к Фото на вашем устройстве")
            }
            
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .photoLibrary
            pickerController.allowsEditing = true
            pickerController.delegate = self
            
            self.present(pickerController, animated: true, completion: nil)
        }
        
        let takePhotoAction = UIAlertAction(title: "Сделать фото", style: .default) { [unowned self] action in
            
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                self.showOkAlert(title: "Нет доступа к Камере",
                                 message: "Не удалось получить доступ к Камере на вашем устройстве")
                
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
    
    private func makeCodeRequest(phone: String) {
        
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
    
    private func createDataSection() -> CollectionSection {
        
        let section = CollectionSection()
        
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
                cell.textLabel?.text = "На ваш телефон будет оправлен пароль"
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
                viewCell.title.text = "Пароль"
                
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
                
                viewCell.value.attributedPlaceholder = NSAttributedString(string: "Введите пароль из SMS", attributes: [NSForegroundColorAttributeName : UIColor.stWhite70Opacity])
                viewCell.value.isSecureTextEntry = true
            }
            
            section.addItem(cellStyle: .default, itemType: 99) { [unowned self] (cell, item) in
                
                cell.selectionStyle = .none
                cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
                cell.textLabel?.text = "Отправить пароль еще раз через 00:05"
                cell.textLabel?.textColor = UIColor.stWhite70Opacity
                cell.textLabel?.numberOfLines = 0
                cell.backgroundColor = UIColor.clear
                
                self.countDownTimer = CountdownTimer(seconds: 6) { time in
                    
                    guard time != nil else {
                        
                        item.allowAction = true
                        cell.textLabel?.text = "Отправить пароль"
                        cell.textLabel?.textColor = UIColor.white
                        return
                    }
                    
                    item.allowAction = false
                    cell.textLabel?.text = "Отправить пароль еще раз через \(time!)"
                }
                
                self.countDownTimer?.preStartSetup = {
                    
                    cell.textLabel?.textColor = UIColor.stWhite70Opacity
                    cell.textLabel?.text = "Отправить пароль еще раз через 00:05"
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
                
                let title = NSMutableAttributedString(string: "Осталось немного!\n\n",
                                                      attributes: [NSForegroundColorAttributeName : UIColor.white,
                                                                   NSFontAttributeName : UIFont.systemFont(ofSize: 16)])
                
                let text = "Выберите картинку для профиля и заполните поля."
                
                let subtitle = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont.systemFont(ofSize: 13)])
                
                title.append(subtitle)
                cell.textLabel?.attributedText = title
            }
            
            section.addItem(cellClass: STLoginAvatarTableViewCell.self) { [unowned self] (cell, item) in
                
                let viewCell = cell as! STLoginAvatarTableViewCell
                viewCell.avatarButton.makeCircular()
                viewCell.avatarButton.addTarget(self, action: #selector(self.choosePhoto(_:)), for: .touchUpInside)
                
                self.imageListener = self.imageEmitter.on({ [unowned viewCell] image in
                    
                    viewCell.avatarButton.setImage(image, for: .normal)
                })
            }
            
            section.addItem(cellClass: STLoginTextTableViewCell.self) { [unowned self] (cell, item) in
                
                let viewCell = cell as! STLoginTextTableViewCell
                viewCell.selectionStyle = .none
                viewCell.contentView.backgroundColor = UIColor.stWhite20Opacity
                viewCell.title.text = "Имя"
                viewCell.title.textColor = UIColor.white
                viewCell.value.attributedPlaceholder = NSAttributedString(string: "Введите имя", attributes: [NSForegroundColorAttributeName : UIColor.stWhite70Opacity])
                viewCell.value.textColor = UIColor.white
                viewCell.value.tag = 1
                viewCell.value.delegate = self
                
                item.validation = { [unowned self] in
                    
                    if let text = viewCell.value.text {
                        
                        if !text.isEmpty {
                            
                            self.userFirstName = text
                            return true
                        }
                    }
                    
                    return false
                }
            }
            
            section.addItem(cellClass: STLoginSeparatorTableViewCell.self)
            
            section.addItem(cellClass: STLoginTextTableViewCell.self) { [unowned self] (cell, item) in
                
                let viewCell = cell as! STLoginTextTableViewCell
                viewCell.selectionStyle = .none
                viewCell.title.text = "Фамилия"
                viewCell.title.textColor = UIColor.white
                viewCell.value.attributedPlaceholder = NSAttributedString(string: "Введите фамилию", attributes: [NSForegroundColorAttributeName : UIColor.stWhite70Opacity])
                
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
                            return true
                        }
                    }
                    
                    return false
                }
            }
            
            break
        }
        
        return section
    }
    
    private func submitUserInfo(callBack: @escaping (_ error: Error?) -> Void) {
        
        for item in self.dataSource.sections.first!.items {
            
            _ = item.validation?()
        }
        
        self.startAnimating()
        
        if let image = self.userImage {
            
            api.uploadImage(image: image)
                
                .onSuccess(callback: { [unowned self] imageResponse in
                    
                    let imageUrlString = imageResponse.url
                    print(imageUrlString)
                    
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
    
    private func updateUserInfo(firstName: String,
                                lastName: String,
                                imageId: Int64? = nil,
                                callBack: @escaping (_ error: Error?) -> Void) {
        
        if let session = STSession.objects(by: STSession.self).first {
            
            api.updateUserInformation(transport: .http, userId: session.userId, firstName: firstName,
                                      lastName: lastName, email: nil, imageId: imageId)
                .onSuccess(callback: { user in
                    
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
