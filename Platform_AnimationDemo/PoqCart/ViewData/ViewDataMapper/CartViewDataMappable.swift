//
//  BagViewDataMappable.swift
//  PoqCart
//
//  Created by Balaji Reddy on 21/06/2018.
//

import Foundation

/**
    This interface represents a type that can map the network Bag data to the view data
 */
public protocol CartViewDataMappable {
    
    /// This method maps the Bag data fetched from the network to a view data representation of it
    ///
    /// - Parameter model: The Bag response from the network
    /// - Returns: A mapped view data reprsentation of the Bag network data
    func mapToViewData(_ model: CartDomainModel) -> CartViewDataRepresentable
}
