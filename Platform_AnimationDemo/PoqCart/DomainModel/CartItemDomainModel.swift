//
//  CartItemDomainModel.swift
//  PoqCart
//
//  Created by Balaji Reddy on 02/10/2018.
//

import Foundation
import PoqUtilities

/// This struct is the domain model representation of a Cart item
public struct CartItemDomainModel: Codable {
    
    /// A unique identifier for the cart item
    public var id: String
    
    /// The brand of the product
    public var brand: String?
    
    /// The title of the product
    public var productTitle: String
    
    /// The formatted sale price string
    public var priceFormatted: String
    
    /// The raw decimal representation of the sale price
    public var price: Decimal
    
    /// The formatted representation of the price before discount
    public var wasPriceFormatted: String?
    
    /// The raw decimal representation of the price before discount
    public var wasPrice: Decimal?
    
    /// The internal poq platform identifier for the product
    public var productId: String
    
    /// The external client identifier for the product
    public var externalProductId: String
    
    /// The url string for the product thumbnail image
    public var thumbnailUrl: String
    
    /// The color of the product
    public var color: String?
    
    /// The size of the product
    public var size: String
    
    /// A unique stock keeping unit or variant ID
    public var sku: String
    
    /// The quantity of the item added to the cart
    public var quantity: Int
    
    /// The formatted total price string for the chosen quantity of the item
    public var totalPriceFormatted: String
    
    /// The raw decimal representation for the total price of the chosen quantity of the item
    public var totalPrice: Decimal
    
    /// A boolean representing whether the item is in stock
    public var isInStock: Bool
    
    /// Any custom data to be conveyed
    public var customData: AnyCodable?
}
