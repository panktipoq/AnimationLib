//
//  PoqStripeCustomerBody.swift
//  PoqDemoApp
//
//  Created by Gabriel Sabiescu on 17/03/2018.
//

import UIKit
import ObjectMapper

public class PoqStripeCustomerBody: Mappable {
    public var email: String?
    public var token: String?
    public var fullName: String?
    public var dob: String?
    public var customerNo: String?
    public var loyaltyCardNumber: String?
    
    public init() {
        // Stub
    }
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        
        email <- map["email"]
        token <- map["token"]
        fullName <- map["fullName"]
        dob <- map["dob"]
        customerNo <- map["customerNo"]
        loyaltyCardNumber <- map["loyaltyCardNumber"]
    }
}
