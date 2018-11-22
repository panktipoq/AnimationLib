//
//  PoqOperation.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 22/07/2016.
//
//

import Foundation

/**
 Base class for all operations
 Should simplify and minify subclasses, since whole work about
 */
open class PoqOperation: Operation {
    
    /// aync operation use KVO to track state of operation. Simplify our code and use one var state and let os know that other depends on state
    static let stateDependedKeys: [String] = ["isExecuting", "isFinished"]
    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if stateDependedKeys.contains(key) {
            return ["state"]
        }
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    fileprivate enum State {
        /// The initial state of an `Operation`.
        case initialized
        
        /// The `Operation` is executing.
        case executing
        
        /// The `Operation` has finished executing.
        case finished
    }
    
    fileprivate final var _state = State.initialized
    fileprivate final var state: State {
        get {
            return _state
        }
        set(newState) {
            willChangeValue(forKey: "state")
            
            // we assume here no onewill try to move wrong order of states, aka, from finished to executing
            _state = newState
            
            didChangeValue(forKey: "state")
        }
    }
    
    public override final var isExecuting: Bool {
        return state == .executing
    }
    
    public override final var isFinished: Bool {
        return state == .finished
    }
    
    /// By default, assume that operation is async
    open override var isAsynchronous: Bool {
        return true
    }
    
    public override final func start() {
        // NSOperation.start() contains important logic that shouldn't be bypassed.
        super.start()
        
        // If the operation has been cancelled, we still need to enter the "Finished" state.
        if isCancelled {
            finish()
        }
    }
    
    public override final func main() {
        
        state = .executing
        if !isCancelled {
            execute()
        } else {
            finish()
        }
    }
    
    fileprivate var hasFinishedAlready = false

    // MARK: API
    
    public final func finish() {
        guard !hasFinishedAlready else {
            return
        }
        
        hasFinishedAlready = true
        state = .finished
    }

    // MARK: Subclass

    /**
     `execute()` is the entry point of execution for all `Operation` subclasses.
     If you subclass `Operation` and wish to customize its execution, you would
     do so by overriding the `execute()` method.
     
     At some point, your `Operation` subclass must call "finish"
     methods defined above; this is how you indicate that your operation has
     finished its execution, and that operations dependent on yours can re-evaluate
     their readiness state.
     */
    open func execute() {
        assert(false, "\(type(of: self)) must override `execute()`.")
        
        finish()
    }
}

