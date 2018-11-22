//
//  Array+Async.swift
//  PoqModuling
//
//  Created by Joshua White on 01/06/2018.
//

import Foundation

// TODO: Re-look into this and a better way of handling this for different protocols.
// This works for a single protocol: `extension Array where Element == AnyObject & PoqModule` but functions are generic.
extension Array {
    
    typealias ForEachAsyncBody = (_ element: Element, _ completion: @escaping () -> Void) -> Void
    typealias ForEachAsyncCompletion = (_ timeoutResult: DispatchTimeoutResult) -> Void
    
    /// An async version of `forEach`, useful for forward calling functionality completed through a single overall completion handler.
    /// - parameter timeout: The amount of time in seconds to wait for before timing out.
    /// - parameter body: **Required** closure to handle function forwarding.
    /// The `completionHandler` **must** be called to return to this function before timeout.
    /// - parameter completionHandler: Optional overall completion called after forwarding functionality to all elements.
    func forEachAsync(timeout: TimeInterval, body: @escaping ForEachAsyncBody, completion: ForEachAsyncCompletion? = nil) {
        var resultsRemaining = count
        
        // Array for completed objects to check if they were dealt with already.
        // Reason: UrbanAirship calls completion twice which is incorrect but kicks one of the correct calls out of the timeframe, this is to stop that.
        var completedObjects = [AnyObject]()
        
        // Schedule the timeout closure to guarentee completion.
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            if resultsRemaining > 0 {
                resultsRemaining = -1
                completion?(.timedOut)
            }
        }
        
        // We loop through all elements forwarding the handler.
        for element in self {
            body(element) {
                // Call this on the main thread just in case to avoid a threading issue.
                DispatchQueue.main.async {
                    // Safeguarding against multiple completion calls causing crash due to overleaving.
                    if let object = element as? AnyClass {
                        if !completedObjects.contains(where: { $0 === object }) {
                            completedObjects.append(object)
                            resultsRemaining -= 1
                        }
                    } else {
                        resultsRemaining -= 1
                    }
                    
                    if resultsRemaining == 0 {
                        resultsRemaining = -1
                        completion?(.success)
                    }
                }
            }
        }
    }
    
    /// The first parameter is the current overall group result starting from the initial result.
    /// The second parameter is the next partial result of the last returned single element handler call.
    typealias ReduceAsyncResultCombiner<Result> = (_ groupResult: Result, _ nextPartialResult: Result) -> Result
    typealias ReduceAsyncBody<Result> = (_ element: Element, _ completion: @escaping (Result) -> Void) -> Void
    typealias ReduceAsyncCompletion<Result> = (_ result: Result, _ timeoutResult: DispatchTimeoutResult) -> Void
    
    /// An async version of `reduce`, useful for forward calling functionality completed through a single overall completion handler and result.
    /// - parameter initialResult: The initial result to start with for the reducing part of this function.
    /// - parameter timeout: The amount of time in seconds to wait for before timing out.
    /// - parameter resultCombiner: The function that combines the result of the current `groupResult` and the `nextPartialResult`.
    /// - parameter body: **Required** closure to handle function forwarding.
    /// The `completionHandler` **must** be called to return to this function before timeout.
    /// - parameter completion: The final group result of this function with whether it timed out.
    func reduceAsync<Result>(_ initialResult: Result, timeout: TimeInterval, resultCombiner: @escaping ReduceAsyncResultCombiner<Result>, body: @escaping ReduceAsyncBody<Result>, completion: @escaping ReduceAsyncCompletion<Result>) {
        var groupResult = initialResult
        var resultsRemaining = count
        
        // Array for completed objects to check if they were dealt with already.
        // Reason: UrbanAirship calls completion twice which is incorrect but kicks one of the correct calls out of the timeframe, this is to stop that.
        var completedObjects = [AnyObject]()
        
        // Schedule the timeout closure to guarentee completion.
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            if resultsRemaining > 0 {
                resultsRemaining = -1
                completion(groupResult, .timedOut)
            }
        }
        
        // We loop through all elements forwarding the handler.
        for element in self {
            body(element) { (result) in
                // Call this on the main thread just in case to avoid a threading issue.
                DispatchQueue.main.async {
                    // We reduce the handler's result using the result combiner.
                    groupResult = resultCombiner(groupResult, result)
                    
                    // Safeguarding against multiple completion calls causing crash due to overleaving.
                    if let object = element as? AnyClass {
                        if !completedObjects.contains(where: { $0 === object }) {
                            completedObjects.append(object)
                            resultsRemaining -= 1
                        }
                    } else {
                        resultsRemaining -= 1
                    }
                    
                    if resultsRemaining == 0 {
                        resultsRemaining = -1
                        completion(groupResult, .success)
                    }
                }
            }
        }
    }
    
}
