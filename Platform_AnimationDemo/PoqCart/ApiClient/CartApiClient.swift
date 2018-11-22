//
//  CartApiClient.swift
//  PoqCart
//
//  Created by Balaji Reddy on 01/10/2018.
//

import Foundation
import PoqNetworking

/*
 
 This interface represents a type that implements methods that can interact with the Cart API
 
 It is a generic protocol with the network model type being an associated type.
 
 */
public protocol CartApiClient {
    
    associatedtype NetworkModelType
    typealias CartCompletionType = (Result<[NetworkModelType]>) -> Void
    
    /// This method fetches the Cart from the Cart API
    ///
    /// - Parameter completion: This completion block is called with the response of the Cart API
    func getCart(completion: @escaping CartCompletionType)
    
    /// This methods posts the updated Cart details to the Cart API
    ///
    /// - Parameters:
    ///   - body: The POST request body with the details of the updated Cart
    ///   - completion: This completion block is called with the response of the POST Cart API request
    func postCart(body: UpdateCartRequest, completion: @escaping CartCompletionType)
}

/*
 
 
 */
public class PoqCartApiClient: CartApiClient, GenericNetworkTaskDelegatable {
    
    public typealias NetworkModelType = Cart
    
    private func poqCartCompletion(_ completion: @escaping CartCompletionType) -> CartCompletionType {
        
        let poqCartCompletion: CartCompletionType = { result in
            
            if case Result<[NetworkModelType]>.failure(let error) = result {
                
                let networkError = PoqCartApiClient.getNetworkError(for: error)
                let errorResult = Result<[NetworkModelType]>.failure(networkError)
                completion(errorResult)
                return
            }
            
            completion(result)
        }
        
        return poqCartCompletion
    }
    
    public var delegates = [UUID: AnyObject]()
    
    public init() { }
    
    public func getCart(completion: @escaping CartCompletionType) {
        
        let delegate = createDelegate(completion: poqCartCompletion(completion))
        PoqNetworkService(networkTaskDelegate: delegate).getCart()
    }
    
    public func postCart(body: UpdateCartRequest, completion: @escaping CartCompletionType) {
        
        let delegate = createDelegate(completion: poqCartCompletion(completion))
        PoqNetworkService(networkTaskDelegate: delegate).postCart(cartRequestBody: body)
    }
    
    fileprivate static func getNetworkError(for error: Error) -> NetworkError {
        
        switch error {
            
        case GenericNetworkTaskDelegateError.unknownError:
            
            return NetworkError.unspecified
            
        case GenericNetworkTaskDelegateError.unexpectedDataType:
            
            return NetworkError.invalidResponse
            
        default:
            
            let error = error as NSError
            
            return (error.domain == NSURLErrorDomain ? NetworkError.urlError(code: error.code, description: error.localizedDescription) : NetworkError.unspecified)
        }
    }
}
