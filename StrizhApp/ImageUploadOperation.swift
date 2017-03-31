//
//  ImageUploadOperation.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import UIKit
import BrightFutures
import Alamofire

class ImageUploadOperation : AsyncOperation {
    
    fileprivate let image: Data
    
    var file: STFile?
    
    var error: STImageUploadError?
    
    var uploadProgressChanged: ((Double) -> Void)?
    
    var uploadProgress = 0.0
    
    var identifier: String
    
    
    override var description: String {
        
        return String("state: \(self.state.stateDescription)")
    }
    
    init(image: Data, identifier: String = UUID().uuidString) {
        
        self.image = image
        self.identifier = identifier
    }
    
    override func execute() {
        
        AppDelegate.appSettings.api.uploadImage(image: self.image, uploadProgress: self.progressChanged)
            
            .onSuccess { [unowned self] file in
                
                self.file = file
                self.finish()
                
                self.completionBlock?()
            }
            .onFailure { [unowned self] error in
                
                self.error = error
                self.finish()
        }
    }
    
    fileprivate func progressChanged(_ progress: Double) {
        
        self.uploadProgress = progress
        self.uploadProgressChanged?(progress)
    }
}
