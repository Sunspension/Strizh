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
    
    func updateUserImageInDB(image: UIImage) {
        
        STUser.realm.beginWrite()
        
        self.imageData = UIImageJPEGRepresentation(image, 1)
        
        do {
            
            try STUser.realm.commitWrite()
        }
        catch {
            
            print("Caught an error when was trying to make commit to Realm")
        }
    }
    
    func updateUserImage() {
        
        if !self.imageUrl.isEmpty {
            
            let width = Int(90 * UIScreen.main.scale)
            
            let queryResize = "?resize=w[\(width)]h[\(width)]q[100]e[true]"
            
            let urlString = self.imageUrl + queryResize
            
            let url = URL(string: urlString)!
            
            AppDelegate.appSettings.imageDownloader.download(URLRequest(url: url)) { [unowned self] response in
                
                if let error = response.result.error {
                    
                    print("image error: \(error.localizedDescription)")
                }
                
                if let image = response.value {
                    
                    STUser.realm.beginWrite()
                    
                    self.imageData = UIImageJPEGRepresentation(image, 1)
                    
                    do {
                        
                        try STUser.realm.commitWrite()
                    }
                    catch {
                        
                        print("Caught an error when was trying to make commit to Realm")
                    }
                }
            }
        }
    }
    
    func refresh() {
        
        AppDelegate.appSettings.api.loadUser(transport: .webSocket, userId: self.id)
            .onSuccess(callback: { user in
                
                user.writeToDB()
                user.updateUserImage()
            })
    }
}
