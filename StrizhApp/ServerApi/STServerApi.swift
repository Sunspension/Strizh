//
//  STServerApi.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import Alamofire
import BrightFutures
import AlamofireObjectMapper

struct STServerApi: PRemoteServerApi {
    
    private var serverBaseUrlString: String
    
    private var socket: STWebSocket
    
    private var httpManager: STHTTPManager
    
    
    init(serverUrlString: String) {
        
        self.serverBaseUrlString = serverUrlString
        self.socket = STWebSocket(serverUrlString: serverUrlString)
        self.httpManager = STHTTPManager(serverUrlString: serverUrlString)
    }
    
    func checkSession() -> Future<STSession, STAuthorizationError> {
        
        return self.httpManager.checkSession()
    }
    
    func registration(phoneNumber: String,
                      deviceType: String,
                      deviceToken: String) -> Future<STRegistration, STAuthorizationError> {
        
        return self.httpManager.registration(phoneNumber: phoneNumber,
                                             deviceType: deviceType,
                                             deviceToken: deviceToken)
        
    }
    
    func authorization(phoneNumber: String,
                       deviceToken: String,
                       code: String,
                       type: String,
                       application: String,
                       systemVersion: String,
                       applicationVersion: String) -> Future<STSession, STAuthorizationError> {
        
        return self.httpManager.authorization(phoneNumber: phoneNumber,
                                              deviceToken: deviceToken,
                                              code: code,
                                              type: type,
                                              application: application,
                                              systemVersion: systemVersion,
                                              applicationVersion: applicationVersion)
        
    }
    
    func logout() -> Future<STSession, STAuthorizationError> {
        
        return self.httpManager.logout()
    }
    
    func uploadImage(image: UIImage) -> Future<STImage, STImageUploadError> {

        return self.httpManager.uploadImage(image: image)
    }
    
    
    func onValidSession() {
        
        self.socket.setup()
    }
    
    
    func updateUserInformation(transport: STServerRequestTransport,
                               userId: Int,
                               firstName: String? = nil,
                               lastName: String? = nil,
                               email: String? = nil,
                               imageId: Int? = nil) -> Future<STUser, STError>{
        
        if transport == .http {
            
            return self.httpManager.updateUserInformation(userId: userId,
                                                          firstName: firstName,
                                                          lastName: lastName,
                                                          email: email,
                                                          imageId: imageId)
        }
        else {
            
            fatalError()
        }
    }
    
    
    func loadUser(transport: STServerRequestTransport, userId: Int) -> Future<STUser, STError> {
        
        if transport == .http {
            
            return self.httpManager.loadUser(userId: userId)
        }
        else {
            
            return self.socket.loadUser(userId: userId)
        }
    }
    
    func loadFeed(filter: STFeedFilter, page: Int, pageSize: Int,
                  isFavorite: Bool, searchString: String?) -> Future<STFeed, STError> {
        
        return self.socket.loadFeed(filter: filter, page: page, pageSize: pageSize,
                                    isFavorite: isFavorite, searchString: searchString)
    }
    
    func loadPersonalPosts(page: Int, pageSize: Int) -> Future<STFeed, STError> {
        
        return self.socket.loadPersonalPosts(page: page, pageSize: pageSize)
    }
}
