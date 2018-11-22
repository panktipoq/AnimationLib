//
//  BagItemViewData.swift
//  PoqCart
//
//  Created by Balaji Reddy on 21/06/2018.
//

import Foundation

/**
 
 The concrete platform implementation of the BagItemViewDataRepresentable protocol
 */
public struct CartItemViewData: CartItemViewDataRepresentable {
    
    public var id: String
    public var productTitle: String
    public var brandName: String?
    public var quantity: Int
    public var nowPrice: String
    public var wasPrice: String?
    public var total: String
    public var productImageUrl: String?
    public var color: String?
    public var size: String?
    public var isInStock: Bool
    
    init(
        id: String,
        productTitle: String,
        quantity: Int,
        nowPrice: String,
        total: String,
        isInStock: Bool) {
        
        self.id = id
        self.productTitle = productTitle
        self.quantity = quantity
        self.nowPrice = nowPrice
        self.total = total
        self.isInStock = isInStock
    }
}
