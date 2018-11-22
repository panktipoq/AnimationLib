//
//  PoqParsedOrder.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 16/09/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import ObjectMapper

/**
Used to convert order delivery and total cost values
from the checkout page
These values are coming from the labels inside HTML page.
So they could have non-numeric values attached to each.
For this reason, we transfer all the values as String
and then use Regex to parse inside the app.
*/
open class PoqParsedOrder: Mappable {
    
    open var subTotal: String?
    open var delivery: String?
    open var discount: String?
    open var total: String?
    open var currency: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        subTotal <- map["subTotal"]
        delivery <- map["delivery"]
        discount <- map["discount"]
        total <- map["total"]
        currency <- map["currency"]
    }
}
