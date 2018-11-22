//
//  PoqBraintreePayPalPaymentSource.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 24/07/2016.
//
//

import Foundation
import ObjectMapper

// FIXME: in app we have few mesions of PaymentSource vs PoqPaymentMethod. We need some unification
open class PoqBraintreePayPalPaymentSource: Mappable {
    
    public static var presentationProvider: BraintreePayPalPresentationProvider = PlatformBraintreePayPalPresentationProvider()
    
    public var email: String?
    public var token: String?
    
    public init() {
    }

    public required init?(map: Map) {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        email <- map["email"]
        token <- map["token"]
    }
    
}

extension PoqBraintreePayPalPaymentSource: PoqPaymentSource {
    // Braintree doesn't need a customer id for now
    public var sourceCustomerId: String { return "" }
    
    public var paymentProvidaer: PoqPaymentProviderType { return .Braintree }
    
    public var paymentMethod: PoqPaymentMethod { return  .PayPal }
    
    public var paymentSourceToken: String { return token ?? "" }

    public var presentation: PoqPaymentSourcePresentation {
        return PoqBraintreePayPalPaymentSource.presentationProvider.presentation(for: self)
    }
}
