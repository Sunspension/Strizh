//
//  PRemoteServerApiV1.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import BrightFutures
import Alamofire

enum STServerRequestTransport {
    
    case http, webSocket
}

protocol PRemoteServerApi {
    
    func checkSession() -> Future<STSession, STAuthorizationError>
    
    func registration(phoneNumber: String,
                      deviceType: String,
                      deviceToken: String) -> Future<STRegistration, STAuthorizationError>
    
    func authorization(phoneNumber: String,
                       deviceToken: String,
                       code: String,
                       type: String,
                       application: String,
                       systemVersion: String,
                       applicationVersion: String) -> Future<STSession, STAuthorizationError>
    
    func logout() -> Future<STSession, STAuthorizationError>
    
    func uploadImage(image: UIImage) -> Future<STImage, STImageUploadError>
    
    func onValidSession() -> Void
    
    func updateUserInformation(transport: STServerRequestTransport,
                               userId: Int,
                               firstName: String?,
                               lastName: String?,
                               email: String?,
                               imageId: Int?) -> Future<STUser, STError>
    
    func loadUser(transport: STServerRequestTransport, userId: Int) -> Future<STUser, STError>
    
//    func loadFeed(page: Int, pageSize: Int, )
}
