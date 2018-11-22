//
//  PoqProductSize.swift
//  PoqiOSNetworking
//
//  Created by Mahmut Canga on 19/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import ObjectMapper
import PoqModuling

/// Object containing a product's size
public final class PoqProductSize : Mappable, PoqTrackingProductSize {
    
    /// The id of the product size
    public final var id: Int?
    
    /// The size label text
    public final var size: String?
    
    /// The sku of the product size
    public final var sku: String?
    
    /// TODO what do we do with quantity in the product size ?
    public final var quantity: Int?
    
    /// The EAN of the product size
    public final var ean: String?
    
    /// The price of the product size
    public final var price: Double?
    
    /// The special price of the product size
    public final var specialPrice: Double?
    
    /// Used to style the price label via createSpecialPriceLabelText
    public final var isClearance: Bool?
    
    /// TODO: Not being used anywhere
    public final var isLowStock: Bool?
    
    // Used for Magento Enterprise
    public final var sizeAttributes: PoqProductSizeAttribute?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    /// Used to map the json data to the actual mapped object.
    ///
    /// - Parameter map: The object containing the response json data.
    public func mapping(map: Map) {
        
        id <- map["id"]
        size <- map["size"]
        sku <- map["sku"]
        quantity <- map["quantity"]
        ean <- map["ean"]
        price <- map["price"]
        specialPrice <- map["specialPrice"]
        sizeAttributes <- map["sizeAttributes"]
        isClearance <- map["isClearance"]
        isLowStock <- map["isLowOnStock"]
    }
    
}
