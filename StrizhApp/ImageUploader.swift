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
    
    private let concurrentBarrierQueue = DispatchQueue(label: "com.strizhApp.concurrentBarrierQueue",
                                                       attributes: DispatchQueue.Attributes.concurrent)
    
    private let operationsLimit = 1
    
    var operations: [Operation] {
        
        return uploadQueue.operations
    }
    
    var completeAllTasks: (() -> Void)?
    
    
    init() {
        
        uploadQueue.maxConcurrentOperationCount = operationsLimit
    }
    
    func uploadImage(image: Data) {
        
        let uploadOperation = ImageUploadOperation(image: image, concurrentQueue: self.concurrentBarrierQueue)
//        uploadOperation.queuePriority = .low
//        uploadOperation.qualityOfService = .background
        
        uploadOperation.completionBlock = {
            
            print("operation complete")
        }
        
        uploadQueue.addOperation(uploadOperation)
    }
    
    func startWaitingTasks() {
        
        concurrentBarrierQueue.async(flags: .barrier) {
            
            var complete = true
            
            var limit = self.operationsLimit
            
            for operation in self.operations {
                
                let task = operation as! ImageUploadOperation
                
                if task.state == .ready {
                    
                    task.start()
                    complete = false
                    
                    limit -= limit
                    
                    if limit == 0 {
                        
                        break
                    }
                }
                else if task.state == .executing {
                    
                    complete = false
                }
            }
            
            if complete {
                
                DispatchQueue.main.async {
                    
                    self.completeAllTasks?()
                }
            }
        }
    }
}
