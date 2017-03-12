//
//  ImageUploader.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import UIKit
import BrightFutures

struct ImageUploader {
    
    private let uploadQueue = OperationQueue()
    
    var operations: [Operation] {
        
        return uploadQueue.operations
    }
    
    init() {
        
        uploadQueue.maxConcurrentOperationCount = 3
    }
    
    func uploadImage(image: Data) {
        
        let uploadOperation = ImageUploadOperation(image: image)
        uploadOperation.queuePriority = .low
        uploadOperation.qualityOfService = .background
        
        uploadQueue.addOperation(uploadOperation)
    }
    
    func startWaitingTasks() {
        
        for operation in self.operations {
            
            let task = operation as! ImageUploadOperation
            
            if task.state == .ready {
                
                task.start()
                break
            }
        }
    }
}
