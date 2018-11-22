//
//  AddToCartBody.swift
//  PoqNetworking
//
//  Created by Balaji Reddy on 20/08/2018.
//

import Foundation


public struct AddToCartBody: Encodable {
    
    public init(variantId: String, variantName: String, productId: String, quantity: Int) {
        self.variantId = variantId
        self.variantName = variantName
        self.productId = productId
        self.quantity = quantity
    }
    
    var variantId: String
    var variantName: String
    var productId: String
    var quantity: Int
}
