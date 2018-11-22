//
//  BagViewData.swift
//  PoqCart
//
//  Created by Balaji Reddy on 21/06/2018.
//

import Foundation

/**
  The concrete platform implementation of the BagViewDataRepresentable protocol
 */
public struct CartViewData: CartViewDataRepresentable, Equatable {
    
    public var contentBlocks: [CartContentBlocks]
    public var numberOfCartItems: Int
    public var total: String
}
