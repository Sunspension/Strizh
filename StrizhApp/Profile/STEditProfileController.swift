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
    
    fileprivate let dataSource = TableViewDataSource()
    
    fileprivate var userImageSection = TableSection()
    
    fileprivate var userInfoSection = TableSection()
    
    fileprivate var user: STUser {
        
        return STUser.objects(by: STUser.self).first!
    }
    
    fileprivate var observableImage = Observable(UIImage())
    
    fileprivate var userImage: UIImage?
    
    fileprivate var firstName: String?
    
    fileprivate var lastName: String?
    
    fileprivate var email: String?
    
    fileprivate var deleteAvatar = false
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    init() {
        
        super.init(style: .plain)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.analytics.logEvent(eventName: st_eProfileEdit, timed: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.analytics.endTimeEvent(eventName: st_eProfileEdit)
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
        
        let rigthItem = UIBarButtonItem(title: "action_save".localized, style: .plain, target: self, action: #selector(self.save))
        
        let leftItem = UIBarButtonItem(title: "action_close".localized, style: .plain, target: self, action: #selector(self.close))
        
        self.navigationItem.rightBarButtonItem = rigthItem
        self.navigationItem.leftBarButtonItem = leftItem
        
        self.title = "profile_edit_page_title".localized
        
        self.createDataSource()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image = info["UIImagePickerControllerOriginalImage"] as! UIImage
        
        if picker.sourceType != .camera {
            
            image = info["UIImagePickerControllerEditedImage"] as! UIImage
        }
        
        self.userImage = image
        self.observableImage.value = image
        
        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
    }
    
    func save() {
        
        var errors = [String]()
        
        self.userInfoSection.items.forEach { item in
            
            if let valid = item.validation?().valid, valid == false {
                
                let itemType = item.itemType as! EditProfileFieldsEnum
                errors.append(itemType == .firstName
                    ? "login_page_name_title".localized
                    : "login_page_last_name_title".localized)
            }
        }
        
        if errors.count > 0 {
            
            var message = ""
            
            if errors.count == 1 {
                
                message = String(format: "profile_edit_empty_field_text".localized, "\(errors[0])")
            }
            else {
                
                message = String(format: "profile_edit_empty_fields_text".localized, "\(errors[0])", "\(errors[1])")
            }
            
            self.showOkAlert(title: "alert_title_error".localized, message: message)
            
            return
        }
        
        self.startAnimating()
        
        self.submitUserInfo() { error in
            
            self.stopAnimating()
            
            guard error == nil else {
                
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            self.analytics.logEvent(eventName: st_eSaveProfile)
            
            NotificationCenter.default.post(Notification(name: Notification.Name(kUserUpdatedNotification)))
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func createDataSource() {
        
        self.userImageSection.add(item: self.user, cellClass: STEditProfileHeaderCell.self) { (cell, item) in
            
            let viewCell = cell as! STEditProfileHeaderCell
            
            viewCell.selectionStyle = .none
            viewCell.layoutMargins = UIEdgeInsets.zero
            viewCell.separatorInset = UIEdgeInsets.zero
            viewCell.deleteAvatar.setTitle("profile_edit_delete_avatar_title".localized, for: .normal)
            
            viewCell.userImage.reactive.tap.observe {[unowned viewCell, unowned self] _ in
                
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "action_cancel".localized, style: .cancel, handler: nil)
                
                self.observableImage.observeNext{ image in
                    
                    guard image.cgImage?.width != nil, image.cgImage?.height != nil else {
                        
                        return
                    }
                    
                    viewCell.userImage.setImage(image.af_imageRoundedIntoCircle(), for: .normal)
                    self.deleteAvatar = false
                    
                    }.dispose(in: viewCell.disposeBag)
                
                let choosePhotoAction = UIAlertAction(title: "login_page_choose_photo_text".localized, style: .default) { [unowned self] action in
                    
                    if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        
                        self.showOkAlert(title: "login_page_no_access_photo_title".localized,
                                         message: "login_page_no_access_photo_message".localized)
                        return
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
                        
                        return
                    }
                    
                    let pickerController = UIImagePickerController()
                    pickerController.sourceType = .camera
                    pickerController.delegate = self
                    
                    self.present(pickerController, animated: true, completion: nil)
                }
                
                alert.addAction(choosePhotoAction)
                alert.addAction(takePhotoAction)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
                
                }.dispose(in: viewCell.disposeBag)
            
            viewCell.deleteAvatar.reactive.tap.observe { [unowned viewCell, unowned self] _ in
                
                var defaultImage = UIImage(named: "avatar")
                defaultImage = defaultImage?.af_imageAspectScaled(toFill: viewCell.userImage.bounds.size)
                viewCell.userImage.setImage(defaultImage?.af_imageRoundedIntoCircle(), for: .normal)
                
                self.userImage = nil
                self.observableImage.value = UIImage()
                self.deleteAvatar = true
                
                }.dispose(in: viewCell.disposeBag)
            
            if let data = self.user.imageData {
                
                if let image = UIImage(data: data) {
                    
                    let userIcon = image.af_imageAspectScaled(toFill: viewCell.userImage.bounds.size)
                    viewCell.userImage.setImage(userIcon.af_imageRoundedIntoCircle(), for: .normal)
                }
            }
            else {
                
                if !self.user.imageUrl.isEmpty {
                    
                    let urlString = self.user.imageUrl + viewCell.userImage.queryResizeString()
                    
                    let filter = RoundedCornersFilter(radius: viewCell.userImage.bounds.size.width)
                    viewCell.userImage.af_setImage(for: .normal, url: URL(string: urlString)!, filter: filter)
                }
                else {
                    
                    var defaultImage = UIImage(named: "avatar")
                    defaultImage = defaultImage?.af_imageAspectScaled(toFill: viewCell.userImage.bounds.size)
                    viewCell.userImage.setImage(defaultImage?.af_imageRoundedIntoCircle(), for: .normal)
                }
            }
        }
        
        self.userInfoSection.add(item: self.user,
                                 itemType: EditProfileFieldsEnum.firstName,
                                 cellClass: STEditProfileTextCell.self) { (cell, item) in
                                    
                                    let viewCell = cell as! STEditProfileTextCell
                                    let user = item.item as! STUser
                                    
                                    viewCell.title.text = "login_page_name_title".localized
                                    viewCell.value.placeholder = "login_page_enter_name_text".localized
                                    viewCell.value.text = user.firstName
                                    viewCell.selectionStyle = .none
                                    viewCell.layoutMargins = UIEdgeInsets.zero
                                    viewCell.separatorInset = UIEdgeInsets.zero
                                    
                                    viewCell.value.reactive.text.observeNext { [unowned self] text in
                                        
                                        self.firstName = text
                                        
                                        }.dispose(in: viewCell.disposeBag)
                                    
                                    item.validation = {
                                        
                                        if !viewCell.value.text!.isEmpty {
                                            
                                            return ValidationResult.onSuccess
                                        }
                                        
                                        return ValidationResult.onError(errorMessage: "profile_edit_page_error_empty_first_name_text".localized)
                                    }
        }
        
        self.userInfoSection.add(item: self.user,
                                 itemType: EditProfileFieldsEnum.lastName,
                                 cellClass: STEditProfileTextCell.self) { (cell, item) in
                                    
                                    let viewCell = cell as! STEditProfileTextCell
                                    let user = item.item as! STUser
                                    
                                    viewCell.title.text = "login_page_last_name_title".localized
                                    viewCell.value.placeholder = "login_page_last_name_action_text".localized
                                    viewCell.value.text = user.lastName
                                    viewCell.selectionStyle = .none
                                    viewCell.layoutMargins = UIEdgeInsets.zero
                                    viewCell.separatorInset = UIEdgeInsets.zero
                                    
                                    viewCell.value.reactive.text.observeNext { [unowned self] text in
                                        
                                        self.lastName = text
                                        
                                        }.dispose(in: viewCell.disposeBag)
                                    
                                    item.validation = {
                                        
                                        if !viewCell.value.text!.isEmpty {
                                            
                                            return ValidationResult.onSuccess
                                        }
                                        
                                        return ValidationResult.onError(errorMessage: "profile_edit_page_error_empty_last_name_text".localized)
                                    }
        }
        
        self.userInfoSection.add(item: self.user,
                                 itemType: EditProfileFieldsEnum.email,
                                 cellClass: STEditProfileTextCell.self) { (cell, item) in
                                    
                                    let viewCell = cell as! STEditProfileTextCell
                                    let user = item.item as! STUser
                                    
                                    viewCell.title.text = "profile_edit_email_text".localized
                                    viewCell.value.placeholder = "profile_edit_email_placeholder".localized
                                    viewCell.value.text = user.email
                                    viewCell.selectionStyle = .none
                                    viewCell.layoutMargins = UIEdgeInsets.zero
                                    viewCell.separatorInset = UIEdgeInsets.zero
                                    
                                    viewCell.value.reactive.text.observeNext { [unowned self] text in
                                        
                                        self.email = text
                                        
                                        }.dispose(in: viewCell.disposeBag)
        }
        
        self.userInfoSection.add(item: self.user,
                                 cellClass: STEditProfileTextCell.self) { (cell, item) in
                                    
                                    let viewCell = cell as! STEditProfileTextCell
                                    let user = item.item as! STUser
                                    
                                    viewCell.title.text = "login_page_phone_title".localized
                                    viewCell.value.placeholder = ""
                                    viewCell.selectionStyle = .none
                                    viewCell.layoutMargins = UIEdgeInsets.zero
                                    viewCell.separatorInset = UIEdgeInsets.zero
                                    
                                    let formatter = SHSPhoneNumberFormatter()
                                    
                                    formatter.prefix = "+7"
                                    formatter.setDefaultOutputPattern(" (###) ### ## ##")
                                    
                                    let phone = String(user.phone.characters.dropFirst())
                                    viewCell.value.text = formatter.formattedPhone(phone)
                                    viewCell.value.isUserInteractionEnabled = false
                                    viewCell.title.textColor = UIColor.stPinkishGreyTwo
                                    viewCell.value.textColor = UIColor.stPinkishGreyTwo
                                    viewCell.contentView.backgroundColor = UIColor.stWhiteTwo
        }
    }
    
    private func submitUserInfo(callBack: @escaping (_ error: Error?) -> Void) {
        
        if let image = self.userImage, let data = UIImageJPEGRepresentation(image, 1) {
            
            api.uploadImage(image: data, uploadProgress: nil)
                
                .onSuccess(callback: { [unowned self] imageResponse in
                    
                    self.analytics.logEvent(eventName: st_eSetAvatar)
                    
                    let firstName = self.firstName ?? self.user.firstName
                    let lastName = self.lastName ?? self.user.lastName
                    let email = self.email ?? self.user.email
                    
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
            
            if self.firstName == nil && self.lastName == nil
                && self.email == nil && self.deleteAvatar == false {
                
                return
            }
            
            let firstName = self.firstName ?? self.user.firstName
            let lastName = self.lastName ?? self.user.lastName
            let email = self.email ?? self.user.email
            
            if self.deleteAvatar {
                
                self.updateUserInfo(firstName: firstName,
                                    lastName: lastName,
                                    email: email,
                                    imageId: 0,
                                    callBack: callBack)
                return
            }
            
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
            
            api.updateUserInformation(transport: .websocket, userId: session.userId, firstName: firstName,
                                      lastName: lastName, email: email, imageId: imageId)
                .onSuccess(callback: { user in
                    
                    if let image = self.userImage {
                        
                        user.updateUserImageInDB(image: image)
                    }
                    else if self.deleteAvatar {
                        
                        user.updateUserImageInDB(image: nil)
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
