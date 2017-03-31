//
//  ImageUploader.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 12/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation
import UIKit
import ReactiveKit

class ImageUploader {
    
    fileprivate let uploadQueue = OperationQueue()
    
    fileprivate let operationsLimit = 3
    
    var operations = [String : ImageUploadOperation]()
    
    var completeAllOperations: (() -> Void)?
    
    var bag = DisposeBag()
    
    let context = ExecutionContext.main
    
    init() {
        
        uploadQueue.maxConcurrentOperationCount = operationsLimit
        
        uploadQueue.reactive.keyPath("operations", ofType: [Operation].self, context: context)
            
            .observeNext { operations in
                
                if operations.count == 0 {
                    
                    DispatchQueue.main.async {
                        
                        self.completeAllOperations?()
                    }
                }
                
            }.dispose(in: bag)
    }
    
    func uploadImages(_ images: [(Data, String)]) {
        
        for (image, id) in images {
            
            let uploadOperation = ImageUploadOperation(image: image, identifier: id)
            
            uploadOperation.queuePriority = .low
            uploadOperation.qualityOfService = .background
            self.operations[id] = uploadOperation
        }
        
        self.uploadQueue.addOperations(self.operations.map({ $0.value }), waitUntilFinished: false)
    }
}
