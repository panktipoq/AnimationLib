//
//  CartDataState.swift
//  PoqCart
//
//  Created by Balaji Reddy on 30/07/2018.
//

import Foundation

/// This struct encapsulates the data state of the Cart screen
public struct CartDataState {
    
    var cart: CartDomainModel
    var error: Error?
    var editedCart: CartDomainModel?
}
