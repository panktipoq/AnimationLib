//
//  BagViewDataRepresentable.swift
//  PoqCart
//
//  Created by Balaji Reddy on 21/06/2018.
//

import Foundation
/**
  This interface represents the view data required to present the Bag screen
 */
public protocol CartViewDataRepresentable {
    
    /// The array of content blocks that are presented on the scrollable view on the Bag screen.
    var contentBlocks: [CartContentBlocks] { get set }
    
    var numberOfCartItems: Int { get set }
    var total: String { get set }
}
