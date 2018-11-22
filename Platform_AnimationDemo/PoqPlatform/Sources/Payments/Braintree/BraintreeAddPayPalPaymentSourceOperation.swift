//
//  BraintreeAddPayPalPaymentSourceOperation.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 24/07/2016.
//
//

import Braintree
import Foundation
import PoqNetworking
import PoqUtilities

class BraintreeAddPayPalPaymentSourceOperation: BraintreeCustomerOperation {
    
    weak var presentingDelegate: BTViewControllerPresentingDelegate?
    
    
    // TODO: add unit test on all possible scenarios - make sure completion always called
    override final func execute() {
        
        guard let braintreeClient = BraintreeHelper.sharedInstance.braintreeClient else {
            let error: NSError = BraintreeCustomerOperation.createError(withMessage: nil)
            completion(error)
            finish()
            return
        }
        
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
        
        payPalDriver.viewControllerPresentingDelegate = presentingDelegate
        //payPalDriver.appSwitchDelegate = self
        
        payPalDriver.authorizeAccount() {
            [weak self]
            (tokenizedPayPalAccount: BTPayPalAccountNonce?, error: Error?) -> Void in
            
            guard let strongSelf = self else {
                Log.error("How operation deallocated before response arrived??")
                return
            }
            
            guard let validNonce: BTPayPalAccountNonce = tokenizedPayPalAccount else {
                Log.error("\(String(describing: error?.localizedDescription))")
                
                let resError: NSError = BraintreeCustomerOperation.createError(withMessage: nil)
                strongSelf.completion(resError)
                strongSelf.finish()
                return
            }
            
            PoqNetworkService(networkTaskDelegate: strongSelf).addBraintreePaymentMethod(BraintreeHelper.sharedInstance.customerId, nonce: validNonce.nonce)
            
        }
        
    }

    
}

