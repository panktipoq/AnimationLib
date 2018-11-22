//
//  CartState.swift
//  PoqCart
//
//  Created by Balaji Reddy on 02/05/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import Foundation
import ReSwift

/**
 
  This struct represents the state of the Bag screen
 */
public struct CartState: StateType {
    
    /// An object representing the view state of the Bag screen
    public var viewState: CartViewState
    
    /// An object representing the data state of the Bag screen
    public var dataState: CartDataState
}
