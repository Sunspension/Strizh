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

class STContactsDataSourceWrapper {
    
    private var loadingStatus = STLoadingStatusEnum.idle
    
    private var notRelatedContactsSection = CollectionSection()
    
    var dataSource = TableViewDataSource()
    
    var loadingStatusChanged: ((_ loadigStatus: STLoadingStatusEnum) -> Void)?
    
    
    func synchronizeContacts() {
    
        // hack for table footer
        self.dataSource.sections.append(CollectionSection())
        
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            
            store.requestAccess(for: .contacts, completionHandler: { (authorized, error) in
                
                if authorized {
                    
                    self.retrieveContatcsWithStore(store: store)
                }
            })
        }
        else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            
            self.retrieveContatcsWithStore(store: store)
        }
    }
    
    private func retrieveContatcsWithStore(store: CNContactStore) {
        
        
        var containers = [CNContainer]()
        
        do {
            
            containers = try store.containers(matching: nil)
        }
        catch {
            
            print("Error fetching containers")
        }
        
        var contacts = [CNContact]()
        
        containers.forEach { container in
            
            do {
                
                let predicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                
                let keysToFetch = [CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey]
                
                let con = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
                
                contacts.append(contentsOf: con)
            }
            catch {
                
                print(error)
            }
        }
        
        self.uploadContacts(contacts: contacts)
    }
    
    private func uploadContacts(contacts: [CNContact]) {
        
        self.loadingStatus = .loading
        self.loadingStatusChanged?(self.loadingStatus)
        
        AppDelegate.appSettings.api.uploadContacts(contacts: contacts)
            .onSuccess { [unowned self] contacts in
                
                self.loadingStatus = .loaded
                
                self.dataSource.sections.removeAll()
                self.createDataSource(contacts: contacts)
                
                self.loadingStatusChanged?(self.loadingStatus)
            }
            .onFailure { [unowned self] error in
            
                self.loadingStatus = .failed
                self.loadingStatusChanged?(self.loadingStatus)
            }
    }
    
    private func createDataSource(contacts: [STContact]) {
        
        contacts.forEach({ contact in
            
            if contact.isRegistered {
                
                let letter = String(contact.firstName.characters.first!)
                
                var section = self.dataSource.sections.filter({ ($0.sectionType as! String) == letter }).first
                
                if section == nil {
                    
                    section = CollectionSection()
                    section!.sectionType = letter
                    
                    self.dataSource.sections.append(section!)
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
        self.dataSource.sections.sort { (oneSection, otherSection) -> Bool in
            
            return (oneSection.sectionType as! String) < (otherSection.sectionType as! String)
        }
        
        self.dataSource.sections.append(self.notRelatedContactsSection)
    }
    
    private func binding(cell: UITableViewCell, item: CollectionSectionItem) {
        
        let viewCell = cell as! STContactCell
        let contact = item.item as! STContact
        
        viewCell.contactName.text = contact.firstName + " " + contact.lastName
        viewCell.addContact.isHidden = contact.isRegistered
        viewCell.layoutMargins = UIEdgeInsets.zero
        viewCell.separatorInset = UIEdgeInsets.zero
        
//        let width = Int(viewCell.contactImage.bounds.size.width * UIScreen.main.scale)
//        let height = Int(viewCell.contactImage.bounds.size.height * UIScreen.main.scale)
//        
//        let queryResize = "?resize=w[\(width)]h[\(height)]q[100]e[true]"
//        
//        let urlString = contact + queryResize
//        
//        let filter = RoundedCornersFilter(radius: cell.userIcon.bounds.size.width)
//        viewCell.contactImage.af_setImage(withURL: URL(string: urlString)!,
//                                          filter: filter,
//                                          completion: nil)
    }
}