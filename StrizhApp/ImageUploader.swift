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
    
    private let operationsLimit = 3
    
    var operations = [ImageUploadOperation]()
    
    var description: String {
        
        return self.operations.reduce("") { (result, operation) -> String in
            
            return result + operation.state.stateDescription + "\n"
        }
    }
    
    var completeAllTasks: (() -> Void)?
    
    
    init() {
        
        uploadQueue.maxConcurrentOperationCount = operationsLimit
    }
    
    mutating func uploadImages(images: [Data]) {
        
        var operations = [ImageUploadOperation]()
        
        for image in images {
            
            let uploadOperation = ImageUploadOperation(image: image)
            
            uploadOperation.queuePriority = .low
            uploadOperation.qualityOfService = .background
            operations.append(uploadOperation)
        }
        
        self.operations.append(contentsOf: operations)
        self.uploadQueue.addOperations(operations, waitUntilFinished: false)
    }
}
