//
//  PoqBraintreeCustomer.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 18/07/2016.
//
//

import Foundation
import ObjectMapper

open class PoqBraintreeCustomer: Mappable {
    
    var customerId: String?
    
    var paymentMethods: [PoqBraintreeCardPaymentSource]?
    
    /// assume we always has only 1 account
    var payPalAccounts: [PoqBraintreePayPalPaymentSource]?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        customerId <- map["customer.customerId"]
        paymentMethods <- map["customer.paymentMethods"]
        payPalAccounts <- map["customer.paypalAccounts"]
    }
}

// MARK: PoqPaymentCustomer
extension PoqBraintreeCustomer: PoqPaymentCustomer {
    
    public var identifier: String { return  customerId ?? "" }

    public func paymentSources(forMethod method: PoqPaymentMethod) -> [PoqPaymentSource] {

        switch method {
        case .Card: return paymentMethods?.map({ $0 as PoqPaymentSource }) ?? []
            
        case .PayPal: return payPalAccounts?.map({ $0 as PoqPaymentSource }) ?? []
            
        case .Klarna: return []
            
        case .ApplePay: return []
        }
    }
    
}
