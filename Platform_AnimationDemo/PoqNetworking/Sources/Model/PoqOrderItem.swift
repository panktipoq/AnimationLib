//
//  PoqOrderItem.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper


public protocol OrderItem: Mappable {
    var id: Int? { get }
    var productID: Int? { get }
    var size: String? { get }
    var sku: String? { get }
    var EANCode: String? { get }
    var price: Double? { get }
    var vatAmount: Double? { get }
    var quantity: Int? { get }
    var note: String? { get }
    var productTitle: String? { get }
    var productSizeID: Int? { get }
    var externalID: String? { get }
    var productImageUrl: String? { get }
    var brand: String? { get }
    var color: String? { get }
    var priceString: String? { get }
}

public struct PoqOrderItem: OrderItem {
    
    public var id: Int?
    public var productID: Int?
    public var size: String?
    public var sku: String?
    public var EANCode: String?
    public var price: Double?
    public var vatAmount: Double?
    public var quantity: Int?
    public var note: String?
    public var productTitle: String?
    public var productSizeID: Int?
    public var externalID: String?
    public var productImageUrl: String?
    public var brand: String?
    public var color: String?
    public var priceString: String?
    
    public init?(map: Map) {
    }
    
    public init() {
    }

    // Mappable
    public mutating func mapping(map: Map) {
        
        id <- map["id"]
        productID <- map["productID"]
        size <- map["size"]
        sku <- map["sku"]
        EANCode <- map["EANCode"]
        price <- map["price"]
        vatAmount <- map["vatAmount"]
        quantity <- map["quantity"]
        note <- map["note"]
        brand <- map["brand"]
        productTitle <- map["productTitle"]
        productSizeID <- map["productSizeID"]
        externalID <- map["externalID"]
        productImageUrl <- map["productImageUrl"]
        color <- map["color"]
        priceString <- map["priceString"]
    }

}
