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
import Contacts

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
    
    func uploadImage(image: Data, uploadProgress: ((_ progress: Double) -> Void)?) -> Future<STFile, STImageUploadError>
    
    func onValidSession() -> Void
    
    func updateUserInformation(transport: STServerRequestTransport,
                               userId: Int,
                               firstName: String,
                               lastName: String,
                               email: String?,
                               imageId: Int64?) -> Future<STUser, STError>
    
    func loadUser(transport: STServerRequestTransport, userId: Int) -> Future<STUser, STError>
    
    func loadFeed(filter: STFeedFilter, page: Int, pageSize: Int,
                  isFavorite: Bool, searchString: String?) -> Future<STFeed, STError>
    
    func loadPersonalPosts(minId: Int, pageSize: Int) -> Future<STFeed, STError>
    
    func favorite(postId: Int, favorite: Bool) -> Future<STPost, STError>
    
    func archivePost(postId: Int, isArchived: Bool) -> Future<STPost, STError>
    
    func deletePost(postId: Int) -> Future<STPost, STError>
    
    func loadContacts() -> Future<[STContact], STError>
    
    func uploadContacts(contacts: [CNContact]) -> Future<[STContact], STError>
    
    func createPost(post: STUserPostObject) -> Future<STPost, STError>
    
    func updatePost(post: STUserPostObject) -> Future<STPost, STError>
    
    func loadDialogs(page: Int, pageSize: Int) -> Future<STDialogsPage, STError>
    
    func loadDialogMessages(dialog: STDialog, pageSize: Int, lastId: Int?) -> Future<[STMessage], STError>
}
