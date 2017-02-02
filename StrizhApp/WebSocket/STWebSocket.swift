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

private enum HTTPMethod : String {
    
    case get, post, put, delete
}


class STWebSocket {
    
    private var socket: SocketIOClient
    
    private var socketConnected = false
    
    
    init(serverUrlString: String) {
        
        let config: SocketIOClientConfiguration = [.log(true), .forcePolling(true), .path("/websocket")]
        self.socket = SocketIOClient(socketURL: URL(string: serverUrlString)!, config: config)
    }
    
    func connect() {
        
        self.socket.connect()
    }
    
    func loadUser(userId: Int) -> Future<STUser, STError> {
        
        let p = Promise<STUser, STError>()
        
        return p.future
    }
    
    fileprivate func socketSetup() {
        
        self.socket.on("connect") { [unowned self] (data, ack) in
            
            self.socketConnected = true
            
            print("===============\n")
            print("socket conneted")
            print("===============\n")
        }
        
        self.socket.on("response") { (data, ack) in
            
            
        }
    }
    
//    fileprivate func makePayload() -> [String : Any] {
//        
//    }
    
    fileprivate func makeQueryParameters() -> [String : Any] {
        
        let params = STQueryParameters()
        
        params
            .add(type: .conditions, params: ["ff" : "ff"])
            .add(type: .page, params: 20)
            .add(type: .filters, params: ["feed" : "true"])
        
        return params.params
    }
}
