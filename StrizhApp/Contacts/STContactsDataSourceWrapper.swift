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
    
    fileprivate var notRelatedContactsSection = TableSection()
    
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
        self.dataSource.sections.append(TableSection())
        
//        self.searchDataSource.sections.append(self.searchSection)
        
        if !showOnlyRegistered {
            
            self.notRelatedContactsSection.header(headerClass: STContactHeaderCell.self, bindingAction: { (cell, item) in
                
                let header = cell as! STContactHeaderCell
                header.title.text = "contacts_page_users_who_don't_use_app_title".localized
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
                self.createDataSource(for: self.dataSource, contacts: contacts)
                self.onDataSourceChanged?()
            }
        }
    }
    
    func searchContacts(searchString: String) {
        
        self.searchDataSource.sections.removeAll()
        self.notRelatedContactsSection.items.removeAll()
        
        _ = self.contactsProvider.contacts.andThen { result in
            
            guard let contacts = result.value else {
                
                return
            }
            
            if searchString.isEmpty {
                
                self.createDataSource(for: self.searchDataSource, contacts: contacts)
                self.onDataSourceChanged?()
                return
            }
            
            let items = contacts.filter({ $0.firstName.contains(searchString) || $0.lastName.contains(searchString) })
            self.createDataSource(for: self.searchDataSource, contacts: items)
            self.onDataSourceChanged?()
        }
    }
    
    fileprivate func createDataSource(for dataSource: TableViewDataSource, contacts: [STContact]) {
        
        contacts.forEach({ contact in
            
            if contact.isRegistered {
                
                let letter = String(contact.firstName.characters.first!)
                
                var section = dataSource.sections.filter({ ($0.sectionType as? String) == letter }).first
                
                if section == nil {
                    
                    section = TableSection(title: letter)
                    section!.sectionType = letter
                    
                    section!.header(headerClass: STContactHeaderCell.self, item: letter, bindingAction: { (cell, item) in
                        
                        let header = cell as! STContactHeaderCell
                        let title = item.item as! String
                        
                        header.title.textColor = UIColor.black
                        header.title.text = title
                    })
                    
                    section!.headerItem!.cellHeight = 30
                    
                    dataSource.sections.append(section!)
                }
                
                section!.addItem(cellClass: STContactCell.self,
                                 item: contact,
                                 bindingAction: self.binding)
            }
            else {
                
                self.notRelatedContactsSection.addItem(cellClass: STContactCell.self,
                                                       item: contact,
                                                       bindingAction: self.binding)
            }
        })
        
        // sorting
        dataSource.sections.sort { (oneSection, otherSection) -> Bool in
            
            return (oneSection.sectionType as! String) < (otherSection.sectionType as! String)
        }
        
        if !showOnlyRegistered && self.notRelatedContactsSection.items.count > 0 {
            
            dataSource.sections.append(self.notRelatedContactsSection)
        }
    }
    
    fileprivate func binding(_ cell: UITableViewCell, item: TableSectionItem) {
        
        let viewCell = cell as! STContactCell
        let contact = item.item as! STContact
        
        viewCell.contactName.text = contact.firstName + " " + contact.lastName
        viewCell.addContact.isHidden = contact.isRegistered
        viewCell.layoutMargins = UIEdgeInsets.zero
        viewCell.separatorInset = UIEdgeInsets.zero
        viewCell.accessoryType = allowsSelection ? .checkmark : .none
        viewCell.disableSelection = !self.showOnlyRegistered
        
        if !contact.isRegistered {
            
            let textToShare = "contacts_page_share_text".localized
            
            viewCell.addContact.reactive.tap.observe { [unowned self] _ in
                
                // analytics
                let container = AppDelegate.appSettings.dependencyContainer
                let analytics: STAnalytics = try! container.resolve()
                analytics.logEvent(eventName: st_eContactInvite)
                
                let activity = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
                self.viewController?.present(activity, animated: true, completion: nil)
                
            }.dispose(in: viewCell.bag)
        }
        
        if contact.imageUrl.isEmpty {
            
            DispatchQueue.main.async {
                
                var defaultImage = UIImage(named: "avatar")
                defaultImage = defaultImage?.af_imageAspectScaled(toFill: viewCell.contactImage.bounds.size)
                viewCell.contactImage.image = defaultImage?.af_imageRoundedIntoCircle()
            }
            
            return
        }
        
        let urlString = contact.imageUrl + viewCell.contactImage.queryResizeString()
        viewCell.contactImage.af_setImage(withURL: URL(string: urlString)!, completion: nil)
    }
}
