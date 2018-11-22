//
//  PoqBraintreeToken.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 18/07/2016.
//
//

import Foundation
import ObjectMapper

open class PoqBraintreeToken: Mappable {
    
    var token: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
   
    // Mappable
    open func mapping(map: Map) {
        token <- map["braintreeClientToken"]
    }
    
}


