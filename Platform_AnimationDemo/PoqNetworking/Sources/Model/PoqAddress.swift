//
//  PoqAddress.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 15/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqAddress : Mappable, NSCopying, Equatable {
    
    public var id: Int?
    public var externalAddressId: String?
    public var addressName: String?
    public var city: String?
    public var country: String?
    public var countryId: String?
    public var firstName: String?
    public var lastName: String?
    public var postCode: String?
    
    public var address1: String?
    public var address2: String?

    public var phone: String?
    
    public var poqUserId: String?
    
    public var isDefaultBilling: Bool?
    public var isDefaultShipping: Bool?
    
    public var save: Bool?
    
    public var message: String?
    public var statusCode: Int?
    
    public var email: String?
    public var company: String?
    public var county: String?
    public var state: String?
    
    public var isApplePay: Bool = false
    
    public var collectDate: String?
    public var metaPackRequestId: String?
    public var metaPackBookingCode: String?
    public var metaPackCarrierServiceCode: String?
    public var orderId: Int?
    
    public init() {
    }
    
    public required init?(map: Map) {
    }

    
    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        externalAddressId <- map["externalAddressId"]
        addressName <- map["addressName"]
        city <- map["city"]
        country <- map["country"]
        countryId <- map["countryId"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        postCode <- map["postCode"]
        
        address1 <- map["address1"]
        address2 <- map["address2"]
        phone <- map["phone"]
        
        poqUserId <- map["poqUserId"]
        
        isDefaultBilling <- map["isDefaultBilling"]
        isDefaultShipping <- map["isDefaultShipping"]
        
        save <- map["save"]
        
        message <- map["message"]
        statusCode <- map["statusCode"]
        
        email <- map["email"]
        company <- map["company"]
        county <- map["county"]
        state <- map["state"]
        
        isApplePay <- map["isApplePay"] 
        
        collectDate <- map["collectDate"]
        metaPackRequestId <- map["metaPackRequestId"]
        metaPackBookingCode <- map["metaPackBookingCode"]
        metaPackCarrierServiceCode <- map["metaPackCarrierServiceCode"]
        orderId <- map["orderId"]
    }
    
    open func copyProperties( from address: PoqAddress ) {
        
        id = address.id
        externalAddressId = address.externalAddressId
        addressName = address.addressName
        city = address.city
        country = address.country
        countryId = address.countryId
        firstName = address.firstName
        lastName = address.lastName
        postCode = address.postCode
        address1 = address.address1
        address2 = address.address2
        phone = address.phone
        poqUserId = address.poqUserId
        isDefaultBilling = address.isDefaultBilling
        isDefaultShipping = address.isDefaultShipping
        save = address.save
        message = address.message
        statusCode = address.statusCode
        email = address.email
        company = address.company
        county = address.county
        state = address.state
        isApplePay = address.isApplePay
    }
    
    @objc open func copy(with zone: NSZone?) -> Any {
        
        let newAddress = PoqAddress()
        newAddress.copyProperties(from: self)
        return newAddress
    }
    
    public static func ==(lhs: PoqAddress, rhs: PoqAddress) -> Bool {
        
        if lhs.id != rhs.id {
            return false
        }
        
        if lhs.externalAddressId != rhs.externalAddressId {
            return false
        }
        
        if lhs.addressName != rhs.addressName {
            return false
        }
        
        if lhs.city != rhs.city {
            return false
        }
        
        if lhs.country != rhs.country {
            return false
        }
        
        if lhs.countryId != rhs.countryId {
            return false
        }
        
        if lhs.firstName != rhs.firstName {
            return false
        }
        
        if lhs.lastName != rhs.lastName {
            return false
        }
        
        if lhs.postCode != rhs.postCode {
            return false
        }
        
        if lhs.address1 != rhs.address1 {
            return false
        }
        
        if lhs.address2 != rhs.address2 {
            return false
        }
        
        if lhs.phone != rhs.phone {
            return false
        }
        
        if lhs.poqUserId != rhs.poqUserId {
            return false
        }
        
        if lhs.isDefaultBilling != rhs.isDefaultBilling {
            return false
        }
        
        if lhs.isDefaultShipping != rhs.isDefaultShipping {
            return false
        }
        
        if lhs.save != rhs.save {
            return false
        }
        
        if lhs.message != rhs.message {
            return false
        }
        
        if lhs.statusCode != rhs.statusCode {
            return false
        }
        
        if lhs.email != rhs.email {
            return false
        }
        
        if lhs.company != rhs.company {
            return false
        }
        
        if lhs.county != rhs.county {
            return false
        }
        
        if lhs.state != rhs.state {
            return false
        }
        
        if lhs.isApplePay != rhs.isApplePay {
            return false
        }
        
        return true
    }
}
