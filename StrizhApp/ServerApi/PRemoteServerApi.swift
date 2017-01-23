//
//  PRemoteServerApiV1.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import BrightFutures

protocol PRemoteServerApi {
    
    func checkSession() -> Future<Session, STAuthorizationError>
    
    func registration(phoneNumber: String,
                      deviceType: String,
                      deviceToken: String) -> Future<Registration, STAuthorizationError>
    
    func authorization(phoneNumber: String,
                       deviceToken: String,
                       code: String,
                       type: String,
                       application: String,
                       systemVersion: String,
                       applicationVersion: String) -> Future<Session, STAuthorizationError>
    
    func logout() -> Future<Session, STAuthorizationError>
}
