//
//  BraintreeDeletePaymentSourceOperation.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 09/08/2016.
//
//

import Foundation
import PoqNetworking

final class BraintreeDeletePaymentSourceOperation: PoqOperation {
    
    let paymentSource: PoqPaymentSource
    let completion: BraintreeOperationCompletion
    init (paymentSource: PoqPaymentSource, completion: @escaping BraintreeOperationCompletion) {
        self.paymentSource = paymentSource
        self.completion = completion
        super.init()
    }
    
    // TODO: add unit test on all possible scenarios - make sure completion always called
    override final func execute() {
        PoqNetworkService(networkTaskDelegate: self).removeBraintreePaymentSource(paymentSource.paymentSourceToken)
        
    }

}


extension BraintreeDeletePaymentSourceOperation: PoqNetworkTaskDelegate {
    
    func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {}
    
    func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {

        // Don't try to read result - it is fake, just to pass checks in network task
        completion(nil)
        finish()
    }
    
    func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        let resError: NSError = BraintreeCustomerOperation.createError(withMessage: error?.localizedDescription)
        completion(resError)
        finish()
    }
    
}
