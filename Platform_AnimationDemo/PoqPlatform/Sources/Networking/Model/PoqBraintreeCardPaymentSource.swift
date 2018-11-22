//
//  PoqBraintreeCardPaymentSource.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 18/07/2016.
//
//

import Foundation
import ObjectMapper
import PoqNetworking

// FIXME: in app we have few mesions of PaymentSource vs PaymentMethod. We need some unification
open class PoqBraintreeCardPaymentSource: Mappable {
    
    public static var presentationProvider: BraintreeCardPresentationProvider = PlatformBraintreeCardPresentationProvider()

    public var billingAddress: PoqAddress?

    var cardType: String?
    var cardImageUrl: String?
    var cardholderName: String?
    var isDebit: Bool?
    
    var expirationMonth: String?
    var expirationYear: String?
    var isExpired: Bool?
    
    var last4: String?
    var token: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    open func mapping(map: Map) {
        
        billingAddress <- map["billingAddress"]
        cardType <- map["cardType"]
        cardholderName <- map["cardholderName"]
        isDebit <- map["isDebit"]
        
        expirationMonth <- map["expirationMonth"]
        expirationYear <- map["expirationYear"]
        
        isExpired <- map["isExpired"]
        
        last4 <- map["lastFour"]
        token <- map["token"]
        
        cardImageUrl <- map["imageUrl"]
    }
    
}

extension PoqBraintreeCardPaymentSource: PoqPaymentSource {
    // Braintree doesn't need a customer id for now
    public var sourceCustomerId: String { return "" }
    
    public var paymentProvidaer: PoqPaymentProviderType { return .Braintree }

    public var paymentMethod: PoqPaymentMethod { return  .Card }

    public var paymentSourceToken: String { return token ?? "" }
    
    public var presentation: PoqPaymentSourcePresentation {
        return PoqBraintreeCardPaymentSource.presentationProvider.presentation(for: self)
    }
}
