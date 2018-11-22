//
//  DecimalExtension.swift
//  PoqCart
//
//  Created by Balaji Reddy on 25/06/2018.
//

import Foundation
import PoqPlatform

extension Decimal {
    
    /// Get the currency string based on currency code and symbol provided by the CurrencyProvider helper class in PoqPlatform
    var currencyString: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.currencyCode = CurrencyProvider.shared.currency.code
        numberFormatter.currencySymbol = CurrencyProvider.shared.currency.symbol
        numberFormatter.numberStyle = .currency
        return numberFormatter.string(from: self as NSDecimalNumber)
    }
}
