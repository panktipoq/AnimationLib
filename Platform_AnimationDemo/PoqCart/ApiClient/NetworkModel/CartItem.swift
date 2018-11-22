//
//  CartItem.swift
//  PoqCart
//
//  Created by Balaji Reddy on 03/08/2018.
//

import Foundation
import PoqUtilities

/// This struct represents a Cart item in the user's Cart
struct CartItem: Codable, CustomDataProvidable {
    
    /// The brand name of the product represented by the Cart item
    var brand: String?
    
    /// A unique identifier for the Cart item
    var id: String
    
    /// The price of one cart item
    var price: Price
    
    /// The "line-item" price of the cart item ( quantity x price )
    var total: Price
    
    /// A flag indicating that the item is in stock
    var isInStock: Bool
    
    /// A unique external client identifier for the product represented by the Cart item
    var clientProductId: String
    
    /// A unique internal platform identifier for the product represented by the Cart item
    var platformProductId: String
    
    /// The title of the product
    var title: String
    
    /// The thumbnail URL for the product image
    var thumbnailUrl: String
    
    /// The quantity of the product being purchased
    var quantity: Int
    
    /// A unique identifier for the specific Stock Keeping Unit
    var variantId: String
    
    /// The name of the particular variant represented by the product
    var variantName: String
    
    /// The color of the cart item
    var color: String?
    
    /// Any custom data the needs to be carried by this data model
    var customData: AnyCodable?
}
