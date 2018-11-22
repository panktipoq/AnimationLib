//
//  CartAnalyticsMiddleware.swift
//  PoqCart
//
//  Created by Balaji Reddy on 13/08/2018.
//

import Foundation
import ReSwift
import PoqAnalytics
import PoqUtilities

/// This struct is a wrapper for the analytics tracking middleware for Cart
struct CartAnalyticsMiddleware {
    
    /// This a middleware to track Cart Analytics. It tracks the bagUpdate and removeFromBag events
    public static let trackCartAnalytics: Middleware<CartState> = { dispatch, getState in
        
        return { next in
            
            return { action in
         
                guard let state = getState() else {
                    
                    Log.error("Unable to get state. Nothing to track.")
                    return next(action)
                }
                
                if let dataAction = action as? DataAction<CartDomainModel> {
                    
                    switch dataAction {

                    case .edit(let editedCart):
                        
                        CartAnalyticsMiddleware.trackCartEdit(cart: state.dataState.cart, editedCart: editedCart)
                        
                    default:
                        break
                    }
                }
                
                return next(action)
            }
        }
    }
    
    fileprivate static func trackCartEdit(cart: CartDomainModel, editedCart: CartDomainModel) {
        
        cart.cartItems.forEach { cartItem in
            
            // Item has been deleted
            if !editedCart.cartItems.contains(where: { $0.id == cartItem.id }) {
                
                PoqTrackerV2.shared.removeFromBag(productId: cartItem.externalProductId, productTitle: cartItem.productTitle)
            }
        }
        
        // Update bag quantity and total
        PoqTrackerV2.shared.bagUpdate(totalQuantity: editedCart.cartItems.reduce(0, { $1.quantity + $0 }), totalValue: editedCart.totalPriceFormatted)
    }
}
