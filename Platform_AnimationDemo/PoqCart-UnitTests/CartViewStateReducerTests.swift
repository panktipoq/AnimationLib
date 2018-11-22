//
//  CartViewStateReducerTests.swift
//  PoqCart-UnitTests
//
//  Created by Balaji Reddy on 02/07/2018.
//

import Foundation
import XCTest

@testable import PoqCart

public class CartViewStateReducerTests: XCTestCase {
    
    var cartState: CartState?
    
    override public func setUp() {

        guard let cart = CartTestDataProvider.cart else {
            
            XCTFail("Could not read test data")
            return
        }

        let cartViewState = CartViewState(screenState: .awaitingInteraction, inEditMode: false, isCheckoutEnabled: false, userLoggedIn: false, checkoutType: .native)
        
        cartState = CartState(viewState: cartViewState, dataState: CartDataState(cart: cart, error: nil, editedCart: nil))
    }
    
    func testToggleEditModeAction() {
        
        let editingState = CartViewStateReducer.reduceCartViewState(action: CartPresenterAction.toggleEditMode, state: cartState?.viewState)
        
        XCTAssertTrue(editingState.inEditMode, "view-state not in edit mode")
        
        let doneEditingState = CartViewStateReducer.reduceCartViewState(action: CartPresenterAction.toggleEditMode, state: editingState)
        
        XCTAssertFalse(doneEditingState.inEditMode, "view-state still in edit mode")
    }

    func testGotoCheckoutAction() {
        
        // When user taps on checkout, if checkoutType is native and the user is not logged in then navigate to login
        let gotoLoginState = CartViewStateReducer.reduceCartViewState(action: CartPresenterAction.goToCheckout, state: cartState?.viewState)
   
        switch gotoLoginState.screenState {
            
        case .navigateTo(let route):
            
            XCTAssertEqual(route.routeIdentifier, CartRouteID.login.rawValue, "Wrong route: \(String(describing: route.routeIdentifier)) for provided state and action")
            
        default:
            
            XCTFail("ViewState should be in navigateTo(route) state")
        }
        
        cartState?.viewState.checkoutType = .transfer
        
        // When user taps on checkout, if checkoutType is webCheckout and regardless if the user login state, navigate to web checkout
        let gotoWebCheckoutState = CartViewStateReducer.reduceCartViewState(action: CartPresenterAction.goToCheckout, state: cartState?.viewState)
        
        switch gotoWebCheckoutState.screenState {
        
        case .navigateTo(let route):
            
            XCTAssertEqual(route.routeIdentifier, CartRouteID.webCheckout.rawValue, "Wrong route: \(String(describing: route.routeIdentifier)) for provided state and action")
            
        default:
            
            XCTFail("ViewState should be in navigateTo(route) state")
        }
        
        cartState?.viewState.checkoutType = .native
        cartState?.viewState.userLoggedIn = true
        
        // When user taps on checkout, if checkoutType is nativeCheckout and if user is logged in then navigate to native checkout
        let gotoNativeCheckoutState = CartViewStateReducer.reduceCartViewState(action: CartPresenterAction.goToCheckout, state: cartState?.viewState)
        
        switch gotoNativeCheckoutState.screenState {
            
        case .navigateTo(let route):
            
            XCTAssertEqual(route.routeIdentifier, CartRouteID.nativeCheckout.rawValue, "Wrong route: \(String(describing: route.routeIdentifier)) for provided state and action")
            
        default:
            
            XCTFail("ViewState should be in navigateTo(route) state")
        }
    }
    
    func testGotoBackgroundAction() {
        
        let gotoBackgroundState = CartViewStateReducer.reduceCartViewState(action: CartPresenterAction.goToBackground, state: cartState?.viewState)
        
        switch gotoBackgroundState.screenState {
            
        case .background:
            
            break
            
        default:
            
            XCTFail("ViewState should be in background state")
        }
    }
    
    func testTapOnCartItemAction() {
        
        let tapOnCartItemActionState = CartViewStateReducer.reduceCartViewState(action: CartPresenterAction.tapOnCartItem(productId: "3364503", externalProductId: nil), state: cartState?.viewState)
        
        switch tapOnCartItemActionState.screenState {
            
        case .navigateTo(let route):
            
            XCTAssertEqual(route.routeIdentifier, CartRouteID.productDetail.rawValue, "Wrong route: \(String(describing: route.routeIdentifier)) for provided state and action")
            
        default:
            
            XCTFail("ViewState should be in background state")
        }
    }
    
    func testShowLoadingIndicatorAction() {
        
        let showLoadingIndicatorActionState = CartViewStateReducer.reduceCartViewState(action: CartPresenterAction.showLoadingIndicator, state: cartState?.viewState)
        
        switch showLoadingIndicatorActionState.screenState {
            
        case .loading:
            
            break
            
        default:
            
            XCTFail("ViewState should be in loading state")
        }
    }
    
    func testSetLoginStatusAction() {
        
        let setLoginStatusActionState = CartViewStateReducer.reduceCartViewState(action: CartPresenterAction.setLoginStatus(userLoggedIn: true), state: cartState?.viewState)
        
        XCTAssert(setLoginStatusActionState.userLoggedIn == true, " User Logged in status not updated")
    }
    
    func testSetCheckoutTypeAction() {

        let setCheckoutTypeActionState = CartViewStateReducer.reduceCartViewState(action: CartPresenterAction.setCheckoutType(checkoutType: .transfer), state: cartState?.viewState)

        XCTAssertEqual(setCheckoutTypeActionState.checkoutType, .transfer, "Checkout type not updated")
    }

    func testSetDataAction() {
        
        let setDataActionState = CartViewStateReducer.reduceCartViewState(action: CartDataAction.set(data: CartDomainModel(cartId: "", cartItems: [], totalPriceFormatted: "", totalPrice: 0.00, customData: nil)), state: cartState?.viewState)
        
        // Checkout should be disabled as there are no cart items
        XCTAssertEqual(setDataActionState.isCheckoutEnabled, false, "Checkout still enabled when set data action with empty cart dispatched")

        switch setDataActionState.screenState {

        case .awaitingInteraction:

            break

        default:

            XCTFail("ViewState should be in awaitingInteraction state")
        }
    }
    
    func testEditDataAction() {

        let setEditActionState = CartViewStateReducer.reduceCartViewState(action: CartDataAction.edit(data: CartDomainModel(cartId: "", cartItems: [], totalPriceFormatted: "", totalPrice: 0.00, customData: nil)), state: cartState?.viewState)

        // Checkout should be disabled as there are no cart items
        XCTAssertEqual(setEditActionState.isCheckoutEnabled, false, "Checkout still enabled when edit data action with empty cart dispatched")

        switch setEditActionState.screenState {

        case .awaitingInteraction:

            break

        default:

            XCTFail("ViewState should be in awaitingInteraction state")
        }
    }
    
    func testGotoShopAction() {
        
        let goToShopState = CartViewStateReducer.reduceCartViewState(action: CartPresenterAction.goToShop, state: cartState?.viewState)
        
        switch goToShopState.screenState {
        case .navigateTo(let route):
            XCTAssertEqual(route.routeIdentifier, CartRouteID.shop.rawValue, "Wrong route id in state")
        default:
            XCTFail("ViewState should be in navigateTo route")
        }
    }
}
