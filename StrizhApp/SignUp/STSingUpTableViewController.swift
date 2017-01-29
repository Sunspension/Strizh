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

enum STSignUpStateEnum {
    
    case signupFirstStep
    
    case signupSecondStep
    
    case signupThirdStep
}

class STSingUpTableViewController: UITableViewController, NVActivityIndicatorViewable, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let dataSource = TableViewDataSource()
    
    private let logo = UIImageView(image: #imageLiteral(resourceName: "logo-login"))
    
    private var contentInset: UIEdgeInsets?
    
    private var signupStep: STSignUpStateEnum = .signupFirstStep
    
    private var phoneNumber: String?
    
    private var countDownTimer: CountdownTimer?
    
    var userImage: UIImage?
    
    private var emitter = Event<UIImage>()
    
    private var listener: EventListener<UIImage>?
    
    
    deinit {
        
        print("deinit")
    }
    
    init(signupStep: STSignUpStateEnum) {
        
        super.init(style: .plain)
        
        self.signupStep = signupStep
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
        
        let rigthItem = UIBarButtonItem(title: "Далее", style: .plain, target: self, action: #selector(self.actionNext))
        rigthItem.tintColor = UIColor.white
        rigthItem.isEnabled = false
        
        self.navigationItem.rightBarButtonItem = rigthItem
        
        self.setCustomBackButton()
        
        self.tableView.register(nibClass: STLoginTableViewCell.self)
        self.tableView.register(nibClass: STLoginLogoTableViewCell.self)
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
        
        switch signupStep {
            
        case .signupSecondStep:
            
            let item = self.dataSource.item(by: indexPath)
            
            guard item.itemType as? Int == 99, item.allowAction == true else {
                
                return
            }
            
            let phone = AppDelegate.appSettings.lastSessionPhoneNumber
            self.makeCodeRequest(phone: phone)
            
//            if let phone = AppDelegate.appSettings.lastSessionPhoneNumber {
//                
//                self.makeCodeRequest(phone: phone)
//            }
            
        default:
            return
        }
    }
    
    // MARK: Private methods
    
    func makeCodeRequest(phone: String?) {
        
        self.countDownTimer?.startTimer()
        
//        startAnimating()
//
//        api.registration(phoneNumber: phone, deviceType: deviceType, deviceToken: "xxxxxxxxxxxxxxxx")
//            .onSuccess(callback: {[unowned self] registration in
//
//                self.stopAnimating()
//
//                AppDelegate.appSettings.lastSessionPhoneNumber = phone
//                self.st_Router_SigUpStepTwo()
//
//            })
//            .onFailure(callback: { error in
//
//                print(error)
//            })
    }
    
    func actionNext() {
        
        self.view.endEditing(true)
        
        switch self.signupStep {
            
        case .signupFirstStep:
            
            if let phone = self.phoneNumber {
            
                self.st_Router_SigUpStepTwo()
                
//                startAnimating()
//                
//                api.registration(phoneNumber: phone, deviceType: deviceType, deviceToken: "xxxxxxxxxxxxxxxx")
//                    .onSuccess(callback: {[unowned self] registration in
//                        
//                        self.stopAnimating()
//                        
//                        AppDelegate.appSettings.lastSessionPhoneNumber = phone
//                        self.st_Router_SigUpStepTwo()
//                        
//                    })
//                    .onFailure(callback: { error in
//                        
//                        print(error)
//                    })
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
        
        let section = CollectionSection()
        
        switch self.signupStep {
            
        case .signupFirstStep:
            
            section.addItem(nibClass: STLoginLogoTableViewCell.self)
            
            section.addItem(nibClass: STLoginTableViewCell.self) { [unowned self] (cell, item) in
                
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
            
            section.addItem(nibClass: STLoginLogoTableViewCell.self)
            
            section.addItem(nibClass: STLoginTableViewCell.self) { (cell, item) in
                
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
            
            section.addItem(nibClass: STLoginTableViewCell.self) { [unowned self] (cell, item) in
                
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
                    self.phoneNumber = wcell.value.phoneNumber()
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
                
                let text = "Заполните поля и выберите аватар, либо пропустите этот шаг."
                
                let subtitle = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont.systemFont(ofSize: 13)])
                
                title.append(subtitle)
                cell.textLabel?.attributedText = title
            }
            
            section.addItem(nibClass: STLoginAvatarTableViewCell.self) { [unowned self] (cell, item) in
            
                let viewCell = cell as! STLoginAvatarTableViewCell
                viewCell.avatarButton.addTarget(self, action: #selector(self.choosePhoto(_:)), for: .touchUpInside)
                
                self.listener = self.emitter.on({ image in
                    
                    viewCell.avatarButton.setImage(image, for: .normal)
                })
            }
            
            section.addItem(nibClass: STLoginTextTableViewCell.self) { (cell, item) in
                
                let viewCell = cell as! STLoginTextTableViewCell
                viewCell.selectionStyle = .none
                viewCell.contentView.backgroundColor = UIColor.stWhite20Opacity
                viewCell.title.text = "Имя"
                viewCell.title.textColor = UIColor.white
                viewCell.value.attributedPlaceholder = NSAttributedString(string: "Введите имя", attributes: [NSForegroundColorAttributeName : UIColor.stWhite70Opacity])
                viewCell.value.textColor = UIColor.white
            }
            
            section.addItem(nibClass: STLoginSeparatorTableViewCell.self)
            
            section.addItem(nibClass: STLoginTextTableViewCell.self) { (cell, item) in
                
                let viewCell = cell as! STLoginTextTableViewCell
                viewCell.selectionStyle = .none
                viewCell.title.text = "Фамилия"
                viewCell.title.textColor = UIColor.white
                viewCell.value.attributedPlaceholder = NSAttributedString(string: "Введите фамилию", attributes: [NSForegroundColorAttributeName : UIColor.stWhite70Opacity])
                
                viewCell.value.textColor = UIColor.white
                viewCell.contentView.backgroundColor = UIColor.stWhite20Opacity
            }
            
            break
        }
        
        return section
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
                self.emitter.emit(image)
            }
        }
        
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}
