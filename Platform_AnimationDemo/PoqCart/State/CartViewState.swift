//
//  CartViewState.swift
//  PoqCart
//
//  Created by Balaji Reddy on 01/07/2018.
//

import Foundation

public struct CartViewState {
    
    var screenState: ScreenState
    var inEditMode: Bool
    var isCheckoutEnabled: Bool
    var userLoggedIn: Bool
    var checkoutType: CartType
}
