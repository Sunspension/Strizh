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
import ReactiveKit

class ImageUploader {
    
    private let uploadQueue = OperationQueue()
    
    private let operationsLimit = 3
    
    var operations = [String : ImageUploadOperation]()
    
    var completeAllOperations: (() -> Void)?
    
    var bag = DisposeBag()
    
    
    init() {
        
        uploadQueue.maxConcurrentOperationCount = operationsLimit
        
        uploadQueue.reactive.keyPath("operations", ofType: [Operation].self).observeNext { operations in
            
            if operations.count == 0 {
                
                DispatchQueue.main.async {
                    
                    self.completeAllOperations?()
                }
            }
            
        }.dispose(in: bag)
    }
    
    func uploadImages(images: [(Data, String)]) {
        
        for (image, id) in images {
            
            let uploadOperation = ImageUploadOperation(image: image, identifier: id)
            
            uploadOperation.queuePriority = .low
            uploadOperation.qualityOfService = .background
            self.operations[id] = uploadOperation
        }
        
        self.uploadQueue.addOperations(self.operations.map({ $0.value }), waitUntilFinished: false)
    }
}
