//
//  STWebSocket.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 21/01/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import UIKit
import SocketIO
import BrightFutures
import ObjectMapper

struct STWebSocket {
    
    public func on(_ event: String) -> Future<UIView, STError> {
        
        let p = Promise<UIView, STError>()
        
        return p.future
    }
}
