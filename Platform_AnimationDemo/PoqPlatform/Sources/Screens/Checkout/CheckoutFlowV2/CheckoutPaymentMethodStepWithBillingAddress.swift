//
//  CheckoutPaymentMethodStepWithBillingAddress.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/08/2016.
//
//

import Foundation
import PoqNetworking
import PoqUtilities

/**
 Checkout step which combine address and billing method.
 On selection will present list of payment options, so `super.stepDetailType` == .sourcesSelection
 Require `deliveryAddressStep` to populate some missed information in the end. Not all payment providers give you names and email
 */
open class CheckoutPaymentMethodStepWithBillingAddress<CFC: CheckoutFlowController>: CheckoutPaymentMethodStep<CFC> {
    
    public weak var deliveryAddressStep: AddressCheckoutStep?
    
    required public init(paymentsConfiguration: [PoqPaymentMethod: PoqPaymentProvider], deliveryAddressStep: AddressCheckoutStep) {
        super.init(paymentsConfiguration: paymentsConfiguration, stepDetailType: .sourcesSelection)
        assert(deliveryAddressStep.addressType == .Delivery)
        
        self.deliveryAddressStep = deliveryAddressStep
    }
    
    override open func populateCheckoutItem(_ checkoutItem: CheckoutItemType) {
        
        super.populateCheckoutItem(checkoutItem)
                
        var billingAddress = paymentSource?.billingAddress
        
        // Here is a known issue: PayPal do not provide billing address
        // Which means we need here set shipping as billing
        if paymentSource?.paymentMethod == .PayPal && billingAddress == nil {
            if let deliveryAddressStep = deliveryAddressStep {
                billingAddress = deliveryAddressStep.address
                
                // issue N2: magento wonna see email here
                // assume we have only one payment source class for paypal
                billingAddress?.email = (paymentSource as? PoqBraintreePayPalPaymentSource)?.email
                
            } else {
                Log.error("We got not address step for .Delivery in flowController")
            }
        } else if paymentSource?.paymentMethod == .Card {
            // Here second part: due to some old SDK we didn't save first/last names with card, so lets puplate them if they a missed
            if let deliveryAddressStep: AddressCheckoutStep = deliveryAddressStep {
                let deliveryAddress = deliveryAddressStep.address
                if billingAddress?.firstName == nil {
                    billingAddress?.firstName = deliveryAddress?.firstName
                }
                
                if billingAddress?.lastName == nil {
                    billingAddress?.lastName = deliveryAddress?.lastName
                }
            }
        }
        
        // To save backward compatibility with V6, we should try to set email if possible
        if billingAddress?.email == nil {
            billingAddress?.email = LoginHelper.getAccounDetails()?.email
        }
        
        if billingAddress == nil {
            Log.error("We didn't find address for \(String(describing: paymentSource?.paymentMethod.rawValue))")
        }
        
        checkoutItem.billingAddress = billingAddress
    }
}

extension CheckoutPaymentMethodStepWithBillingAddress: AddressCheckoutStep {
    
    public var addressType: AddressType { return .Billing }
    
    public var address: PoqAddress? {
        return paymentSource?.billingAddress
    }
}
