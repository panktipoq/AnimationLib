//
//  CartError.swift
//  PoqCart
//
//  Created by Balaji Reddy on 21/09/2018.
//

import Foundation
import PoqPlatform

public enum CartError: Error {
    case outOfStockItemInCart
    case unspecified
}

extension CartError: LocalizedError {
    
    public var errorDescription: String? {
        
        switch self {
        case .outOfStockItemInCart:
            
            return "OUT_OF_STOCK_ITEM_IN_CART".localizedPoqString
            
        default:
            return "SOMETHING_WENT_WRONG".localizedPoqString
        }
    }

}
