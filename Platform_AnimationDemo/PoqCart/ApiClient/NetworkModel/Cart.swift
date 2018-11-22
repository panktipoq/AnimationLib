//
//  Cart.swift
//  PoqCart
//
//  Created by Balaji Reddy on 03/08/2018.
//

import Foundation
import PoqUtilities

/// This struct represents a users Cart
public struct Cart: Codable, CustomDataProvidable {
    
    /// A unique identifier for the user's Cart
    var cartId: String
    
    /// The items in a user's Cart
    var cartItems: [CartItem]
    
    /// The total price for the items in the user's Cart
    var total: Price
    
    /// Any custom data to be provided
    var customData: AnyCodable?
}
