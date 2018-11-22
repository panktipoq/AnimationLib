//
//  PoqStripeCustomer.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 17/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation

import ObjectMapper

open class PoqStripeCustomer: Mappable {
    
    open var id: String?
    
    open var sources: [PoqPaymentSource]?
    
    // MARK: Mappable
    public required init?(map: Map) {
    }
    
    public init() {
    }

    open func mapping(map: Map) {
        
        id <- map["id"]
        sources <- (map["sources.data"], PaymentSourceTransform())
    }
}

extension PoqStripeCustomer: PoqPaymentCustomer {
    final public var identifier: String { return id ?? "" }

    final public func paymentSources(forMethod method: PoqPaymentMethod) -> [PoqPaymentSource] {
        
        switch method {
            
        case .Card: return sources?.filter({$0.paymentMethod == PoqPaymentMethod.Card}).map({ $0 as PoqPaymentSource }) ?? []
            
        case .PayPal: return []
            
        case .Klarna: return sources?.filter({ $0.paymentMethod == PoqPaymentMethod.Klarna }).map({ $0 as PoqPaymentSource }) ?? []
            
        case .ApplePay: return []
        }
    }
}
