//
//  STWebSocket.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 03/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import SocketIO
import Foundation
import BrightFutures
import ObjectMapper
import Contacts

class STWebSocket {
    
    fileprivate var socket: SocketIOClient?
    
    fileprivate var serverUrlString: String
    
    fileprivate var requestCallbacks: [String : ([String : Any]?, [String : Any]?) -> Void] = [:]
    
    
    init(serverUrlString: String) {
        
        self.serverUrlString = serverUrlString
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onApplicationDidBecomeActiveNotification),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onApplicationDidEnterBackgroundNotification),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup() {
        
        self.socketSetup()
    }
    
    
    func loadUser(userId: Int) -> Future<STUser, STError> {
        
        let p = Promise<STUser, STError>()
        
        let request = STSocketRequestBuilder.loadUser(id: userId).request
        
        self.sendRequest(request: request) { (response, error)  in
            
            if error != nil {
                
                p.failure(.loadUserFalure)
            }
            
            if let user = STUser(JSON: response!) {
                
                p.success(user)
            }
        }
        
        return p.future
    }
    
    func updateUserInformation(userId: Int,
                               firstName: String,
                               lastName: String,
                               email: String? = nil,
                               imageId: Int64? = nil) -> Future<STUser, STError>{
    
        let p = Promise<STUser, STError>()
        
        let request = STSocketRequestBuilder.updateUserInformation(userId: userId,
                                                                   firstName: firstName,
                                                                   lastName: lastName,
                                                                   email: email,
                                                                   imageId: imageId).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.updateUserFailure)
            }
            else if let user = STUser(JSON: response!) {
                
                p.success(user)
            }
        }
        
        return p.future
    }
    
    
    func loadFeed(filter: STFeedFilter, page: Int, pageSize: Int,
                  isFavorite: Bool, searchString: String?) -> Future<STFeed, STError> {
        
        let p = Promise<STFeed, STError>()
        
        let request = STSocketRequestBuilder.loadFeed(filter: filter, page: page, pageSize: pageSize, isFavorite: isFavorite, searchString: searchString).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.loadFeedFailure)
            }
            else if let feed = STFeed(JSON: response!) {
                
                p.success(feed)
            }
        }
        
        return p.future
    }
    
    func loadFeed(userId: Int, page: Int, pageSize: Int) -> Future<STFeed, STError> {
        
        let p = Promise<STFeed, STError>()
        
        let request = STSocketRequestBuilder.loadUserFeed(userId: userId, page: page, pageSize: pageSize).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.loadFeedByUserIdFailure)
            }
            else if let feed = STFeed(JSON: response!) {
                
                p.success(feed)
            }
        }
        
        return p.future
    }
    
    func loadPersonalPosts(minId: Int, pageSize: Int) -> Future<STFeed, STError> {
        
        let p = Promise<STFeed, STError>()
        
        let request = STSocketRequestBuilder.loadPersonalPosts(minId: minId, pageSize: pageSize).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.loadFeedFailure)
            }
            else if let feed = STFeed(JSON: response!) {
                
                p.success(feed)
            }
        }
        
        return p.future
    }
    
    func favorite(postId: Int, favorite: Bool) -> Future<STPost, STError> {
        
        let p = Promise<STPost, STError>()
        
        let request = STSocketRequestBuilder.favorite(postId: postId, favorite: favorite).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.favoriteFailure)
            }
            else if let post = STPost(JSON: response!) {
                
                p.success(post)
            }
        }
        
        return p.future
    }
    
    func archivePost(postId: Int, isArchived: Bool) -> Future<STPost, STError> {
        
        let p = Promise<STPost, STError>()
        
        let request = STSocketRequestBuilder.archivePost(postId: postId, isArchived: isArchived).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.archiveFailure)
            }
            else if let post = STPost(JSON: response!) {
                
                p.success(post)
            }
        }
        
        return p.future
    }
    
    func deletePost(postId: Int) -> Future<STPost, STError> {
        
        let p = Promise<STPost, STError>()
        
        let request = STSocketRequestBuilder.deletePost(postId: postId).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.deletePostFailure)
            }
            else if let post = STPost(JSON: response!) {
                
                p.success(post)
            }
        }
        
        return p.future
    }
    
    func loadContacts() -> Future<[STContact], STError> {
        
        let p = Promise<[STContact], STError>()
        
        let request = STSocketRequestBuilder.loadContacts.request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.uploadContactsFailure)
            }
            
            if let contacts = response!["contact"] as? [[String : Any]] {
                
                let remoteContacts = Mapper<STContact>().mapArray(JSONArray: contacts)
                p.success(remoteContacts)
            }
        }
        
        return p.future
    }
    
    func uploadContacts(contacts: [CNContact]) -> Future<[STContact], STError> {
        
        let p = Promise<[STContact], STError>()
        
        let request = STSocketRequestBuilder.uploadContacts(contacts: contacts).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.loadContactsFailure)
            }
            else if let contacts = response!["contact"] as? [[String : Any]] {
                
                let remoteContacts = Mapper<STContact>().mapArray(JSONArray: contacts)
                p.success(remoteContacts)
            }
        }
        
        return p.future
    }
    
    func createPost(post: STUserPostObject) -> Future<STPost, STError> {
        
        let p = Promise<STPost, STError>()
        
        let request = STSocketRequestBuilder.createPost(post: post, update: false).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.createPostError)
            }
            else if let post = STPost(JSON: response!) {
                
                p.success(post)
            }
        }
        
        return p.future
    }
    
    func updatePost(post:STUserPostObject) -> Future<STPost, STError> {
        
        let p = Promise<STPost, STError>()
        
        let request = STSocketRequestBuilder.createPost(post: post, update: true).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.updatePostError)
            }
            else if let post = STPost(JSON: response!) {
                
                p.success(post)
            }
        }
        
        return p.future
    }
    
    func loadDialogs(page: Int, pageSize: Int, postId: Int? = nil, userIdAndIsIncoming: (Int, Bool)? = nil, searchString: String? = nil) -> Future<STDialogsPage, STError> {
        
        let p = Promise<STDialogsPage, STError>()
        
        let request = STSocketRequestBuilder.loadDialogs(page: page, pageSize: pageSize, postId: postId,
                                                         userIdAndIsIncoming: userIdAndIsIncoming, searchString: searchString).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.loadDialogsError)
            }
            else if let post = STDialogsPage(JSON: response!) {
                
                p.success(post)
            }
        }
        
        return p.future
    }
    
    func loadDialog(by id: Int) -> Future<STDialog, STError> {
        
        let p = Promise<STDialog, STError>()
        
        let request = STSocketRequestBuilder.loadDialog(dialogId: id).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.loadDialogsError)
            }
            else if let dialog = STDialog(JSON: response!) {
                
                p.success(dialog)
            }
        }
        
        return p.future
    }
    
    func loadPost(by id: Int) -> Future<STPost, STError> {
        
        let p = Promise<STPost, STError>()
        
        let request = STSocketRequestBuilder.loadPost(postId: id).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.loadPostError)
            }
            else if let post = STPost(JSON: response!) {
                
                p.success(post)
            }
        }
        
        return p.future
    }
    
    func loadDialogWithLastMessage(by dialogId: Int) -> Future<STDialog, STError> {
        
        let p = Promise<STDialog, STError>()
        
        let request = STSocketRequestBuilder.loadDialogWithLastMessage(dialogId: dialogId).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.loadDialogError)
            }
            else if let dialog = STDialog(JSON: response!) {
                
                p.success(dialog)
            }
        }
        
        return p.future
    }
    
    func loadDialogMessages(dialogId: Int, pageSize: Int, lastId: Int64?) -> Future<[STMessage], STError> {
        
        let p = Promise<[STMessage], STError>()
        
        let request = STSocketRequestBuilder.loadDialogMessages(dialogId: dialogId, pageSize: pageSize, lastId: lastId).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.loadMessagesError)
            }
            else if let messagePath = response!["message"] as? [[String : Any]] {
                
                let messages = Mapper<STMessage>().mapArray(JSONArray: messagePath)
                p.success(messages)
            }
        }
        
        return p.future
    }
    
    func sendMessage(dialogId: Int, message: String) -> Future<STMessage, STError> {
        
        let p = Promise<STMessage, STError>()
        
        let request = STSocketRequestBuilder.sendMessage(dialogId: dialogId, message: message).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.sendMessageError)
            }
            else if let message = STMessage(JSON: response!) {
                
                p.success(message)
            }
        }
        
        return p.future
    }
    
    func notifyMessagesRead(dialogId: Int, lastMessageId: Int64?) -> Future<STDialog, STError> {
        
        let p = Promise<STDialog, STError>()
        
        let request = STSocketRequestBuilder.notifyMessagesRead(dialogId: dialogId, lastMessageId: lastMessageId).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.notifyMessagesReadError)
            }
            else if let message = STDialog(JSON: response!) {
                
                p.success(message)
            }
        }
        
        return p.future
    }
    
    func createDialog(objectId: Int, objectType: Int) -> Future<STDialog, STError> {
        
        let p = Promise<STDialog, STError>()
        
        let request = STSocketRequestBuilder.createDialog(objectId: objectId, objectType: objectType).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.createDialogError)
            }
            else if let dialog = STDialog(JSON: response!) {
                
                p.success(dialog)
            }
        }
        
        return p.future
    }
    
    func loadMessage(by id: Int) -> Future<STMessage, STError> {
        
        let p = Promise<STMessage, STError>()
        
        let request = STSocketRequestBuilder.loadMessage(messageId: id).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(.loadMessageError)
            }
            else if let message = STMessage(JSON: response!) {
                
                p.success(message)
            }
        }
        
        return p.future
    }
    
    func updateUserNotificationSettings(settings: STUserNotificationSettings, userId: Int) -> Future<STUser, STError> {
        
        let p = Promise<STUser, STError>()
        
        let request = STSocketRequestBuilder.updateUserNotificationSettings(settings: settings, userId: userId).request
        
        self.sendRequest(request: request) { (response, error) in
            
            if error != nil {
                
                p.failure(STError.updateNotificationSettingsError)
            }
            else if let user = STUser(JSON: response!) {
                
                p.success(user)
            }
        }
        
        return p.future
    }
    
    @objc func onApplicationDidBecomeActiveNotification() {
        
        if let socket = self.socket {
            
            if socket.status != .connected {
                
                socket.connect()
            }
        }
    }
    
    @objc func onApplicationDidEnterBackgroundNotification() {
        
        if let socket = self.socket {
            
            if socket.status == .connected {
                
                socket.disconnect()
            }
        }
    }
    
    // MARK: Private methods
    fileprivate func sendRequest(request: STSocketRequest,
                                 callback: @escaping (_ json: [String : Any]?, _ error: [String : Any]?) -> Void) {
        
        self.socketConnect { [weak self] in
            
            debugPrint("================================")
            debugPrint("request id: \(request.requestId)")
            debugPrint("================================")
            
            self?.requestCallbacks[request.requestId] = callback
            self?.socket?.emit("request", request.payLoad)
        }
    }
    
    fileprivate func socketSetup() {
        
        let serverUrl = URL(string: serverUrlString)!
        
        let cookies = HTTPCookieStorage.shared.cookies?.filter({ $0.domain == "." + serverUrl.host! })
        
        let config: SocketIOClientConfiguration = [.log(true),
                                                   .forceWebsockets(true),
                                                   .path("/api/websocket"),
                                                   .cookies(cookies ?? [])]
        
        self.socket = SocketIOClient(socketURL: URL(string: serverUrlString)!, config: config)
        
        self.socket!.on("event") { (data, ack) in

            if
                let data = data[0] as? [String : Any],
                let type = data["type"] as? String,
                let object = data["data"] as? [String : Any] {
                
                switch type {
                    
                case "message":
                    
                    guard let message = STMessage(JSON: object) else {
                        
                        return
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(kReceiveMessageNotification), object: message)
                    
                    break
                    
                case "dialog_badge":
                    
                    guard let badge = STDialogBadge(JSON: object) else {
                        
                        return
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(kReceiveDialogBadgeNotification), object: badge)
                    
                    break
                    
                default:
                    break
                    
                }
            }
        }
        
        self.socket!.on("response") { (data, ack) in
            
            guard let json = self.serializeJSON(data: data) else {
                
                return
            }
            
            if let requestId = json["request_id"] as? String {
                
                if let callback = self.requestCallbacks[requestId] {
                    
                    self.requestCallbacks.removeValue(forKey: requestId)
                    
                    if let data = json["data"] as? [String : Any] {
                        
                        callback(data, nil)
                    }
                    else {
                        
                        callback(nil, json)
                    }
                }
            }
        }
    }
    
    fileprivate func serializeJSON(data: [Any]) -> [String : AnyObject]? {
        
        // converting data to json
        guard let responseString = data[0] as? String else {
            
            return nil
        }
        
        let responseData = responseString.data(using: String.Encoding.utf8)
        
        var json: [String : AnyObject]? = nil
        
        do {
            
            json = try JSONSerialization.jsonObject(with: responseData!, options: []) as? [String : AnyObject]
        }
        catch let error {
            
            debugPrint(error)
        }
        
        return json
    }
    
    fileprivate func socketConnect(callback:@escaping () -> Void) {
        
        if self.socket?.status != .connected {
            
            self.socket?.connect()
            self.socket?.once("connect") { (data, ack) in
                
                callback()
            }
        }
        else {
            
            callback()
        }
    }
}
