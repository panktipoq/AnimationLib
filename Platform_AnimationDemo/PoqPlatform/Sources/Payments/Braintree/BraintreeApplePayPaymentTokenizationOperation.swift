//
//  BraintreeApplePayPaymentTokenizationOperation.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 28/07/2016.
//
//

import Braintree
import Foundation
import PassKit
import PoqNetworking
import PoqUtilities


class  BraintreeApplePayPaymentTokenizationOperation: PoqOperation {
    
    let payment: PKPayment
    let completion: (_ token: String?, _ error: NSError?) -> Void

    init(payment: PKPayment, completion: @escaping (_ token: String?, _ error: NSError?) -> Void) {
        self.payment = payment
        self.completion = completion
        
        super.init()
    }
    
    override final func execute() {
        
        guard let braintreeClient = BraintreeHelper.sharedInstance.braintreeClient else {
            let error: NSError = BraintreeCustomerOperation.createError(withMessage: nil)
            completion(nil, error)
            finish()
            return
        }
        
        let applePayClient = BTApplePayClient(apiClient: braintreeClient)
        applePayClient.tokenizeApplePay(payment) {
            [weak self]
            (tokenizedApplePayPayment, error) in
            
            DispatchQueue.main.async(execute: {
                [weak self] in
                guard let tokenizedApplePayPayment = tokenizedApplePayPayment else {
                    Log.error("error.localizedDescription = \(String(describing: error?.localizedDescription))")
                    let error: NSError = BraintreeCustomerOperation.createError(withMessage: error?.localizedDescription)
                    self?.completion(nil, error)
                    
                    return
                }
                
                // Received a tokenized Apple Pay payment from Braintree.
                self?.completion(tokenizedApplePayPayment.nonce, nil)
            })
        }
    }

    
}
