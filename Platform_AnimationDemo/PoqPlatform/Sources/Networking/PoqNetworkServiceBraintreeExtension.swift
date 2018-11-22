//
//  PoqNetworkServiceBraintreeExtension.swift
//  Poq.iOS.Belk
//
//  Created by Nikolay Dzhulay on 11/16/16.
//
//

import Foundation
import PoqNetworking

// MARK: - Braintree

extension PoqNetworkService {
    
    public final func generateBraintreeClientToken() {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.braintreeGenerateToken, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqBraintreeToken>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.braintreeApiGenerateToken)
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func generateBraintreeNonce(_ paymentSourceToken: String) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.braintreeGenerateNonce, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqBraintreeNonce>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.braintreeApiGenerateNonce, paymentSourceToken)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /// Add payment source to client
    /// - parameter customerId: pass nil, user doen't exist yet.
    /// - parameter nonce: payment method Nonce from Braintree
    public final func addBraintreePaymentMethod(_ customerId: String?, nonce: String) {
        let httpMethod: HTTPMethod = customerId == nil ? .POST : .PUT
        
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.braintreeUpdateCustomer, httpMethod: httpMethod)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqBraintreeCustomer>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        if let existedCustomerId: String = customerId {
            networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.braintreeApiUpdateCustomer, existedCustomerId)
        } else {
            networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.braintreeApiCreateCustomer)
        }
        
        let postBody = PoqBraintreePaymentPostBody()
        postBody.paymentMethodNonce = nonce
        
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /// Delete payment token from current customer
    public final func removeBraintreePaymentSource(_ paymentSourceToken: String) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.braintreeDeletePaymentSource, httpMethod: .DELETE)
        
        // For BRAINTREE_DELETE_PAYMENT_SOURCE - we will get shallow customer, fake
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqBraintreeCustomer>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.braintreeApiDeletePaymentSource, paymentSourceToken)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getBraintreeCustomer(_ customerId: String) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.braintreeGetCustomer, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqBraintreeCustomer>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.braintreeApiGetCustomer, customerId)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
}
