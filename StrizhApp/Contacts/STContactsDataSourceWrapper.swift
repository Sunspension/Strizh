//
//  STContactsDataSourceWrapper.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 25/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import Contacts
import AlamofireImage
import Bond

class STContactsDataSourceWrapper {
    
    fileprivate var notRelatedContactsSection = CollectionSection()
    
    fileprivate var searchSection = CollectionSection()
    
    fileprivate var contactsProvider = STContactsProvider.sharedInstance
    
    var allowsSelection = false
    
    var showOnlyRegistered = false
    
    var onDataSourceChanged: (() -> Void)?
    
    var dataSource = TableViewDataSource()
    
    var searchDataSource = TableViewDataSource()
    
    var loadingStatusChanged: ((_ loadigStatus: STLoadingStatusEnum) -> Void)?
    
    var viewController: UIViewController?
    
    var searchString = ""
    
    
    init(viewController: UIViewController? = nil) {
        
        self.viewController = viewController
        
        // hack for table footer
        self.dataSource.sections.append(CollectionSection())
        
        self.searchDataSource.sections.append(self.searchSection)
        
        if !showOnlyRegistered {
            
            self.notRelatedContactsSection.header(headerClass: STContactHeaderCell.self, bindingAction: { (cell, item) in
                
                let header = cell as! STContactHeaderCell
                header.title.text = "НЕ ИСПОЛЬЗУЮТ STRIZHAPP"
                header.title.textColor = UIColor.stSteelGrey
            })
            
            self.notRelatedContactsSection.headerItem?.cellHeight = 30
        }
    }
    
    func synchronizeContacts() {
        
        self.contactsProvider.loadingStatusChanged = self.loadingStatusChanged
        
        _ = self.contactsProvider.contacts.andThen { result in
            
            if let contacts = result.value {
                
                self.dataSource.sections.removeAll()
                self.createDataSource(contacts: contacts)
                self.onDataSourceChanged?()
            }
        }
    }
    
    func searchContacts(searchString: String) {
        
        self.searchSection.items.removeAll()
        
        let items = dataSource.sections.flatMap({ $0.items }).filter { item -> Bool in
            
            let contact = item.item as! STContact
            
            if contact.firstName.contains(searchString) || contact.lastName.contains(searchString) {
                
                return true
            }
            
            return false
        }
        
        items.forEach { item in
            
            self.searchSection.addItem(cellClass: STContactCell.self, item: item.item, bindingAction: self.binding)
        }
    }
    
    fileprivate func createDataSource(contacts: [STContact]) {
        
        contacts.forEach({ contact in
            
            if contact.isRegistered {
                
                let letter = String(contact.firstName.characters.first!)
                
                var section = self.dataSource.sections.filter({ ($0.sectionType as! String) == letter }).first
                
                if section == nil {
                    
                    section = CollectionSection(title: letter)
                    section!.sectionType = letter
                    
                    section!.header(headerClass: STContactHeaderCell.self, item: letter, bindingAction: { (cell, item) in
                        
                        let header = cell as! STContactHeaderCell
                        let title = item.item as! String
                        
                        header.title.textColor = UIColor.black
                        header.title.text = title
                    })
                    
                    section!.headerItem!.cellHeight = 30
                    
                    self.dataSource.sections.append(section!)
                }
                
                section!.addItem(cellClass: STContactCell.self,
                                 item: contact,
                                 bindingAction: self.binding)
            }
            else if !showOnlyRegistered {
                
                self.notRelatedContactsSection.addItem(cellClass: STContactCell.self,
                                                       item: contact,
                                                       bindingAction: self.binding)
            }
        })
        
        // sorting
        
        self.dataSource.sections.sort { (oneSection, otherSection) -> Bool in
            
            return (oneSection.sectionType as! String) < (otherSection.sectionType as! String)
        }
        
        if !showOnlyRegistered {
            
            self.dataSource.sections.append(self.notRelatedContactsSection)
        }
    }
    
    fileprivate func binding(_ cell: UITableViewCell, item: CollectionSectionItem) {
        
        let viewCell = cell as! STContactCell
        let contact = item.item as! STContact
        
        viewCell.contactName.text = contact.firstName + " " + contact.lastName
        viewCell.addContact.isHidden = contact.isRegistered
        viewCell.layoutMargins = UIEdgeInsets.zero
        viewCell.separatorInset = UIEdgeInsets.zero
        viewCell.accessoryType = allowsSelection ? .checkmark : .none
        
        if !contact.isRegistered {
            
            let textToShare = "Приглашаю в приложение StrizhApp, которое можно скачать в App Store"
            
            viewCell.addContact.reactive.tap.observe { [unowned self] _ in
                
                let activity = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
                self.viewController?.present(activity, animated: true, completion: nil)
                
            }.dispose(in: viewCell.bag)
        }
        
        if contact.imageUrl.isEmpty {
            
            return
        }
        
        let width = Int(viewCell.contactImage.bounds.size.width * UIScreen.main.scale)
        let height = Int(viewCell.contactImage.bounds.size.height * UIScreen.main.scale)
        
        let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
        
        let urlString = contact.imageUrl + queryResize
        
        let filter = RoundedCornersFilter(radius: viewCell.contactImage.bounds.size.width)
        viewCell.contactImage.af_setImage(withURL: URL(string: urlString)!,
                                          filter: filter,
                                          completion: nil)
    }
}
