//
//  PoqVouchersDashboard.swift
//  Poq.iOS.Belk
//
//  Created by Robert Dimitrov on 12/30/16.
//
//

import Foundation
import ObjectMapper

open class PoqVouchersDashboard: Mappable {
    
    open var featuredVouchers: [PoqVoucherV2] = []
    open var voucherCategories: [PoqVoucherCategory] = []

    // MARK: Mappable
    public required init?(map: Map) {
    }
    
    public init() {
    }

    open func mapping(map: Map) {
        featuredVouchers <- map["featuredVouchers"]
        voucherCategories <- map["voucherCategories"]
    }
    
}
