//
//  PoqStripeCardPaymentSource.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 17/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import ObjectMapper
import PoqNetworking

open class PoqStripeCardPaymentSource {

    public static var presentationProvider: StripePresentationProvider = PlatformStripePresentationProvider()
    open var type: PoqPaymentMethod?
    open var id: String?
    open var brand: String?
    open var last4: String?
    open var funding: String?
    
    open var customerId: String?
    
    // security checks
    open var cvc_check: String?
    open var zipCode_check: String?
    
    public var billingAddress: PoqAddress?

    public init() {
        // Do nothing
    }   
    
    public required init?(map: Map) {
        // Nothing to do
    }
    
    // Mappable
    open func mapping(map: Map) {
        id <- map["id"]
        brand <- map["brand"]
        last4 <- map["last4"]
        funding <- map["funding"]
        customerId <- map["customer"]
        
        cvc_check <- map["cvc_check"]
        zipCode_check <- map["address_zip_check"]
        
        var countryName: String? = nil
        countryName <- map["address_country"]
        if let existedCountryName = countryName, let country: Country = CountriesHelper.countryByLongName(existedCountryName) {
            billingAddress = PoqAddress()
            
            billingAddress?.country = country.name
            billingAddress?.countryId = country.isoCode
            
            var city: String?
            city <- map["address_city"]
            billingAddress?.city = city
            
            var address1: String?
            address1 <- map["address_line1"]
            billingAddress?.address1 = address1
            
            var address2: String?
            address2 <- map["address_line2"]
            billingAddress?.address2 = address2
            
            var postCode: String?
            postCode <- map["address_zip"]
            billingAddress?.postCode = postCode
            
            var county: String?
            county <- map["address_state"]
            billingAddress?.county = county
            
            var firstName: String?
            firstName <- map["metadata.first_name"]
            billingAddress?.firstName = firstName
            
            var lastName: String?
            lastName <- map["metadata.last_name"]
            billingAddress?.lastName = lastName
            
            var phone: String?
            phone <- map["metadata.phone"]
            billingAddress?.phone = phone
            
            var email: String?
            email <- map["metadata.email"]
            billingAddress?.email = email
        }
    }
}

// MARK: Convinient API

extension PoqStripeCardPaymentSource {

    // TODO: with swift 3 make it real private, not fileprivate
    fileprivate static let stripePassConst: String = "pass"
    
    /// Check that card passed cvc check
    /// If false - don't use and ignore it
    final var isCVCCheckPassed: Bool {
        return cvc_check == PoqStripeCardPaymentSource.stripePassConst
    }
    
    /// Check that card passed postal code check
    /// If false - don't use and ignore it
    final var isPostcodeCheckPassed: Bool {
        return zipCode_check == PoqStripeCardPaymentSource.stripePassConst
    }
}

extension PoqStripeCardPaymentSource: PoqPaymentSource {
    
    public var sourceCustomerId: String { return customerId ?? "" }
    public var paymentProvidaer: PoqPaymentProviderType { return .Stripe }
    public var paymentMethod: PoqPaymentMethod { return type ?? .Card }
    public var paymentSourceToken: String { return id ?? "" }
    
    public var presentation: PoqPaymentSourcePresentation {
        return PoqStripeCardPaymentSource.presentationProvider.presentation(for: self)
    }
}
