//
//  Price.swift
//  PoqCart
//
//  Created by Balaji Reddy on 20/09/2018.
//

import Foundation

/// This struct a representation of price
public struct Price: Codable {
    
    /// This is the current price
    var now: Decimal
    
    /// This is the formatted current price string
    var nowFormatted: String
    
    /// This is the price before discount/modification when applicable
    var was: Decimal?
    
    /// This is the formatted price before discount/modification when applicable
    var wasFormatted: String?
    
    /// This is the currency symbol for the price
    var currencySymbol: String
    
    /// This is the currency code for the price
    var currencyCode: String
}
