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
    
    private let image: Data
    
    var file: STFile?
    
    var error: STImageUploadError?
    
    var uploadProgressChanged: ((Double) -> Void)?
    
    var uploadProgress = 0.0
    
    
    override var description: String {
        
        return String("state: \(self.state.stateDescription)")
    }
    
    init(image: Data) {
        
        self.image = image
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
    
    private func progressChanged(progress: Double) {
        
        self.uploadProgress = progress
        self.uploadProgressChanged?(progress)
    }
}
