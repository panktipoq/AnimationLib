//
//  PoqTrackingOrderItem.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 6/5/17.
//
//

import Foundation

open class PoqTrackingOrderItem {
    
    // The transaction ID with which the item should be associated
    public var transactionId: String = ""
    
    // The product id
    public var id: String = ""
    
    // The name of the product
    public var name: String = ""
    
    // The SKU of a product
    public var sku: String = ""
    
    // A category to which the product belongs
    public var category: String = ""
    
    // The price of a product
    public var price: Double = 0
    
    // The quantity of a product
    public var quantity: Int = 0
    
    // The local currency of a transaction. Defaults to the currency of the view (profile) in which the transactions are being viewed.
    public var currencyCode: String?
    
    public init() {
        
    }
}
