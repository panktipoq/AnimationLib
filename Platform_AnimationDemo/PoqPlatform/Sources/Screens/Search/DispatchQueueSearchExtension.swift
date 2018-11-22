//
//  DispatchQueueSearchExtension.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 2/20/17.
//
//

import Foundation

private let GlobalSearchWorkingQueue: DispatchQueue = DispatchQueue(label: "SearchWorkingQueue", qos: .userInitiated)  

/// We running some async tasks and we want to make sure they are FIFO
/// Lets create one queue for all tasks in search
extension DispatchQueue {
    static var searchWorkingQueue: DispatchQueue {
        return GlobalSearchWorkingQueue
    }
}
