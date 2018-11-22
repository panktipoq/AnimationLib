//
//  PoqKlarnaPaymentSource.swift
//  PoqDemoApp
//
//  Created by Gabriel Sabiescu on 23/09/2018.
//

import UIKit
import ObjectMapper

class PoqStripeKlarnaPaymentSource {

    private var klarnaSourceCustomerId: String = ""
    private var klarnaSourceTokenId: String = ""
    
    public init(id: String, customerId: String) {
        klarnaSourceTokenId = id
        klarnaSourceCustomerId = customerId
    }
    
    init() {
        // Stub
    }
    
    public required init?(map: Map) {
        // Stub
    }
    
    func mapping(map: Map) {
        // Stub - for future implementation
    }
}

extension PoqStripeKlarnaPaymentSource: PoqPaymentSource {
    
    public var sourceCustomerId: String { return klarnaSourceCustomerId }
    public var paymentSourceToken: String { return klarnaSourceTokenId }
    public var paymentProvidaer: PoqPaymentProviderType { return .Stripe }
    public var paymentMethod: PoqPaymentMethod { return .Klarna }
    public var presentation: PoqPaymentSourcePresentation { return PoqPaymentSourcePresentation() }
}
