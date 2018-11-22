//
//  OperationQueueExtension.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 26/07/2017.
//
//

import Foundation

fileprivate let GlobalQueue: OperationQueue = {
    let res = OperationQueue()
    res.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
    res.qualityOfService = .utility
    res.name = "Poq.Global.Queue"
    return res
}()

extension OperationQueue {
    
    /// General purpose concurrent operation queue
    /// Should be use across app for any operation
    @nonobjc
    static var global: OperationQueue {
        return GlobalQueue
    }
}

