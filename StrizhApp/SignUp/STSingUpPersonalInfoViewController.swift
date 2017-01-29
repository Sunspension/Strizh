//
//  STSingUpPersonalInfoViewController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 30/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import EmitterKit
import NVActivityIndicatorView

class STSingUpPersonalInfoViewController: UIViewController, NVActivityIndicatorViewable, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate {

    private let dataSource = TableViewDataSource()
    
    private var userImage: UIImage?
    
    private var emitter = Event<UIImage>()
    
    private var listener: EventListener<UIImage>?
    
    var contentInset: UIEdgeInsets?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var skipImage: UIImageView!
    
    
    deinit {
        
        print("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        
        bottomView.backgroundColor = UIColor.stBrightBlue
        skipButton.setTitleColor(UIColor.stWhite70Opacity, for: .normal)
        skipButton.addTarget(self, action: #selector(self.skipAction), for: .touchUpInside)
        
        skipImage.tintColor = UIColor.stWhite70Opacity
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardNotificationListener.keyboardWillShow(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardNotificationListener.keyboardWillHide(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        let section = CollectionSection()
        
        section.addItem(cellStyle: .default) { (cell, item) in
            
            cell.selectionStyle = .none
            cell.textLabel?.numberOfLines = 0
            cell.backgroundColor = UIColor.clear
            cell.textLabel?.textAlignment = .center
            
            let title = NSMutableAttributedString(string: "Осталось немного!\n\n",
                                                  attributes: [NSForegroundColorAttributeName : UIColor.white,
                                                               NSFontAttributeName : UIFont.systemFont(ofSize: 16)])
            
            let text = "Выберите аватар и заполните поля, либо пропустите этот шаг."
            
            let subtitle = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont.systemFont(ofSize: 13)])
            
            title.append(subtitle)
            cell.textLabel?.attributedText = title
        }
        
        section.addItem(nibClass: STLoginAvatarTableViewCell.self) { [unowned self] (cell, item) in
            
            let viewCell = cell as! STLoginAvatarTableViewCell
            viewCell.avatarButton.makeCircular()
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

        self.dataSource.sections.append(section)
        
        let rigthItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(self.actionNext))
        rigthItem.tintColor = UIColor.white
        rigthItem.isEnabled = false
        
        self.navigationItem.rightBarButtonItem = rigthItem
        
        self.setCustomBackButton()
    }
    
    
    func keyboardWillShow(_ notification: Notification) {
        
        if self.contentInset == nil {
            
            self.contentInset = tableView.contentInset
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size {
            
            let contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            self.tableView?.contentInset = contentInset
            self.tableView?.scrollIndicatorInsets = contentInset
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        UIView.animate(withDuration: 0.2) { 
            
            self.tableView?.contentInset = self.contentInset ?? UIEdgeInsets.zero
            self.tableView?.scrollIndicatorInsets = self.contentInset ?? UIEdgeInsets.zero
            self.contentInset = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        var naviHeight = UIApplication.shared.statusBarFrame.height
        
        if let barHeight = self.navigationController?.navigationBar.frame.size.height {
            
            naviHeight += barHeight
        }
        
        let offset = (self.tableView.frame.height - self.tableView.contentSize.height) / 2 - naviHeight
        
        guard offset > 0 else {
            
            return
        }
        
        self.tableView.contentInset = UIEdgeInsets(top: offset, left: 0, bottom: 0, right: 0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
    }
    
    
    // MARK: Private methods
    
    func actionNext() {
        
        
    }
    
    func skipAction() {
        
        self.st_Router_OpenMainController()
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
