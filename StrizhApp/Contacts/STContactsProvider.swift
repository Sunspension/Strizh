//
//  STAddressBook.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 16/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import Contacts
import BrightFutures

class STContactsProvider {
    
    static let sharedInstance = STContactsProvider()
    
    private (set) var loadingStatus: STLoadingStatusEnum = STLoadingStatusEnum.idle {
        
        willSet {
            
            self.loadingStatusChanged?(newValue)
        }
    }
    
    private var privateContacts = [STContact]()
    
    
    var loadingStatusChanged: ((_ loadigStatus: STLoadingStatusEnum) -> Void)?
    
    var contacts: Future<[STContact], STError> {
       
        let p = Promise<[STContact], STError>()
        
        guard privateContacts.count > 0, loadingStatus == .loaded else {
            
            _ = synchronizeContacts().andThen(callback: { result in
                
                if let error = result.error {
                    
                    p.failure(error)
                }
                else if let contacts = result.value {
                    
                    p.success(contacts)
                }
            })
            
            return p.future
        }
        
        p.success(privateContacts)
        
        return p.future
    }
    
    func reset() {
        
        self.privateContacts.removeAll()
        self.loadingStatus = .idle
    }
    
    private func synchronizeContacts() -> Future<[STContact], STError> {
        
        let p = Promise<[STContact], STError>()
        
        let store = CNContactStore()
        
        let retrieveContactsBlock = {
            
            _ = self.retrieveContactsWithStore(store: store).andThen(callback: { result in
                
                if let error = result.error {
                    
                    p.failure(error)
                }
                else if let contacts = result.value {
                    
                    p.success(contacts)
                }
            })
        }
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            
            store.requestAccess(for: .contacts, completionHandler: { (authorized, error) in
                
                if authorized {
                    
                    retrieveContactsBlock()
                }
            })
        }
        else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            
            retrieveContactsBlock()
        }
        
        return p.future
    }
    
    private func retrieveContactsWithStore(store: CNContactStore) -> Future<[STContact], STError> {
        
        
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
        
        return self.uploadContacts(contacts: contacts)
    }
    
    private func uploadContacts(contacts: [CNContact]) -> Future<[STContact], STError> {
        
        let p = Promise<[STContact], STError>()
        
        self.loadingStatus = .loading
        
        AppDelegate.appSettings.api.uploadContacts(contacts: contacts)
            .onSuccess { [unowned self] contacts in
                
                self.privateContacts.append(contentsOf: contacts)
                
                p.success(contacts)
                self.loadingStatus = .loaded
            }
            .onFailure { [unowned self] error in
                
                p.failure(error)
                self.loadingStatus = .failed
            }
        
        return p.future
    }
}
