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

class STWebSocket {
    
    private var socket: SocketIOClient?
    
    private var serverUrlString: String
    
    init(serverUrlString: String) {
        
        self.serverUrlString = serverUrlString
    }
    
    func connect() {
        
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
    
    func loadFeed(page: Int, pageSize: Int) -> Future<([STPost], [STUser]), STError> {
        
        let p = Promise<([STPost], [STUser]), STError>()
        
        DispatchQueue.global().async {
            
            let request = STSocketRequestBuilder.loadFeed(page: page, pageSize: pageSize).request
            
            self.sendRequest(request: request) { json in
                
                if let post = json["post"] as? [[String : Any]] {
                    
                    if let posts = Mapper<STPost>().mapArray(JSONArray: post) {
                        
                        if let user = json["user"] as? [[String : Any]] {
                            
                            if let users = Mapper<STUser>().mapArray(JSONArray: user) {
                                
                                DispatchQueue.main.async {
                                    
                                    p.success((posts, users))
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return p.future
    }
    
    
    // MARK: Private methods
    
    fileprivate func sendRequest(request: STSocketRequest,
                                 callback: @escaping (_ json: [String : Any]) -> Void) {
        
        self.socketConnect {
            
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
            
            self.socket!.connect()
            
            self.socket?.on("connect") { (data, ack) in
                
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
