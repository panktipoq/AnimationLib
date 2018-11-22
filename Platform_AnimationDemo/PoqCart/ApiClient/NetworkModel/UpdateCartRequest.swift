//
//  UpdateCartRequest.swift
//  PoqCart
//
//  Created by Balaji Reddy on 03/08/2018.
//

import Foundation
import PoqUtilities

/// This struct encapsulates a Cart POST Body
public struct UpdateCartRequest: Codable, CustomDataProvidable {
    
    /// This struct represents a Cart item in the Cart POST Body
    struct CartItem: Codable, CustomDataProvidable {
        var cartItemId: String
        var quantity: Int
        var deleted: Bool?
        var customData: AnyCodable?
    }
    
    /// The items in the Cart that are being updated
    var items: [CartItem]
    
    /// Any custom data to be carried by this object
    var customData: AnyCodable?
}
