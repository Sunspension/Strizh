//
//  ModelExtensions.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 13/02/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import AlamofireImage

extension STUser {
    
    func updateUserImage() {
        
        if let url = URL(string: self.imageUrl) {
            
            AppDelegate.appSettings.imageDownloader.download(URLRequest(url: url)) { resposne in
                
                if let image = resposne.value {
                    
                    self.imageData = UIImageJPEGRepresentation(image, 1)
                    self.writeToDB()
                }
            }
        }
    }
    
    func refresh() {
        
        AppDelegate.appSettings.api.loadUser(transport: .webSocket, userId: self.id)
            .onSuccess(callback: { user in
                
                user.updateUserImage()
            })
    }
}
