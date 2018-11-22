//
//  CartDataStateReducerTests.swift
//  PoqCart
//
//  Created by Balaji Reddy on 03/07/2018.
//

import Foundation
import XCTest

@testable import PoqCart

public class CartDataStateReducerTests: XCTestCase {
    
    var cartState: CartState?
    
    override public func setUp() {
        
        guard let cart = CartTestDataProvider.cart else {
            
            XCTFail("Could not read test data")
            return
        }
        
        let cartViewState = CartViewState(screenState: .awaitingInteraction, inEditMode: false, isCheckoutEnabled: false, userLoggedIn: false, checkoutType: .native)
        
        cartState = CartState(viewState: cartViewState, dataState: CartDataState(cart: cart, error: nil, editedCart: nil))
    }
    
    func testDeleteCartItemAction() {
        
        let testCartItemId = "61669731"
        
        XCTAssertNotNil(cartState?.dataState.cart.cartItems.first(where: { $0.id == testCartItemId }), "Cart Item does not exist. Check test data.")
        
        let deleteCartItemActionDataState = CartDataStateReducer.reduceCartData(action: CartPresenterAction.deleteCartItem(id: testCartItemId), state: cartState?.dataState)
        
        XCTAssertNotNil(deleteCartItemActionDataState.editedCart, "Edited cart is nil even after an edit.")
        
        XCTAssertNil(deleteCartItemActionDataState.editedCart?.cartItems.first(where: { $0.id == testCartItemId }), "Cart Item not deleted")
    }
    
    func testUpdateQuantityAction() {
        
        let testCartItemId = "61669731"
        let testQuantity = 3
        
        XCTAssertNotNil(cartState?.dataState.cart.cartItems.first(where: { $0.id == testCartItemId }), "Cart Item does not exist. Check test data.")
        
        XCTAssertNotEqual(cartState?.dataState.cart.cartItems.first(where: { $0.id == testCartItemId })?.quantity, testQuantity, "Quantity already set to final value. Check test data.")
        
        let updateQuantityCartPresenterActionState = CartDataStateReducer.reduceCartData(action: CartPresenterAction.updateQuantity(id: testCartItemId, quantity: testQuantity), state: cartState?.dataState)
        
        XCTAssertNotNil(updateQuantityCartPresenterActionState.editedCart, "Edited cart is nil even after an edit.")
        
        XCTAssertEqual(updateQuantityCartPresenterActionState.editedCart?.cartItems.first(where: { $0.id == testCartItemId })?.quantity, testQuantity, "Cart Item quantity not updated")
    }
    
    func testSetDataAction() {

        let testCartItemId = "61669731"
        
        XCTAssertNotNil(cartState?.dataState.cart.cartItems.first(where: { $0.id == testCartItemId }), "Cart Item does not exist. Check test data.")
        
        guard var testCartData = cartState?.dataState else {
            
            XCTFail("No data in test state. Check setup.")
            return
        }
        
        guard let cartItemWithTestIdIndex = cartState?.dataState.cart.cartItems.index(where: { $0.id == testCartItemId }) else {
            XCTFail("Can't find cart item with the test cart item id. Check test data.")
            return
        }
        
        testCartData.cart.cartItems.remove(at: cartItemWithTestIdIndex)
        
        let setDataActionState = CartDataStateReducer.reduceCartData(action: DataAction.set(data: testCartData.cart), state: cartState?.dataState )
        
        XCTAssertNil(setDataActionState.cart.cartItems.first(where: { $0.id == testCartItemId }), "Removed Cart Item does exit. Cart data set action did not succeed.")
    }
    
    func testCancelEditAction() {
        
        let testCartItemId = "61669731"
        
        XCTAssertNotNil(cartState?.dataState.cart.cartItems.first(where: { $0.id == testCartItemId }), "Cart Item does not exist. Check test data.")
        
        XCTAssertNil(cartState?.dataState.editedCart, "Edited Cart not nil before editing. Check test data")
        
        let deletedCartItemDataState = CartDataStateReducer.reduceCartData(action: CartPresenterAction.deleteCartItem(id: testCartItemId), state: cartState?.dataState)
        
        XCTAssertNotNil(deletedCartItemDataState.editedCart, "Edited Cart nil even after deleting cart item.")
        
        let cancelledEditDataState = CartDataStateReducer.reduceCartData(action: CartPresenterAction.cancelEdit, state: deletedCartItemDataState)
        
        XCTAssertNil(cancelledEditDataState.editedCart, "Edited Cart not nil even after cancelling edit.")
    }
    
    func testGotoCheckoutAction() {
        
         XCTAssertNotNil(cartState?.dataState.cart.cartItems.first(where: { $0.isInStock == false }), "No cart item out of stock. Check test data.")
        
        XCTAssertNil(cartState?.dataState.error, "Already in error state. Cannot proceed with test. Check test data.")
        
        let goToCheckoutDataState = CartDataStateReducer.reduceCartData(action: CartPresenterAction.goToCheckout, state: cartState?.dataState)
        
        XCTAssertNotNil(goToCheckoutDataState.error, "No error on goToCheckout action even when item out of stock")
    }
}
