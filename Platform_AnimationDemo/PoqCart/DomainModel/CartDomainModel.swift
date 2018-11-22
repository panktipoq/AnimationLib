//
//  CartDomainModel.swift
//  PoqCart
//
//  Created by Balaji Reddy on 02/10/2018.
//

import Foundation
import PoqUtilities

/// This struct is the domain model representation of a Cart
public struct CartDomainModel {
    
    /// A unique identifier for the cart
    public var cartId: String
    
    /// The items contained in the cart
    public var cartItems: [CartItemDomainModel]
    
    /// The formatted total price string
    public var totalPriceFormatted: String
    
    /// The raw decimal representation of the total price of the cart
    public var totalPrice: Decimal
    
    /// The total number of items in the cart
    public var numberOfItems: Int {
        
        return cartItems.reduce(0, { $0 + $1.quantity })
    }
    
    /// Any custom data that is to presented
    public var customData: AnyCodable?
}
