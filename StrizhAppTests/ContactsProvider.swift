//
//  ContactsProvider.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 07/09/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import XCTest
@testable import StrizhApp

class ContactsProvider: XCTestCase {
    
    private let contactsProvider = STContactsProvider.sharedInstance
    
    private var status = STLoadingStatusEnum.idle
    
    override func setUp() {
        super.setUp()
        
        self.contactsProvider.loadingStatusChanged = { status in
            
            self.status = status
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAllContacts() {
        
        let promise = expectation(description: "Contacts loaded")
        
        DispatchQueue.main.after(when: 2) {
            
            _ = self.contactsProvider.contacts.andThen { result in
                
                guard result.value != nil else {
                    
                    return XCTFail()
                }
                
                if self.status == .loaded {
                    
                    promise.fulfill()
                }
                else {
                    
                    XCTFail()
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
    }
    
    func testRegisteredContacts() {
        
        let promise = expectation(description: "Registered contacts loaded")
        
        DispatchQueue.main.after(when: 2) {
            
            _ = self.contactsProvider.registeredContacts.andThen { result in
                
                guard let contacts = result.value else {
                    
                    return XCTFail()
                }
                
                let count = contacts.count
                let registeredCount = contacts.map({ $0.isRegistered == true }).count
                
                XCTAssertTrue(count == registeredCount)
                promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
    }
}
