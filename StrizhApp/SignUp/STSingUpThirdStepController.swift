//
//  STSingUpThirdStepController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 9/23/17.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

class STSingUpThirdStepController: STSingUpBaseController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

    private var observableImage = Observable(UIImage())
    
    private var textFieldObservable = Observable(false)
    
    private var userImage: UIImage?
    
    private var userFirstName = ""
    
    private var userLastName = ""
    
    
    override func rightNavigationItemText() -> String {
        
        return "action_done".localized
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(nibClass: STLoginAvatarTableViewCell.self)
        self.tableView.register(nibClass: STLoginTextTableViewCell.self)
        self.tableView.register(nibClass: STLoginSeparatorTableViewCell.self)
        
        self.navigationItem.hidesBackButton = true
    }
    
    // MARK: UITextFieldDelegate implementation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == 1 {
            
            self.textFieldObservable.value = true
        }
        else {
            
            self.view.endEditing(true)
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
    
    
    // MARK: - UIImagePickerControllerDelegate implementation
    
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
    
    override func actionNext() {
        
        super.actionNext()
        
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
    }
    
    override func createDataSection() -> TableSection {
        
        let section = TableSection()
        
        section.add(cellStyle: .default) { (cell, item) in
            
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
        
        section.add(cellClass: STLoginAvatarTableViewCell.self) { [unowned self] (cell, item) in
            
            let viewCell = cell as! STLoginAvatarTableViewCell
            viewCell.avatarButton.addTarget(self, action: #selector(self.choosePhoto(_:)), for: .touchUpInside)
            
            self.observableImage.observeNext { image in
                
                guard
                    
                    image.cgImage?.width != nil,
                    image.cgImage?.height != nil else {
                        
                        return
                }
                
                viewCell.avatarButton.setImage(image.af_imageRoundedIntoCircle(), for: .normal)
                
                if !self.userLastName.isEmpty && !self.userFirstName.isEmpty {
                    
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
                
            }.dispose(in: viewCell.disposeBag)
            
            item.validation = { [unowned self] in
                
                let image = self.observableImage.value
                
                guard
                    
                    image.cgImage?.width != nil,
                    image.cgImage?.height != nil
                    
                    else {
                        
                        return ValidationResult.onError(errorMessage: "Вы не выбрали аватарку")
                }
                
                return ValidationResult.onSuccess
            }
        }
        
        section.add(cellClass: STLoginTextTableViewCell.self) { [unowned self] (cell, item) in
            
            let viewCell = cell as! STLoginTextTableViewCell
            viewCell.selectionStyle = .none
            viewCell.contentView.backgroundColor = UIColor.stWhite20Opacity
            viewCell.title.text = "login_page_name_title".localized
            viewCell.title.textColor = UIColor.white
            viewCell.value.attributedPlaceholder = NSAttributedString(string: "login_page_enter_name_text".localized, attributes: [NSForegroundColorAttributeName : UIColor.stWhite70Opacity])
            viewCell.value.textColor = UIColor.white
            viewCell.value.tag = 1
            viewCell.value.delegate = self
        }
        
        section.add(cellClass: STLoginSeparatorTableViewCell.self)
        
        section.add(cellClass: STLoginTextTableViewCell.self) { [unowned self] (cell, item) in
            
            let viewCell = cell as! STLoginTextTableViewCell
            viewCell.selectionStyle = .none
            viewCell.title.text = "login_page_last_name_title".localized
            viewCell.title.textColor = UIColor.white
            viewCell.value.attributedPlaceholder = NSAttributedString(string: "login_page_last_name_action_text".localized, attributes: [NSForegroundColorAttributeName : UIColor.stWhite70Opacity])
            
            viewCell.value.textColor = UIColor.white
            viewCell.contentView.backgroundColor = UIColor.stWhite20Opacity
            viewCell.value.tag = 2
            viewCell.value.delegate = self
            
            self.textFieldObservable.observeNext{ [viewCell] result in
                
                if result != true {
                    
                    return
                }
                
                viewCell.value.becomeFirstResponder()
            }
            .dispose(in: viewCell.disposeBag)
        }
        
        return section
    }
    
    @objc private func choosePhoto(_ sender: UIButton) {
        
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
    
    private func submitUserInfo(_ callBack: @escaping (_ error: Error?) -> Void) {
        
        for item in self.dataSource.sections.first!.items {
            
            if let result = item.validation?() {
                
                if !result.valid {
                    
                    let error = STError.error(message: result.errorDescription!)
                    
                    callBack(error)
                    return
                }
            }
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
    
    private func updateUserInfo(firstName: String,
                                    lastName: String,
                                    imageId: Int64? = nil,
                                    callBack: @escaping (_ error: Error?) -> Void) {
        
        if let session = STSession.objects(by: STSession.self).first {
            
            api.updateUserInformation(transport: .websocket, userId: session.userId, firstName: firstName,
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
            
            fatalError("no session")
        }
    }
}
