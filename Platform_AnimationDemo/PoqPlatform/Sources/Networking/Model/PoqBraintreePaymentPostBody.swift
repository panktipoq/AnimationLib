//
//  PoqBraintreePaymentPostBody.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 23/07/2016.
//
//

import Foundation
import ObjectMapper

open class PoqBraintreePaymentPostBody: Mappable {
    
    var paymentMethodNonce: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    open func mapping(map: Map) {

        paymentMethodNonce <- map["paymentMethodNonce"]
    }
    
}
