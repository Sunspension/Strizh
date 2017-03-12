//
//  STEditProfileController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 16/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage
import SHSPhoneComponent
import ReactiveKit
import Bond
import NVActivityIndicatorView

private enum EditProfileFieldsEnum {
    
    case firstName, lastName, email
}

class STEditProfileController: UITableViewController, UITextFieldDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate, NVActivityIndicatorViewable {
    
    private let dataSource = TableViewDataSource()
    
    private var userImageSection = CollectionSection()
    
    private var userInfoSection = CollectionSection()
    
    private var user: STUser?
    
    private var observableImage = Observable(UIImage())
    
    private var userImage: UIImage?
    
    private var firstName: String?
    
    private var lastName: String?
    
    private var email: String?
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    init() {
        
        super.init(style: .plain)
        
        self.user = STUser.objects(by: STUser.self).first
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.stLightBlueGrey
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.dataSource.sections.append(self.userImageSection)
        self.dataSource.sections.append(self.userInfoSection)
        
        self.tableView.dataSource = self.dataSource
        
        self.tableView.register(nibClass: STEditProfileHeaderCell.self)
        self.tableView.register(nibClass: STEditProfileTextCell.self)
        
        let rigthItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(self.save))
        
        let leftItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(self.close))
        
        self.navigationItem.rightBarButtonItem = rigthItem
        self.navigationItem.leftBarButtonItem = leftItem
        
        self.title = "Профиль"
        
        self.createDataSource()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
