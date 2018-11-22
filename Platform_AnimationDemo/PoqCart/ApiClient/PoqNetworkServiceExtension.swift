//
//  PoqNetworkServiceExtension.swift
//  PoqCart
//
//  Created by Balaji Reddy on 18/06/2018.
//

import Foundation
import PoqNetworking

/// The PoqNetworkTaskTypeProvider for Cart
public enum PoqCartNetworkTask: String, PoqNetworkTaskTypeProvider {
    public var type: String {
        return rawValue
    }
    
    case getCart
    case postCart
}

/// An enum that defines the API paths for the Cart
///
/// - cart: The path for the Cart endpoint
public enum PoqCartNetworkTaskConfig: String {
   
    case cart = "/cart"
}

extension PoqNetworkService {
    
    /// This method calls the GET Cart endpoint to fetch the Cart
    ///
    /// - Returns: The PoqNetworkTask instance for the requrest
    @discardableResult
    public final func getCart() -> PoqNetworkTask<DecodableParser<Cart>> {
        
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqCartNetworkTask.getCart, httpMethod: .GET)
        let networkTask = PoqNetworkTask<DecodableParser<Cart>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setPath(format: PoqCartNetworkTaskConfig.cart.rawValue)
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    /// This method calls the POST Cart endpoint to update the Cart
    ///
    /// - Parameter cartRequestBody: The cart details to be updated
    /// - Returns: The PoqNetworkTask instance for the request
    @discardableResult
    public final func postCart(cartRequestBody: UpdateCartRequest) -> PoqNetworkTask<DecodableParser<Cart>> {
        
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqCartNetworkTask.postCart, httpMethod: .POST)
        let networkTask = PoqNetworkTask<DecodableParser<Cart>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setPath(format: PoqCartNetworkTaskConfig.cart.rawValue)
        
        networkRequest.setBody(cartRequestBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
}
