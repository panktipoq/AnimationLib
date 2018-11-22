//
//  ViewStateReducer.swift
//  PoqCart
//
//  Created by Balaji Reddy on 02/05/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import Foundation
import ReSwift
import PoqUtilities

public typealias ProductID = (productId: Int, externalProductId: String?)

struct CartViewStateReducer {
    
    fileprivate static func reduceToggleEditMode(_ state: CartViewState) -> CartViewState {
        
        var state = state
        
        state.inEditMode = !state.inEditMode
        
        state.isCheckoutEnabled = !state.inEditMode
        
        return state
    }

    fileprivate static func reduceGotoBackground(_ state: CartViewState) -> CartViewState {
        
        var state = state
        
        state.screenState = .background
        
        return state
    }
    
    fileprivate static func reduceGotoCheckout(_ state: CartViewState) -> CartViewState {
        
        var state = state
        
        switch state.checkoutType {
            
        case .native:
            
            switch state.userLoggedIn {
                
            case true:
                
                let checkoutRoute = Route(routeIdentifier: CartRouteID.nativeCheckout.rawValue, data: nil)
                state.screenState = .navigateTo(route: checkoutRoute)
                
            case false:
                
                let loginRoute = Route(routeIdentifier: CartRouteID.login.rawValue, data: nil)
                state.screenState = .navigateTo(route: loginRoute)
            }
            
        case .transfer:
            let checkoutRoute = Route(routeIdentifier: CartRouteID.webCheckout.rawValue, data: nil)
            state.screenState = .navigateTo(route: checkoutRoute)
        }
        
        return state
    }
    
    fileprivate static func reduceTapOnCartItem(_ productIds: (String, String?), _ state: CartViewState) -> CartViewState {
        
        var state = state
        
        let productDetailsRoute = Route(routeIdentifier: CartRouteID.productDetail.rawValue, data: (productIds))
        
        state.screenState = .navigateTo(route: productDetailsRoute)
        
        return state
    }
    
    fileprivate static func reduceShowLoadingIndicator(_ state: CartViewState) -> CartViewState {
        
        var state = state
        
        state.screenState = .loading
        
        state.isCheckoutEnabled = false
        
        return state
    }
    
    fileprivate static func reduceSetLoginStatus(_ state: CartViewState, _ userLoggedIn: Bool) -> CartViewState {
        
        var state = state
        
        state.userLoggedIn = userLoggedIn
        
        return state
    }
    
    fileprivate static func reduceSetCheckoutType(_ state: CartViewState, _ checkoutType: CartType) -> CartViewState {
        
        var state = state
        state.checkoutType = checkoutType
        
        return state
    }
    
    fileprivate static func reduceGoToShop(_ state: CartViewState) -> CartViewState {
        
        var state = state
        
        let shop = Route(routeIdentifier: CartRouteID.shop.rawValue, data: nil)
        state.screenState = .navigateTo(route: shop)
        
        return state
    }
    
    fileprivate static func reduceCartSetOrEdit(_ state: CartViewState, _ cart: CartDomainModel) -> CartViewState {
        
        var state = state
        
        // Data has just been set. We cancel the editMode and set the viewState to .awaitingInteraction.
        state.screenState = .awaitingInteraction
        
        state.inEditMode = false
        
        state.isCheckoutEnabled =  cart.cartItems.reduce(0, { return $1.quantity + $0 }) > 0
        
        return state
    }
    
    fileprivate static func reduceCancelEdit(_ state: CartViewState) -> CartViewState {
        var state = state
        
        state.inEditMode = false
        state.isCheckoutEnabled = true
        
        return state
    }
    
    /// This method is the reducer for the ViewState property in the CartState object
    ///
    /// - Parameters:
    ///   - action: The action dispatched to the Store
    ///   - cart: The current Cart view state
    /// - Returns: The reduced Cart view state based on the current state and action received
    public static func reduceCartViewState(action: Action, state: CartViewState?) -> CartViewState {
       
        guard let state = state else {
            
            return CartViewState(screenState: .background, inEditMode: false, isCheckoutEnabled: false, userLoggedIn: false, checkoutType: CartType.transfer)
        }
        
        if let presenterAction = action as? CartPresenterAction {
       
            Log.verbose("Action received: \(action)")
            Log.verbose("Current state: \(state)")
            
            switch presenterAction {
                
            case .toggleEditMode:
                
                return reduceToggleEditMode(state)
                
            case .goToBackground:
                
                return reduceGotoBackground(state)
                
            case .goToCheckout:
                
                return reduceGotoCheckout(state)
                
            case .tapOnCartItem(let platformProductId, let clientProductId):
                
                return reduceTapOnCartItem((platformProductId, clientProductId), state)
                
            case .showLoadingIndicator:
                
                return reduceShowLoadingIndicator(state)
            
            case .setLoginStatus(let userLoggedIn):
                
                return reduceSetLoginStatus(state, userLoggedIn)
                
            case .setCheckoutType(let checkoutType):
                
                return reduceSetCheckoutType(state, checkoutType)
                
            case .goToShop:
                
                return reduceGoToShop(state)
                
            case .cancelEdit:
                
                return reduceCancelEdit(state)

            default:
                
                break
            }
            
        } else if let dataAction = action as? CartDataAction {
            
            switch dataAction {
                
            case .set(let cart):
               
                return reduceCartSetOrEdit(state, cart)
                 
            case .edit(let cart):
                
                return reduceCartSetOrEdit(state, cart)
                
            case .error:
                
                var state = state
                
                state.screenState = .awaitingInteraction
                
                return state
            }
        }
        
       return state
    }
}
