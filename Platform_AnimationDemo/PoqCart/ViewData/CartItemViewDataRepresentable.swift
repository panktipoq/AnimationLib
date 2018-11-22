//
//  BagItemViewDataRepresentable.swift
//  PoqCart
//
//  Created by Balaji Reddy on 21/06/2018.
//

import Foundation

/**
    This interface represents the minimum view data required to present a Bag Item
 */
public protocol CartItemViewDataRepresentable {
    
    var id: String { get set }
    var productTitle: String { get set }
    var brandName: String? { get set }
    var quantity: Int { get set }
    var nowPrice: String { get set }
    var wasPrice: String? { get set }
    var total: String { get set }
    var productImageUrl: String? { get set }
    var color: String? { get set }
    var size: String? { get set }
    var isInStock: Bool { get set }
}
