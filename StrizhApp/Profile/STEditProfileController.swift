//
//  STEditProfileController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 16/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import AlamofireImage

private enum EditProfileFieldsEnum {
    
    case firstName, lastName, email
}

class STEditProfileController: UITableViewController, UITextFieldDelegate {

    private let dataSource = TableViewDataSource()
    
    private var userImageSection = CollectionSection()
    
    private var userInfoSection = CollectionSection()
    
    private var user: STUser?
    
    
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
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        self.dataSource.sections.append(self.userImageSection)
        self.dataSource.sections.append(self.userInfoSection)
        
        self.tableView.dataSource = self.dataSource
        
        self.tableView.register(cell: STEditProfileHeaderCell.self)
        self.tableView.register(cell: STEditProfileTextCell.self)
        
        let rigthItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(self.save))
        
        let leftItem = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(self.close))
        
        self.navigationItem.rightBarButtonItem = rigthItem
        self.navigationItem.leftBarButtonItem = leftItem
        
        self.title = "Профиль"
        
        self.createDataSource()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.view.endEditing(true)
    }
    
    func save() {
        
        var errors = [String]()
        
        self.userInfoSection.items.forEach { item in
            
            if item.validation?() == false {
                
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
        
//        api.updateUserInformation(transport: .webSocket,
//                                  userId: self.user!.id,
//                                  firstName: <#T##String?#>, lastName: <#T##String?#>, email: <#T##String?#>, imageId: <#T##Int?#>)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func createDataSource() {
        
        self.userImageSection.addItem(cellClass: STEditProfileHeaderCell.self, item: self.user) { (cell, item) in
            
            if let user = self.user {
                
                let viewCell = cell as! STEditProfileHeaderCell
                viewCell.selectionStyle = .none
                
                if let data = user.imageData {
                    
                    DispatchQueue.global().async {
                        
                        DispatchQueue.main.async {
                            
                            viewCell.userImage.image = UIImage(data: data)
                            viewCell.userImage.makeCircular()
                        }
                    }
                }
                else {
                    
                    if !user.imageUrl.isEmpty {
                        
                        let width = Int(viewCell.userImage.bounds.size.width * UIScreen.main.scale)
                        let height = Int(viewCell.userImage.bounds.size.height * UIScreen.main.scale)
                        
                        let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
                        
                        let urlString = user.imageUrl + queryResize
                        
                        let filter = RoundedCornersFilter(radius: viewCell.userImage.bounds.size.width)
                        viewCell.userImage.af_setImage(withURL: URL(string: urlString)!, filter: filter)
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
                
                item.validation = {
                
                    return !viewCell.value.text!.isEmpty
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
                
                item.validation = {
                    
                    return !viewCell.value.text!.isEmpty
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
            }
        }
    }
}
