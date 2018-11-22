//
//  PoqPostAddress.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 20/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqPostAddress : Mappable {
    
    open var billingAddress:PoqAddress?
    open var shippingAddress: PoqAddress?
    open var useBillingAsShipping: Bool?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        billingAddress <- map["billingAddress"]
        shippingAddress <- map["shippingAddress"]
        useBillingAsShipping <- map["useBillingAsShipping"]
    }
}
