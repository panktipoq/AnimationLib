//
//  StripeCardValidator.swift
//  Poq.iOS
//
//  Created by Gabriel Sabiescu on 07/07/2016.
//
//

import Bolts
import PoqNetworking
import UIKit

/**
 #PLA-850 
 Ideally this functionality needed temporaly.
 Here is a full story:
    Initially MSG didn't have froud protection by postal code.
    For a some time after first launch we/MSG decided to add this protection.
    To improve UX and don't kick cards which doesn't have 'post code checked' mark, on first run after update we run this validator to silently validate card with provided billing address.
    Looks like after couple update this functionality become usless
 */

// TODO: add analytics to this validator and, probably, delete it, when this events diappears after few updates

public class StripeCardValidator: NSObject {

    var customerId: String?
    var paymentSources: [PoqStripeCardPaymentSource] = []
    var billingAddress: PoqAddress?

    func checkUserCards() {
    
        guard let validCustomerId = customerId else {
            return
        }
    
        PoqNetworkService(networkTaskDelegate: self).fetchStripeCustomerPaymentSources( forCustomerId: validCustomerId )
    }
}

extension StripeCardValidator: PoqNetworkTaskDelegate {
    
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
    }
    
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {

        if networkTaskType == PoqNetworkTaskType.stripeGetCards {
            guard let stripeCardsResponse = result?.first as? StripeCardsResponse,
                let validPaymentSources: [PoqStripeCardPaymentSource]  = stripeCardsResponse.paymentSources else {
                return
            }
            paymentSources += validPaymentSources
            
            if (paymentSources.count > 0) {
                
                guard let validBillingAddress = billingAddress, let validCustomerId = customerId, let paymentSource = paymentSources.last, let paymentSourceId: String = paymentSource.id, let postCode = validBillingAddress.postCode else {
                    return
                }
                let postBody = PoqStripeZipCodeBody()
                postBody.addressZip = postCode
                PoqNetworkService(networkTaskDelegate: self).checkPaymentSource(paymentSourceId, toCustomer: validCustomerId, zipCode: postBody)
            }
        }
    }
    
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        if networkTaskType == PoqNetworkTaskType.stripeCheckCardToken {
            guard let validCustomerId: String = customerId else {
                return
            }

            if paymentSources.count > 0 {
                guard let firstObject: PoqStripeCardPaymentSource = paymentSources.last, let validPaymentSourceId = firstObject.id else {
                    return
                }

                PoqNetworkService(networkTaskDelegate: self).removePaymentSourceCustomer(validPaymentSourceId, fromCusomer: validCustomerId )
            }
        } else if networkTaskType == PoqNetworkTaskType.stripeDeleteCardToken {
            
            guard let firstObject: PoqStripeCardPaymentSource = paymentSources.last, let _ = firstObject.id else {
                return
            }
            paymentSources.removeLast()
            
        }
    }
}
