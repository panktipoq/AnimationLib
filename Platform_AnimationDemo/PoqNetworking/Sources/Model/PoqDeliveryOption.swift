//
//  PoqDeliveryOption.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 15/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqDeliveryOption : Mappable {
    
    open var id: Int?
    open var code: String?
    open var title: String?
    open var orderId:Int?
    open var price:Double?
    open var message:String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        code <- map["optionCode"]
        title <- map["title"]
        orderId <- map["orderId"]
        price <- map["price"]
        message <- map["message"]
    }
}
