//
//  Login.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 07/09/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import XCTest

class Login: XCTestCase {
        
    func testLogedIn() {
        
//        let prod = "https://api.strizhapp.ru"
        let dev = "https://dev.api.strizhapp.ru"
        
        let serverUrl = URL(string: dev)!
        let cookies = HTTPCookieStorage.shared.cookies?.filter({ $0.domain == "." + serverUrl.host! })
        
        XCTAssert(cookies == nil || cookies!.count < 0, "Register first")
    }
}
