//
//  CartStateReducer.swift
//  PoqCart
//
//  Created by Balaji Reddy on 23/09/2018.
//

import Foundation
import ReSwift

struct CartStateReducer {
    
    /// This method is the reducer for Cart state
    ///
    /// - Parameters:
    ///   - action: The action dispatched to the Store
    ///   - cart: The current cart state
    /// - Returns: The reduced Cart state based on the current state and action received
    public static func reduceCartState(action: Action, state: CartState?) -> CartState {
     
        var viewState = CartViewStateReducer.reduceCartViewState(action: action, state: state?.viewState)
        let dataState = CartDataStateReducer.reduceCartData(action: action, state: state?.dataState)
        
        switch action {
        case let presenterAction as CartPresenterAction:
            switch presenterAction {
            case .goToCheckout:
                
                // If there's an error (OutOfStock for instance) then we do not go to checkout and set the state back to awaiting interaction
                if dataState.error != nil {
                    viewState.screenState = .awaitingInteraction
                }
            default:
                break
            }
        default:
            break
        }
        
        return CartState(viewState: viewState, dataState: dataState)
    }
}
