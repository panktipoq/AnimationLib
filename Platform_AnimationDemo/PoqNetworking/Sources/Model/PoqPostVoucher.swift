//
//  PoqPostVoucher.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 24/08/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import ObjectMapper

open class PoqPostVoucher : Mappable {
    
    open var code:String?
    open var orderId:Int?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        code <- map["code"]
        orderId <- map["orderId"]
    }
}
