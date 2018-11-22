//
//  PoqVoucher.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 15/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import ObjectMapper

public protocol PoqVoucherProtocol {
    var id: String? {get set}
    var voucherCode: String? {get set}
    var value: Double? {get set}
}

open class PoqVoucher : Mappable, PoqVoucherProtocol {
    
    open var id: String?
    open var voucherCode: String?
    open var value: Double?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        voucherCode <- map["voucherCode"]
        value <- map["value"]
    }
}
