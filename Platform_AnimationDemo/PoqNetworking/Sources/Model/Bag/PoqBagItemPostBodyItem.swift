//
//  PoqBagItemPostBodyItem.swift
//  Pods
//
//  Created by Erinç Erol on 10/02/2015.
//
//

import Foundation
import ObjectMapper

open class PoqBagItemPostBodyItem : Mappable {
    
    open var id: Int?
    open var productSizeID: Int?
    open var quantity: Int?
    open var cartId: String? // Native checkout - magento enterprise only
    open var sku: String?
    open var registryItemId: String?
    
    // Magento Enterprise
    open var sizeAttributeId: String?
    open var sizeOptionId: String?
    
    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    // Mappable
    open func mapping(map: Map) {
        
        id <- map["id"]
        productSizeID <- map["productSizeID"]
        quantity <- map["quantity"]
        sizeAttributeId <- map["sizeAttributeId"]
        sizeOptionId <- map["sizeOptionId"]
        cartId <- map["cartId"]
        sku <- map["sku"]
        registryItemId <- map["registryItemId"]
    }
}
