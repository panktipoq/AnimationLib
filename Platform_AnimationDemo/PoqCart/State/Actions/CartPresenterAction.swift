//
//  PresenterAction.swift
//  PoqCart
//
//  Created by Balaji Reddy on 02/05/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import Foundation
import ReSwift

/**
    An enum type representing all the Actions that the platform implementation of the CartViewController, ViewStateReducer and DataStateReducer can handle.
 */
public enum CartPresenterAction: Action {
    case showLoadingIndicator
    case toggleEditMode
    case deleteCartItem(id: String)
    case updateQuantity(id: String, quantity: Int)
    case tapOnCartItem(productId: String, externalProductId: String?)
    case goToCheckout
    case goToBackground
    case setLoginStatus(userLoggedIn: Bool)
    case setCheckoutType(checkoutType: CartType)
    case cancelEdit
    case goToShop
}
