//
//  STNewPostContactsController.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 20/08/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import Bond

fileprivate enum TypeOfRecepientsEnum {
    
    case all, contactsOnly
}

class STNewPostContactsController: STContactsController {
    
    
    fileprivate let selectedItems = MutableObservableArray([STContact]())
    
    fileprivate let typeOfRecepientsSection = TableSection()
    
    fileprivate lazy var postObject: STUserPostObject = {
        
        return try! self.dependencyContainer.resolve(STUserPostObject.self) as! STUserPostObject
        
    }()
    
    fileprivate var isPublic = true
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if postObject.objectType == .new {
            
            self.analytics.logEvent(eventName: st_eNewPostStep3, timed: true)
        }
        else {
            
            self.analytics.logEvent(eventName: st_eContacts)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        // checking press back button
        if self.navigationController?.viewControllers.index(of: self) == nil {
            
            if postObject.objectType != .new {
                
                return
            }
            
            self.analytics.endTimeEvent(eventName: st_eNewPostStep3)
        }
    }
    
    //MARK: - UISearchBar delegate implementation
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        return postObject.objectType == .resend ? true : isPublic == false
    }
    
    override func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        super.searchBarTextDidBeginEditing(searchBar)
        
        if postObject.objectType == .new {
            
            self.analytics.logEvent(eventName: st_eNewPostContactSearch)
        }
    }
    
    override func setup() {
        
        super.setup()
        
        let rightItem = UIBarButtonItem(title: "contacts_page_create_text".localized,
                                        style: .plain, target: self, action: #selector(self.nextAction))
        rightItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = rightItem
        
        self.selectedItems.observeNext(with: { [unowned self] event in
            
            rightItem.isEnabled = event.dataSource.count != 0
            
            if (event.dataSource.count == 0) {
                
                self.title = "contacts_page_title".localized
            }
            else {
                
                self.title = "contacts_page_title".localized + "(\(event.dataSource.count))"
            }
        })
            .dispose(in: self.disposeBag)
        
        self.tableView.allowsMultipleSelection = postObject.objectType == .resend ? true : !isPublic
    }
    
    override func binding(_ cell: UITableViewCell, item: TableSectionItem) {
        
        super.binding(cell, item: item)
        
        let viewCell = cell as! STContactCell
        viewCell.disableSelection = false
        viewCell.accessoryType = .checkmark
        viewCell.isDisabledCell = postObject.objectType == .new ? self.isPublic : false
        
        if self.tableView.allowsSelection && self.selectedItems.contains(item.item as! STContact) {
            
            self.tableView.selectRow(at: item.indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    override func synchronizeContacts() {
        
        _ = self.contactsProvider.registeredContacts.andThen { result in
            
            if let contacts = result.value {
                
                if self.postObject.objectType == .edit {
                    
                    if self.postObject.userIds.count > 0 {
                        
                        for userId in self.postObject.userIds {
                            
                            if let contact = contacts.first(where: { $0.contactUserId == userId }) {
                                
                                self.selectedItems.append(contact)
                            }
                        }
                    }
                }
                
                // when user trying to edit post
                if self.postObject.objectType == .new {
                    
                    self.setupTypeOfRecepientsSection()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
                
                self.createDataSource(for: self.dataSource, contacts: contacts)
                self.setupSearchController()
                self.reloadTableView()
            }
        }
    }

    override func setupDataSource() {
        
        super.setupDataSource()
        
        self.dataSource.onDidSelectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) in
            
            if let type =  item.itemType as? TypeOfRecepientsEnum {
                
                switch type {
                    
                case .contactsOnly:
                    
                    self.isPublic = false
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    self.tableView.allowsMultipleSelection = !self.isPublic
                    self.tableView.reloadData()
                    
                    break
                    
                default:
                    break
                }
                
                return
            }
            
            self.selectedItems.append((item.item as! STContact))
        }
        
        self.dataSource.onDidDeselectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) in
            
            if let type =  item.itemType as? TypeOfRecepientsEnum {
                
                if type == .all {
                    
                    self.isPublic = true
                    self.selectedItems.removeAll()
                    self.tableView.allowsMultipleSelection = !self.isPublic
                    self.tableView.reloadData()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                }
                
                return
            }
            
            let index = self.selectedItems.index(of: item.item as! STContact)!
            self.selectedItems.remove(at: index)
        }
        
        self.searchDataSource.onDidSelectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) in
            
            self.selectedItems.append((item.item as! STContact))
        }
        
        self.searchDataSource.onDidDeselectRowAtIndexPath = {
            
            (_ tableView: UITableView, _ indexPath: IndexPath, _ item: TableSectionItem) in
            
            let index = self.selectedItems.index(of: item.item as! STContact)!
            self.selectedItems.remove(at: index)
        }
    }
    
    fileprivate func setupTypeOfRecepientsSection() {
        
        self.typeOfRecepientsSection.add(itemType: TypeOfRecepientsEnum.all, cellStyle: .subtitle) { (cell, item) in
            
            item.cellHeight = 65
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.detailTextLabel?.textColor = UIColor(red: 129 / 255.0, green: 137 / 255.0, blue: 150 / 255.0, alpha: 1)
            cell.detailTextLabel?.numberOfLines = 0
            cell.textLabel?.text = "Все пользователи Strizhapp"
            cell.detailTextLabel?.text = "После модерации сделка отправится всем пользователям Strizhapp"
            cell.accessoryType = .checkmark
            cell.selectionStyle = .none
            cell.tintColor = self.isPublic ? UIColor.stBrightBlue : UIColor.lightGray
            
            self.tableView.selectRow(at: item.indexPath, animated: false, scrollPosition: .none)
        }
        
        self.typeOfRecepientsSection.add(itemType: TypeOfRecepientsEnum.contactsOnly, cellStyle: .subtitle) { (cell, item) in
            
            item.cellHeight = 65
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.detailTextLabel?.textColor = UIColor(red: 129 / 255.0, green: 137 / 255.0, blue: 150 / 255.0, alpha: 1)
            cell.detailTextLabel?.numberOfLines = 0
            cell.textLabel?.text = "Мои контакты"
            cell.detailTextLabel?.text = "Выберите получателей из своих зарегистрированных контактов"
            cell.selectionStyle = .none
            cell.accessoryType = .checkmark
            cell.tintColor = !self.isPublic ? UIColor.stBrightBlue : UIColor.lightGray
        }
        
        self.dataSource.sections.append(self.typeOfRecepientsSection)
        
        let dummySection = TableSection()
        
        // dummy cell
        dummySection.add(cellStyle: .default, bindingAction: { (cell, item) in
            
            item.cellHeight = 14
            cell.backgroundColor = UIColor.clear
        })
        
        self.dataSource.sections.append(dummySection)
    }
    
    @objc fileprivate func nextAction() {
        
        self.postObject.userIds.append(contentsOf: self.selectedItems.array.map({ $0.contactUserId }))
        
        self.postObject.isPublic = self.isPublic
        
        self.startAnimating()
        
        switch self.postObject.objectType {
            
        case .new, .resend:
            
            if self.selectedItems.count > 0 {
                
                _ = self.contactsProvider.contacts.andThen(callback: { result in
                    
                    if let totalContacts = result.value {
                        
                        self.analytics.logEvent(eventName: st_eNewPostContactSelect, params: ["select_count" : self.selectedItems.count,
                                                                                              "total_count" : totalContacts.count])
                    }
                })
            }
            
            self.analytics.endTimeEvent(eventName: st_eNewPostStep3)
            
            api.createPost(post: self.postObject)
                
                .onSuccess(callback: { [unowned self] post in
                    
                    self.stopAnimating()
                    self.analytics.logEvent(eventName: st_eNewPostCreateFinish, params: ["select_count" : self.selectedItems.count])
                    
                    NotificationCenter.default.post(name: NSNotification.Name(kPostCreatedNotification), object: post)
                    
                    self.showOkAlert(title: "contacts_page_success_title".localized,
                                     message:"contacts_page_success_create_message".localized, okAction: {
                                        
                                        action in self.navigationController?.dismiss(animated: true, completion: nil)
                    })
                })
                .onFailure(callback: { [unowned self] error in
                    
                    self.stopAnimating()
                    self.showError(error: error)
                })
            
            break
            
        case .edit:
            
            api.updatePost(post: self.postObject)
                
                .onSuccess(callback: { [unowned self] post in
                    
                    self.stopAnimating()
                    
                    // still having the same behavior
                    NotificationCenter.default.post(name: NSNotification.Name(kPostCreatedNotification), object: post)
                    
                    self.showOkAlert(title: "contacts_page_success_title".localized,
                                     message:"contacts_page_success_update_message".localized, okAction: {
                                        
                                        action in self.navigationController?.dismiss(animated: true, completion: nil)
                    })
                })
                .onFailure(callback: { [unowned self] error in
                    
                    self.stopAnimating()
                    self.showError(error: error)
                })
            
            break
        }
    }
}
