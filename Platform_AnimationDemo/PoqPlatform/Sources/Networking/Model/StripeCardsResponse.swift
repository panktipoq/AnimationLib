//
//  StripeCardsResponse.swift
//  Poq.iOS.Belk
//
//  Created by Nikolay Dzhulay on 11/17/16.
//
//

import Foundation
import ObjectMapper

open class StripeCardsResponse: Mappable {
    
    open var paymentSources: [PoqStripeCardPaymentSource]?
    
    // MARK: Mappable
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    open func mapping(map: Map) {
        paymentSources <- map["data"]
    }
}
