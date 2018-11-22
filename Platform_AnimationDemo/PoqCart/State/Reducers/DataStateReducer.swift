//
//  DataStateReducer.swift
//  PoqCart
//
//  Created by Balaji Reddy on 02/05/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import Foundation
import ReSwift
import PoqUtilities

public typealias CartDataAction = DataAction<CartDomainModel>

/**
 
 A wrapper struct for the Reducer method for Cart data.
 */
struct CartDataStateReducer {
    
   /// This method is the reducer for the Cart data property in the CartState object
   ///
   /// - Parameters:
   ///   - action: The action dispatched to the Store
   ///   - cart: The current Cart data state
   /// - Returns: The reduced Cart data state based on the current state and action received
   public static func reduceCartData(action: Action, state cart: CartDataState?) -> CartDataState {

        Log.debug("Action received: \(action)")
        Log.debug("Current State: \(String(describing: cart))")
    
        guard var cartDataState = cart else {
            
            return CartDataState(cart: CartDomainModel(cartId: "", cartItems: [], totalPriceFormatted: "", totalPrice: 0.00, customData: nil), error: nil, editedCart: nil)
        }
    
        // Remove any pre-existing errors
        cartDataState.error = nil
    
        let cart = cartDataState.cart
    
        if let presenterAction = action as? CartPresenterAction {
            
            var newCart = cartDataState.editedCart ?? cart
            
            switch presenterAction {
                
            case .deleteCartItem(let id):
            
                guard let indexOfDeletedCartItem = newCart.cartItems.index(where: { $0.id == id }) else {
                    
                    assertionFailure("Could not find the cart item to be deleted")
                    break
                }
                
                newCart.cartItems.remove(at: indexOfDeletedCartItem)
                
                cartDataState.editedCart = newCart
                
            case .updateQuantity(let id, let quantity):
                
                if let indexOfEditedCartItem = newCart.cartItems.index(where: { $0.id == id }) {
                    newCart.cartItems[indexOfEditedCartItem].quantity = quantity
                }
                
                cartDataState.editedCart = newCart
            
            case .cancelEdit:
                
                cartDataState.editedCart = nil
                
            case .goToCheckout:
                
                // If Cart has item which is out of stock. Show an error.
                if cartDataState.cart.cartItems.contains(where: { $0.isInStock == false }) {
                
                    cartDataState.error = CartError.outOfStockItemInCart
                }
                
            default:
                
                break
            }
        } else if let dataAction = action as? CartDataAction {
            
            switch dataAction {
            case .set(let data):
                
                cartDataState.cart = data
                
                // Set the editedCart to nil
                cartDataState.editedCart = nil
                
            case .edit(let data):
                
                cartDataState.cart = data
                
                // Set the editedCart to nil
                cartDataState.editedCart = nil
                
            case .error(let error):
                
                // 404 error is returned when the cart is empty. We don't treat that as an error.
                if case NetworkError.urlError(let code, _) = error, code == 404 {
                    
                    cartDataState.cart =  CartDomainModel(cartId: "", cartItems: [], totalPriceFormatted: "", totalPrice: 0.00, customData: nil)
                    break
                }
                cartDataState.error = error
            }
        }
    
        return cartDataState
    }
}
