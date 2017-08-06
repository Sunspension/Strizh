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
import Contacts

struct STServerApi: PRemoteServerApi {
    
    fileprivate var serverBaseUrlString: String
    
    fileprivate var socket: STWebSocket
    
    fileprivate var httpManager: STHTTPManager
    
    
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
                      deviceToken: String?) -> Future<STRegistration, STAuthorizationError> {
        
        return self.httpManager.registration(phoneNumber: phoneNumber,
                                             deviceType: deviceType,
                                             deviceToken: deviceToken)
        
    }
    
    func authorization(phoneNumber: String,
                       deviceToken: String?,
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
    
    func fbAuthorization(deviceToken: String?, deviceUUID: String, code: String) -> Future<STSession, STAuthorizationError> {
        
        return self.httpManager.fbAuthorization(deviceToken: deviceToken, deviceUUID: deviceUUID, code: code)
    }
    
    func logout() -> Future<STSession, STAuthorizationError> {
        
        return self.httpManager.logout()
    }
    
    func uploadImage(image: Data, uploadProgress: ((_ progress: Double) -> Void)? = nil) -> Future<STFile, STImageUploadError> {

        return self.httpManager.uploadImage(image: image, uploadProgress: uploadProgress)
    }
    
    func createPost(post: STUserPostObject) -> Future<STPost, STError> {
        
        return self.socket.createPost(post: post)
    }
    
    func updatePost(post:STUserPostObject) -> Future<STPost, STError> {
        
        return self.socket.updatePost(post: post)
    }
    
    func onValidSession() {
        
        self.socket.setup()
    }
    
    
    func updateUserInformation(transport: STServerRequestTransport,
                               userId: Int,
                               firstName: String,
                               lastName: String,
                               email: String? = nil,
                               imageId: Int64? = nil) -> Future<STUser, STError>{
        
        if transport == .http {
            
            return self.httpManager.updateUserInformation(userId: userId,
                                                          firstName: firstName,
                                                          lastName: lastName,
                                                          email: email,
                                                          imageId: imageId)
        }
        else {
            
            return self.socket.updateUserInformation(userId: userId,
                                                     firstName: firstName,
                                                     lastName: lastName,
                                                     email: email,
                                                     imageId: imageId)
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
    
    func loadPersonalPosts(minId: Int, pageSize: Int) -> Future<STFeed, STError> {
        
        return self.socket.loadPersonalPosts(minId: minId, pageSize: pageSize)
    }
    
    func favorite(postId: Int, favorite: Bool) -> Future<STPost, STError> {
        
        return self.socket.favorite(postId: postId, favorite: favorite)
    }
    
    func archivePost(postId: Int, isArchived: Bool) -> Future<STPost, STError> {
        
        return self.socket.archivePost(postId: postId, isArchived: isArchived)
    }
    
    func deletePost(postId: Int) -> Future<STPost, STError> {
        
        return self.socket.deletePost(postId: postId)
    }
    
    func loadContacts() -> Future<[STContact], STError> {
        
        return self.socket.loadContacts()
    }
    
    func uploadContacts(contacts: [CNContact]) -> Future<[STContact], STError> {
        
        return self.socket.uploadContacts(contacts: contacts)
    }
    
    func loadDialogs(page: Int, pageSize: Int, postId: Int? = nil, userIdAndIsIncoming: (Int, Bool)? = nil, searchString: String? = nil) -> Future<STDialogsPage, STError> {
        
        return self.socket.loadDialogs(page: page, pageSize: pageSize, postId: postId,
                                       userIdAndIsIncoming: userIdAndIsIncoming, searchString: searchString)
    }
    
    func loadDialog(by id: Int) -> Future<STDialog, STError> {
        
        return self.socket.loadDialog(by: id)
    }
    
    func loadPost(by id: Int) -> Future<STPost, STError> {
        
        return self.socket.loadPost(by: id)
    }
    
    func loadDialogWithLastMessage(by dialogId: Int) -> Future<STDialog, STError> {
        
        return self.socket.loadDialogWithLastMessage(by: dialogId)
    }
    
    func loadDialogMessages(dialogId: Int, pageSize: Int, lastId: Int64?) -> Future<[STMessage], STError> {
        
        return self.socket.loadDialogMessages(dialogId: dialogId, pageSize: pageSize, lastId: lastId)
    }
    
    func sendMessage(dialogId: Int, message: String) -> Future<STMessage, STError> {
        
        return self.socket.sendMessage(dialogId: dialogId, message: message)
    }

    func notifyMessagesRead(dialogId: Int, lastMessageId: Int64?) -> Future<STDialog, STError> {
        
        return self.socket.notifyMessagesRead(dialogId: dialogId, lastMessageId: lastMessageId)
    }
    
    func createDialog(objectId: Int, objectType: Int) -> Future<STDialog, STError> {
        
        return self.socket.createDialog(objectId: objectId, objectType: objectType)
    }
    
    func loadMessage(by id: Int) -> Future<STMessage, STError> {
        
        return self.socket.loadMessage(by: id)
    }
    
    func updateUserNotificationSettings(settings: STUserNotificationSettings, userId: Int) -> Future<STUser, STError> {
        
        return self.socket.updateUserNotificationSettings(settings: settings, userId: userId)
    }
}
