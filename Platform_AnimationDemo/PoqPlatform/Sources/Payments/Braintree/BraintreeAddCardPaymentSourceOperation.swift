//
//  BraintreeAddCardPaymentSourceOperation.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 22/07/2016.
//
//

import Braintree
import Foundation
import PoqNetworking
import PoqUtilities

final class BraintreeAddCardPaymentSourceOperation: BraintreeCustomerOperation {
    
    let card: BTCard
   
    
    init(card: BTCard, completion: @escaping (_ error: NSError?) -> Void) {
        self.card = card

        super.init(completion: completion)
    }
    
    // TODO: add unit test on all possible scenarios - make sure completion always called
    override final func execute() {
        
        guard let braintreeClient = BraintreeHelper.sharedInstance.braintreeClient else {
            let error: NSError = BraintreeCustomerOperation.createError(withMessage: nil)
            completion(error)
            finish()
            return
        }
        
        let cardClient = BTCardClient(apiClient: braintreeClient)
        
        
        cardClient.tokenizeCard(card) {
            [weak self]
            (nonce: BTCardNonce?, error: Error?) in
            
            DispatchQueue.main.async(execute: {
                [weak self] in
                guard let strongSelf = self else {
                    Log.error("How operation deallocated before response arrived??")
                    return
                }
                
                guard let validNonce: BTCardNonce = nonce else {
                    Log.error("\(String(describing: error?.localizedDescription))")
                    
                    let message: String? = (error as NSError?)?.userInfo[NSLocalizedFailureReasonErrorKey] as? String
                    let resError: NSError = BraintreeCustomerOperation.createError(withMessage: message)
                    strongSelf.completion(resError)
                    strongSelf.finish()
                    return
                }
                
                PoqNetworkService(networkTaskDelegate: strongSelf).addBraintreePaymentMethod(BraintreeHelper.sharedInstance.customerId, nonce: validNonce.nonce)
            })
           
        }
        
    }

    
    override final func updateCustomer(withResounse customer: PoqBraintreeCustomer) {
        BraintreeHelper.sharedInstance.updateBraintreeCustomer(customer)
        BraintreeHelper.sharedInstance.preferredPaymentSource = customer.paymentMethods?.first ?? BraintreeHelper.sharedInstance.preferredPaymentSource
    }
}


