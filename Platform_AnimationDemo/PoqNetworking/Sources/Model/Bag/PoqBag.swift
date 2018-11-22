//
//  PoqBag.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 11/01/2017.
//
//

import Foundation
import ObjectMapper

open class PoqBag: Mappable {
    
    open var id: Int?
    open var globalNotificationMessages: [String]?
    open var itemCount: Int?
    open var total: Double?
    open var bagItems: [PoqBagItem]?
    open var vouchers: [PoqVoucherV2]?
    open var merchandiseTotal: Double?
    open var totalVoucherSavings: Double?
    open var shippingSurcharge: Double?
    open var estimatedShipping: Double?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
   
    // Mappable
    open func mapping(map: Map) {
        id <- map["id"]
        globalNotificationMessages <- map["globalNotificationMessages"]
        itemCount <- map["itemCount"]
        total <- map["total"]
        bagItems <- map["bagItems"]
        vouchers <- map["vouchers"]
        merchandiseTotal <- map["merchandiseTotal"]
        totalVoucherSavings <- map["totalVoucherSavings"]
        shippingSurcharge <- map["shippingSurcharge"]
        estimatedShipping <- map["estimatedShipping"]
    }
}
