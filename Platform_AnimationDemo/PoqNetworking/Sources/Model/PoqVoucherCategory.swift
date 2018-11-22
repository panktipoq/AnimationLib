//
//  PoqVoucherCategory.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 12/29/16.
//
//

import Foundation
import ObjectMapper

open class PoqVoucherCategory: Mappable {
    
    open var id: Int?
    open var title: String?
    open var voucherCount: Int?
    open var sortIndex: Int?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    open func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        voucherCount <- map["voucherCount"]
        sortIndex <- map["sortIndex"]
    }
    
}
