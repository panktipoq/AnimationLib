//
//  PaymentProviderMock.swift
//  PoqDemoApp
//
//  Created by Nikolay Dzhulay on 10/17/17.
//

import Foundation
import PassKit
import ObjectMapper

@testable import PoqNetworking
@testable import PoqPlatform

class PaymentSourceMock: PoqPaymentSource {
    var sourceCustomerId: String = ""
    
    required init() {
        // Stub
    }
    
    required init?(map: Map) {
        // Stub
    }
    
    func mapping(map: Map) {
        // Stub
    }

    var paymentProvidaer: PoqPaymentProviderType { 
        return .Braintree
    }

    var presentation: PoqPaymentSourcePresentation {
        var singleLine = "VISA **** 1111"
        
        if let postCode = billingAddress?.postCode, postCode.count > 0 {
            singleLine += " | \(postCode.capitalized)"
        }
        
        return PoqPaymentSourcePresentation(twoLinePresentation: (singleLine, nil), oneLinePresentation: singleLine, paymentMethodIconUrl: nil, cardIcon: nil)
    }
    
    var paymentMethod: PoqPaymentMethod {
        return .Card
    }

    var paymentSourceToken: String {
        return "Test_token"
    }
    
    var billingAddress: PoqAddress? {
        let address = PoqAddress()

        address.city = "London"
        address.country = "United Kingdom"
        address.countryId = "GB"
        address.firstName = "TestF"
        address.lastName = "TestL"
        address.postCode = "EC2A 3EQ"
        
        address.address1 = "POQ"
        address.address2 = "21 Garden Walk"
        
        return address
    }
}

class PaymentCustomerMock: PoqPaymentCustomer {
    
    let identifier: String = "123-IdentifyMe"
    
    func paymentSources(forMethod method: PoqPaymentMethod) -> [PoqPaymentSource] {
        return [PaymentSourceMock()]
    }
}

class PaymentProviderMock: PoqPaymentProvider {
    
    var paymentProviderType: PoqPaymentProviderType { 
        return .Braintree
    }

    var customer: PoqPaymentCustomer?

    var preferredPaymentSource: PoqPaymentSource? {
        get {
            return customer?.paymentSources(forMethod: .Card).first
        }
        set {
        }
    }

    func createApplePayToken(forPayment payment: PKPayment, completion: @escaping (_ token: String?, _ error: NSError?) -> Void) {
    }

    func createCardCreationUIProvider() -> PoqPaymentCardCreationUIProvider? {
        return StripeCartCreationUIProvider()
    }

    func createPaymentSource(_ paymentSourceParameters: PoqPaymentSourceParameters, completion: @escaping (_ error: NSError?) -> Void) {
        
        customer = PaymentCustomerMock()
        DispatchQueue.main.async {
            completion(nil)
        }
    }

    func deletePaymentSource(_ paymentSource: PoqPaymentSource, completion: @escaping (_ error: NSError?) -> Void) {
    }
}
