//
//  GenericNetworkTaskDelegatable.swift
//  PoqNetworking
//
//  Created by Balaji Reddy on 04/10/2018.
//

import Foundation

public protocol GenericNetworkTaskDelegatable: AnyObject {
    
    var delegates: [UUID: AnyObject] { get set }
}

extension GenericNetworkTaskDelegatable {
    
    public func createDelegate<T>(completion: @escaping ((Result<T>) -> Void)) -> GenericNetworkTaskDelegate<T> {
        let uuid = UUID()
        let callCompletion: ((Result<T>) -> Void) = { [weak self] result in
            self?.delegates.removeValue(forKey: uuid)
            completion(result)
        }
        let delegate = GenericNetworkTaskDelegate<T>(completion: callCompletion)
        delegates[uuid] = delegate
        return delegate
    }
}
