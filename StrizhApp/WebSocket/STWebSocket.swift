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
    
    private var socket: SocketIOClient?
    
    private var serverUrlString: String
    
    
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
        
        self.sendRequest(request: request) { json in
            
            if let user = STUser(JSON: json) {
                
                p.success(user)
            }
            else {
                
//                p.failure(STError.anyError(error: <#T##Error#>))
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
        
        self.sendRequest(request: request) { json in
            
            if let user = STUser(JSON: json) {
                
                p.success(user)
            }
        }
        
        return p.future
    }
    
    
    func loadFeed(filter: STFeedFilter, page: Int, pageSize: Int,
                  isFavorite: Bool, searchString: String?) -> Future<STFeed, STError> {
        
        let p = Promise<STFeed, STError>()
        
        let request = STSocketRequestBuilder.loadFeed(filter: filter, page: page, pageSize: pageSize, isFavorite: isFavorite, searchString: searchString).request
        
        self.sendRequest(request: request) { json in
            
            if let feed = STFeed(JSON: json) {
                
                p.success(feed)
            }
        }
        
        return p.future
    }
    
    func loadPersonalPosts(minId: Int, pageSize: Int) -> Future<STFeed, STError> {
        
        let p = Promise<STFeed, STError>()
        
        let request = STSocketRequestBuilder.loadPersonalPosts(minId: minId, pageSize: pageSize).request
        
        self.sendRequest(request: request) { json in
            
            if let feed = STFeed(JSON: json) {
                
                p.success(feed)
            }
        }
        
        return p.future
    }
    
    func favorite(postId: Int, favorite: Bool) -> Future<STPost, STError> {
        
        let p = Promise<STPost, STError>()
        
        let request = STSocketRequestBuilder.favorite(postId: postId, favorite: favorite).request
        
        self.sendRequest(request: request) { json in
            
            if let post = STPost(JSON: json) {
                
                p.success(post)
            }
            else {
                
                p.failure(.favoriteFailure)
            }
        }
        
        return p.future
    }
    
    func archivePost(postId: Int, isArchived: Bool) -> Future<STPost, STError> {
        
        let p = Promise<STPost, STError>()
        
        let request = STSocketRequestBuilder.archivePost(postId: postId, isArchived: isArchived).request
        
        self.sendRequest(request: request) { json in
            
            if let post = STPost(JSON: json) {
                
                p.success(post)
            }
            else {
                
                p.failure(.archiveFailure)
            }
        }
        
        return p.future
    }
    
    func deletePost(postId: Int) -> Future<STPost, STError> {
        
        let p = Promise<STPost, STError>()
        
        let request = STSocketRequestBuilder.deletePost(postId: postId).request
        
        self.sendRequest(request: request) { json in
            
            if let post = STPost(JSON: json) {
                
                p.success(post)
            }
            else {
                
                p.failure(.archiveFailure)
            }
        }
        
        return p.future
    }
    
    func loadContacts() -> Future<[STContact], STError> {
        
        let p = Promise<[STContact], STError>()
        
        let request = STSocketRequestBuilder.loadContacts.request
        
        self.sendRequest(request: request) { json in
            
            if let contacts = json["contact"] as? [[String : Any]] {
                
                if let remoteContacts = Mapper<STContact>().mapArray(JSONArray: contacts) {
                    
                    p.success(remoteContacts)
                }
            }
            else {
                
                p.failure(.loadContactsFailure)
            }
        }
        
        return p.future
    }
    
    func uploadContacts(contacts: [CNContact]) -> Future<[STContact], STError> {
        
        let p = Promise<[STContact], STError>()
        
        let request = STSocketRequestBuilder.uploadContacts(contacts: contacts).request
        
        self.sendRequest(request: request) { json in
            
            if let contacts = json["contact"] as? [[String : Any]] {
                
                if let remoteContacts = Mapper<STContact>().mapArray(JSONArray: contacts) {
                    
                    p.success(remoteContacts)
                }
            }
            else {
                
                p.failure(.loadContactsFailure)
            }
        }
        
        return p.future
    }
    
    func createPost(post: STUserPostObject) -> Future<STPost, STError> {
        
        let p = Promise<STPost, STError>()
        
        let request = STSocketRequestBuilder.createPost(post: post, update: false).request
        
        self.sendRequest(request: request) { json in
            
            if let post = STPost(JSON: json) {
                
                p.success(post)
            }
            else {
                
                p.failure(.favoriteFailure)
            }
        }
        
        return p.future
    }
    
    func updatePost(post:STUserPostObject) -> Future<STPost, STError> {
        
        let p = Promise<STPost, STError>()
        
        let request = STSocketRequestBuilder.createPost(post: post, update: true).request
        
        self.sendRequest(request: request) { json in
            
            if let post = STPost(JSON: json) {
                
                p.success(post)
            }
            else {
                
                p.failure(.favoriteFailure)
            }
        }
        
        return p.future
    }
    
    func loadDialogs(page: Int, pageSize: Int) -> Future<STDialogsPage, STError> {
        
        let p = Promise<STDialogsPage, STError>()
        
        let request = STSocketRequestBuilder.loadDialogs(page: page, pageSize: pageSize).request
        
        self.sendRequest(request: request) { json in
            
            if let post = STDialogsPage(JSON: json) {
                
                p.success(post)
            }
            else {
                
                p.failure(.loadDialogsError)
            }
        }
        
        return p.future
    }
    
    func loadDialogMessages(dialog: STDialog, pageSize: Int, lastId: Int?) -> Future<[STMessage], STError> {
        
        let p = Promise<[STMessage], STError>()
        
        let request = STSocketRequestBuilder.loadDialogMessages(dialog: dialog, pageSize: pageSize, lastId: lastId).request
        
        self.sendRequest(request: request) { json in
            
            if let messagePath = json["message"] as? [[String : Any]] {
                
                if let messages = Mapper<STMessage>().mapArray(JSONArray: messagePath) {
                    
                    p.success(messages)
                }
            }
            else {
                
                p.failure(.loadContactsFailure)
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
                                 callback: @escaping (_ json: [String : Any]) -> Void) {
        
        self.socketConnect {
            
            print("================================")
            print("request id: \(request.requestId)")
            print("================================")
            
            self.socket?.emit("request", request.payLoad)
            
            self.socket?.on("response") { (data, ack) in
                
                // converting data to json
                guard let responseString = data[0] as? String else {
                    
                    return
                }
                
                let responseData = responseString.data(using: String.Encoding.utf8)
                
                var json = [String : AnyObject]()
                
                do {
                    
                    json = try JSONSerialization.jsonObject(with: responseData!, options: []) as! [String : AnyObject]
                }
                catch let error {
                    
                    print(error)
                }
                
                print(json)
                
                if let requestId = json["request_id"] as? String,
                    requestId == request.requestId {
                    
                    if let data = json["data"] as? [String : Any] {
                        
                        callback(data)
                    }
                }
            }
        }
    }
    
    fileprivate func socketSetup() {
        
        let config: SocketIOClientConfiguration = [.log(true),
                                                   .forceWebsockets(true),
                                                   .path("/websocket"),
                                                   SocketIOClientOption.cookies(HTTPCookieStorage.shared.cookies!)]
        
        self.socket = SocketIOClient(socketURL: URL(string: serverUrlString)!, config: config)
        
        self.socket?.on("event") { (data, ack) in
            
            print(data)
        }
    }
    
    fileprivate func socketConnect(callback:@escaping () -> Void) {
        
        if self.socket?.status != .connected {
            
            self.socket?.connect()
            
            self.socket?.once("connect") { (data, ack) in
                
                print("===============\n")
                print("socket connected")
                print("===============\n")
                
                callback()
            }
        }
        else {
            
            callback()
        }
    }
}
