//
//  BraintreeTokenGenerationOperation.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 22/07/2016.
//
//

import Braintree
import Foundation
import PoqNetworking
import PoqUtilities

/// This operation should take token fromAPI and create BTAPIClient using it
/// We shuld run only one operation at the time, if operation already executing - just add it as dependencies
/// Just in case operation will check - do BTClient exists or not. If exists - operation will resurn success
open class BraintreeTokenGenerationOperation: PoqOperation {
    
    var braintreeClient: BTAPIClient?

    override open func execute() {

        guard BraintreeHelper.sharedInstance.braintreeClient == nil else {
            finish()
            return
        }
        
        PoqNetworkService(networkTaskDelegate: self).generateBraintreeClientToken()
        
    }
}

extension BraintreeTokenGenerationOperation: PoqNetworkTaskDelegate {
    
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {}

    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        if let token: PoqBraintreeToken = result?.first as? PoqBraintreeToken, let tokenString: String = token.token, tokenString.count > 0 {
            let client = BTAPIClient(authorization: tokenString)
            BraintreeHelper.sharedInstance.braintreeClient = client
        } else {
            Log.error("Some wired happen, we got ok response but in the end - we can't get authorization token")
        }
        finish()
    }
    
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        Log.error("Got error while generate braintree token. Error: \(error?.localizedDescription ?? "nil" )")
        finish()
    }
}
