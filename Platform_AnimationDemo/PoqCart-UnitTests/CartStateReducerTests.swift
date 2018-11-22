//
//  CartStateReducerTests.swift
//  PoqCart-UnitTests
//
//  Created by Balaji Reddy on 23/09/2018.
//

import Foundation
import XCTest

@testable import PoqCart

public class CartStateReducerTests: XCTestCase {
    
    var cartState: CartState?
    
    override public func setUp() {
        
        guard let cart = CartTestDataProvider.cart else {
            
            XCTFail("Could not read test data")
            return
        }
        
        let cartViewState = CartViewState(screenState: .awaitingInteraction, inEditMode: false, isCheckoutEnabled: false, userLoggedIn: false, checkoutType: .transfer)
        
        cartState = CartState(viewState: cartViewState, dataState: CartDataState(cart: cart, error: nil, editedCart: nil))

    }
    
    func testGotoCheckoutError() {
        
        XCTAssertNotNil(cartState?.dataState.cart.cartItems.first(where: { $0.isInStock == false }), "No cart item out of stock. Check test data.")
        
        let gotoCheckoutState = CartStateReducer.reduceCartState(action: CartPresenterAction.goToCheckout, state: cartState)
        
        guard case .awaitingInteraction = gotoCheckoutState.viewState.screenState else {
            
            XCTFail("Screen state should be in awaitingInteraction")
            return
        }
    }
}
