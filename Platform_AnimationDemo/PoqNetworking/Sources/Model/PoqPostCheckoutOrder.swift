//
//  PoqPostCheckoutOrder.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 20/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqPostCheckoutOrder<CheckoutItemType: CheckoutItem> : Mappable {
    
    open var code: String?
    open var title: String?
    open var orderId: Int?
    open var postName: String?
    
    open var checkoutItem: CheckoutItemType?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        code <- map["code"]
        title <- map["title"]
        orderId <- map["orderId"]
        postName <- map["postName"]
        
        checkoutItem <- map["checkoutItem"]
    }
}