//        let originalImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        
        let croppedImage = info["UIImagePickerControllerEditedImage"] as! UIImage
        
        self.userImage = croppedImage
        self.observableImage.value = croppedImage
        
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
    }
    
    func save() {
        
        guard self.user != nil else {
            
            return
        }
        
        var errors = [String]()
        
        self.userInfoSection.items.forEach { item in
            
            if let valid = item.validation?().valid, valid == false {
                
                let itemType = item.itemType as! EditProfileFieldsEnum
                errors.append(itemType == .firstName ? "Имя" : "Фамилия")
            }
        }
        
        if errors.count > 0 {
            
            var message = ""
            
            if errors.count == 1 {
                
                message = "Поле \(errors[0]) не должно быть пустым"
            }
            else {
                
                message = "Поля \(errors[0]) и \(errors[1]) не должны быть пустыми"
            }
            
            self.showOkAlert(title: "Ошибка", message: message)
            
            return
        }
        
        self.startAnimating()
        
        self.submitUserInfo() { error in
            
            self.stopAnimating()
            
            guard error == nil else {
                
                self.showError(error: error!)
                return
            }
            
            NotificationCenter.default.post(Notification(name: Notification.Name(kUserUpdatedNotification)))
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func createDataSource() {
        
        self.userImageSection.addItem(cellClass: STEditProfileHeaderCell.self, item: self.user) { (cell, item) in
            
            if let user = self.user {
                
                let viewCell = cell as! STEditProfileHeaderCell
                viewCell.selectionStyle = .none
                viewCell.layoutMargins = UIEdgeInsets.zero
                viewCell.separatorInset = UIEdgeInsets.zero
                
                viewCell.userImage.reactive.tap.observe {[unowned viewCell, unowned self] _ in
                
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
                    
                    self.observableImage.observeNext{ image in
                        
                        guard image.cgImage?.width != nil, image.cgImage?.height != nil else {
                            
                            return
                        }
                        
                        viewCell.userImage.setImage(image, for: .normal)
                        
                    }.dispose(in: viewCell.bag)
                    
                    let choosePhotoAction = UIAlertAction(title: "Выбрать фото", style: .default) { [unowned self] action in
                        
                        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                            
                            self.showOkAlert(title: "Нет доступа к Фото",
                                             message: "Не удалось получить доступ к Фото на вашем устройстве")
                            return
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
                            
                            return
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
                    
                }.dispose(in: viewCell.bag)
                
                viewCell.deleteAvatar.reactive.tap.observe { [unowned viewCell, unowned self] _ in
                    
                    viewCell.userImage.setImage(UIImage(named: "avatar"), for: .normal)
                    self.userImage = nil
                    self.observableImage.value = UIImage()
                    
                }.dispose(in: viewCell.bag)
                
                if let data = user.imageData {
                    
                    viewCell.userImage.setImage(UIImage(data: data), for: .normal)
                    viewCell.userImage.makeCircular()
                }
                else {
                    
                    if !user.imageUrl.isEmpty {
                        
                        let width = Int(viewCell.userImage.bounds.size.width * UIScreen.main.scale)
                        let height = Int(viewCell.userImage.bounds.size.height * UIScreen.main.scale)
                        
                        let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                        
                        let urlString = user.imageUrl + queryResize
                        
                        let filter = RoundedCornersFilter(radius: viewCell.userImage.bounds.size.width)
                        viewCell.userImage.af_setImage(for: .normal, url: URL(string: urlString)!, filter: filter)
                    }
                }
            }
        }
        
        self.userInfoSection.addItem(cellClass: STEditProfileTextCell.self,
                                     item: self.user,
                                     itemType: EditProfileFieldsEnum.firstName) { (cell, item) in
                                        
                                        if let user = self.user {
                                            
                                            let viewCell = cell as! STEditProfileTextCell
                                            
                                            viewCell.title.text = "Имя"
                                            viewCell.value.placeholder = "Введите имя"
                                            viewCell.value.text = user.firstName
                                            viewCell.selectionStyle = .none
                                            viewCell.layoutMargins = UIEdgeInsets.zero
                                            viewCell.separatorInset = UIEdgeInsets.zero
                                            
                                            viewCell.value.reactive.text.observeNext { [unowned self] text in
                                                
                                                self.firstName = text
                                                
                                                }.dispose(in: viewCell.bag)
                                            
                                            item.validation = {
                                                
                                                if !viewCell.value.text!.isEmpty {
                                                    
                                                    return ValidationResult.onSuccess
                                                }
                                                
                                                return ValidationResult.onError(errorMessage: "Поле Имя не должно быть пустым")
                                            }
                                        }
        }
        
        self.userInfoSection.addItem(cellClass: STEditProfileTextCell.self,
                                     item: self.user,
                                     itemType: EditProfileFieldsEnum.lastName) { (cell, item) in
                                        
                                        if let user = self.user {
                                            
                                            let viewCell = cell as! STEditProfileTextCell
                                            
                                            viewCell.title.text = "Фамилия"
                                            viewCell.value.placeholder = "Введите фамилию"
                                            viewCell.value.text = user.lastName
                                            viewCell.selectionStyle = .none
                                            viewCell.layoutMargins = UIEdgeInsets.zero
                                            viewCell.separatorInset = UIEdgeInsets.zero
                                            
                                            viewCell.value.reactive.text.observeNext { [unowned self] text in
                                                
                                                self.lastName = text
                                                
                                            }.dispose(in: viewCell.bag)
                                            
                                            item.validation = {
                                                
                                                if !viewCell.value.text!.isEmpty {
                                                    
                                                    return ValidationResult.onSuccess
                                                }
                                                
                                                return ValidationResult.onError(errorMessage: "Поле Фамилия не должно быть пустым")
                                            }
                                        }
        }
        
        self.userInfoSection.addItem(cellClass: STEditProfileTextCell.self,
                                     item: self.user,
                                     itemType: EditProfileFieldsEnum.email) { (cell, item) in
                                        
                                        if let user = self.user {
                                            
                                            let viewCell = cell as! STEditProfileTextCell
                                            
                                            viewCell.title.text = "Почта"
                                            viewCell.value.placeholder = "Введите e-mail"
                                            viewCell.value.text = user.email
                                            viewCell.selectionStyle = .none
                                            viewCell.layoutMargins = UIEdgeInsets.zero
                                            viewCell.separatorInset = UIEdgeInsets.zero
                                            
                                            viewCell.value.reactive.text.observeNext { [unowned self] text in
                                                
                                                self.email = text
                                                
                                            }.dispose(in: viewCell.bag)
                                        }
        }
        
        self.userInfoSection.addItem(cellClass: STEditProfileTextCell.self,
                                     item: self.user,
                                     itemType: EditProfileFieldsEnum.email) { (cell, item) in
                                        
                                        if let user = self.user {
                                            
                                            let viewCell = cell as! STEditProfileTextCell
                                            
                                            viewCell.title.text = "Телефон"
                                            viewCell.value.placeholder = ""
                                            viewCell.selectionStyle = .none
                                            viewCell.layoutMargins = UIEdgeInsets.zero
                                            viewCell.separatorInset = UIEdgeInsets.zero
                                            
                                            let formatter = SHSPhoneNumberFormatter()
                                            
                                            formatter.prefix = "+7"
                                            formatter.setDefaultOutputPattern(" (###) ### ## ##")
                                            
                                            let phone = String(user.phone.characters.dropFirst())
                                            viewCell.value.text = formatter.formattedPhone(phone: phone)
                                            viewCell.value.isUserInteractionEnabled = false
                                            viewCell.title.textColor = UIColor.stPinkishGreyTwo
                                            viewCell.value.textColor = UIColor.stPinkishGreyTwo
                                            viewCell.contentView.backgroundColor = UIColor.stWhiteTwo
                                        }
        }
    }
    
    private func submitUserInfo(callBack: @escaping (_ error: Error?) -> Void) {
        
        if let image = self.userImage, let data = UIImageJPEGRepresentation(image, 1) {
            
            api.uploadImage(image: data, uploadProgress: nil)
                
                .onSuccess(callback: { [unowned self] imageResponse in
                    
                    let firstName = self.firstName ?? self.user!.firstName
                    let lastName = self.lastName ?? self.user!.lastName
                    let email = self.email ?? self.user!.email
                    
                    self.updateUserInfo(firstName: firstName,
                                        lastName: lastName,
                                        email: email,
                                        imageId: imageResponse.id,
                                        callBack: callBack)
                })
                .onFailure(callback: { error in
                    
                    callBack(error)
                })
        }
        else {
            
            if self.firstName == nil && self.lastName == nil && self.email == nil {
                
                return
            }
            
            let firstName = self.firstName ?? self.user!.firstName
            let lastName = self.lastName ?? self.user!.lastName
            let email = self.email ?? self.user!.email
            
            self.updateUserInfo(firstName: firstName,
                                lastName: lastName,
                                email: email,
                                callBack: callBack)
        }
    }
    
    private func updateUserInfo(firstName: String,
                                lastName: String,
                                email: String? = nil,
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
