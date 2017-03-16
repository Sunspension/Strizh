//
//  AsyncOperation.swift
//  StrizhApp
//
//  Created by Vladimir Kokhanevich on 15/03/2017.
//  Copyright © 2017 Vladimir Kokhanevich. All rights reserved.
//

import Foundation

/// An abstract class that makes building simple asynchronous operations easy.
/// Subclasses must implement `execute()` to perform any work and call
/// `finish()` when they are done. All `Operation` work will be handled
/// automatically.
open class AsyncOperation : Operation {
    
    enum OperationState: Int {
        
        case ready, executing, finished
        
        var stateDescription: String {
            
            switch self {
                
            case .ready:
                
                return "isReady"
                
            case .executing:
                
                return "isExecuting"
                
            case .finished:
                
                return "isFinished"
            }
        }
    }
    
    private let stateQueue = DispatchQueue(
        label: "com.myApp.operation.state",
        attributes: .concurrent)
    
    private var rawState = OperationState.ready
    
    var state: OperationState {
        
        get {
            
            return stateQueue.sync(execute: { rawState })
        }
        set {
            
            willChangeValue(forKey: newValue.stateDescription)
            
            stateQueue.sync(flags: .barrier, execute: { rawState = newValue })
            
            didChangeValue(forKey: newValue.stateDescription)
        }
    }
    
    public final override var isReady: Bool {
     
        return state == .ready && super.isReady
    }
    
    public final override var isExecuting: Bool {
        
        return state == .executing
    }
    
    public final override var isFinished: Bool {
        
        return state == .finished
    }
    
    
    public override final func start() {
        
        super.start()
        
        if isCancelled {
            
            finish()
            return
        }
        
        state = .executing
        execute()
    }
    
    /// Subclasses must implement this to perform their work and they must not
    /// call `super`. The default implementation of this function throws an
    /// exception.
    open func execute() {
        
        fatalError("Subclasses must implement `execute`")
    }
    
    /// Call this function after any work is done or after a call to `cancel()`
    /// to move the operation into a completed state.
    open func finish() {
        
        state = .finished
    }
}
