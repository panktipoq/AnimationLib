//
//  GenericNetworkTaskDelegate.swift
//  PoqNetworking
//
//  Created by Balaji Reddy on 01/10/2018.
//

import Foundation

public enum GenericNetworkTaskDelegateError: Error {
    case unknownError
    case unexpectedDataType
}

public class GenericNetworkTaskDelegate<R>: PoqNetworkTaskDelegate {
    
    private let completion: ((Result<R>) -> Void)
    
    public init(completion: @escaping ((Result<R>) -> Void)) {
        self.completion = completion
    }
    
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {}
    
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        networkTaskDidComplete(networkTaskType, result: result, statusCode: 200)
    }
    
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?, statusCode: Int) {
        
        // No payload received when status code is not 200
        guard statusCode == 200 else {
            
            completion(.success(nil))
            return
        }
        
        if let result = result as? R {
            
            completion(.success(result))
            
        } else {
            completion(.failure(GenericNetworkTaskDelegateError.unexpectedDataType))
        }
    }
    
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        completion(.failure(error ?? GenericNetworkTaskDelegateError.unknownError))
    }
}
