//
//  StartCartTransferResponseOrder.swift
//  Poq.iOS.Platform.SimplyBe
//
//  Created by Nikolay Dzhulay on 2/21/17.
//
//

import Foundation
import ObjectMapper

public class StartCartTransferResponseOrder: Mappable {

    public final var orderId: Int?
    public final var items: [StartCartTransferResponseOrderItem]?
    public final var subtotal: Double? 
    
    // MARK: Mappable
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    public func mapping(map: Map) {
        
        orderId <- map["orderId"]
        items <- map["items"]
        subtotal <- map["subtotal"]
    }
}

public class StartCartTransferResponseOrderItem: Mappable {

    public final var productId: Int?
    public final var productTitle: String?
    public final var sku: String?
    public final var price: Double?
    public final var specialPrice: Double?
    public final var quantity: Int?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    public func mapping(map: Map) {

        productId <- map["productId"]
        productTitle <- map["productTitle"]
        sku <- map["sku"]
        price <- map["price"]
        specialPrice <- map["specialPrice"]
        quantity <- map["quantity"]
    }
}
