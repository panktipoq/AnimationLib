//
//  PoqStudentNumber.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 1/21/16.
//  Copyright © 2016 Poq. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqStudentNumber: Mappable {
    open var cardNumber: String?
    open var orderId: Int?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    open func mapping(map: Map) {
        
        cardNumber <- map["cardNumber"]
        orderId <- map["orderId"]
    }

}
