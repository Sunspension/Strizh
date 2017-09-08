//
//  StrizhAppUITests.swift
//  StrizhAppUITests
//
//  Created by Vladimir Kokhanevich on 07/09/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import XCTest

class StrizhAppUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTapOnCell() {
        
        XCUIApplication().tables.cells.containing(.staticText, identifier:"Test").children(matching: .staticText).matching(identifier: "Test").element(boundBy: 1).tap()
        
    }
    
    func testAddToFavorite() {
        
        let exist = NSPredicate(format: "exists == 1")
        let button = XCUIApplication().tables.buttons.matching(identifier: "icon star").element(boundBy: 0)
        
        expectation(for: exist, evaluatedWith: button, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        let isSelected = button.isSelected
        button.tap()
        
        XCTAssertTrue(isSelected != button.isSelected)
    }
}
