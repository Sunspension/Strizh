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

class ImageUploadOperation : Operation {
    
    enum State {
        
        case ready, executing, finished
    }
    
    private let image: Data
    
    var state = State.ready {
        
        willSet {
            
            self.didChangeState?(newValue)
        }
    }
    
    var file: STFile?
    
    var error: STImageUploadError?
    
    var uploadProgressChanged: ((Double) -> Void)?
    
    var didChangeState: ((State) -> Void)?
    
    var uploadProgress = 0.0
    
    override var isAsynchronous: Bool {
        
        return true
    }
    
    override var isExecuting: Bool {
        
        return state == .executing
    }
    
    override var isFinished: Bool {
        
        return state == .finished
    }
    
    init(image: Data) {
        
        self.image = image
    }
    
    override func start() {
        
        if self.isCancelled {
            
            state = .finished
        }
        else {
            
            state = .ready
            main()
        }
    }
    
    override func main() {
        
        if self.isCancelled {
            
            state = .finished
        }
        else {
            
            state = .executing
        }
        
        AppDelegate.appSettings.api.uploadImage(image: self.image, uploadProgress: self.progressChanged)
            
            .onSuccess { [unowned self] file in
                
                self.file = file
                self.state = .finished
            }
            .onFailure { error in
                
                self.error = error
                self.state = .finished
            }
    }
    
    private func progressChanged(progress: Double) {
        
        self.uploadProgress = progress
        self.uploadProgressChanged?(progress)
    }
}
