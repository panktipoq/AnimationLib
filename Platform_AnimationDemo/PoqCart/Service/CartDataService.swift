//
//  CartDataService.swift
//  PoqCart
//
//  Created by Balaji Reddy on 03/08/2018.
//

import Foundation
import PoqNetworking
import ReSwift

public class CartDataService<CartApiClientType: CartApiClient, MapperType: CartDomainModelMappable>: CartDataServiceable where CartApiClientType.NetworkModelType == MapperType.NetworkModelType {
    
    let apiClient: CartApiClientType
    let domainModelMapper: MapperType
    
    public init(apiClient: CartApiClientType, domainModelMapper: MapperType) {
        self.apiClient = apiClient
        self.domainModelMapper = domainModelMapper
    }
    
    /// An ActionCreator for the Cart GET endpoint
    ///
    /// Returns immediately with a CartPresenterAction.showLoadingIndicator action and dispatches as DataAction.set action on success and an DataAction.error on failure of the request
    ///
    /// - Parameters:
    ///   - state: The state of the Cart screen
    ///   - store: The Cart Store instance
    /// - Returns: The Action to be dispatched
    public func getCart(state: CartState, store: Store<CartState>) -> Action? {

        let getCartCompletion: ((Result<[CartApiClientType.NetworkModelType]>) -> Void)  = { [weak self] result in
            
            guard let strongSelf = self else {
                
                assertionFailure("Failed to get an instance of self")
                return
            }
            
            switch result {
             
            case .success(let cartArray):
                
                if let cartArray = cartArray, cartArray.count == 1 {
                    
                    let cartDomainModel = strongSelf.domainModelMapper.map(from: cartArray[0])
                    store.dispatch(DataAction<CartDomainModel>.set(data: cartDomainModel))
                    
                }
                
            case .failure(let error):
    
                store.dispatch(CartDataAction.error(error))
            }
        }
        
        apiClient.getCart(completion: getCartCompletion)
        
        return CartPresenterAction.showLoadingIndicator
    }
    
    /// An ActionCreator for the Cart POST endpoint
    ///
    ///  Returns with CartPresenterAction.toggleEditMode action when the Cart has not been edited. Otherwise returns with a CartPresenterAction.showLoadingIndicator immediately and a DataAction.edit action on success and DataAction.error on failure
    /// - Parameters:
    ///   - state: The state of the Cart screen
    ///   - store: The Cart Store instance
    /// - Returns: The Action to be dispatched
    public func postCart(state: CartState, store: Store<CartState>) -> Action? {
        
        guard let editedCart = state.dataState.editedCart else {
            
            // Nothing to updated. Edited Cart is nil. Clear Edit Mode.
            return CartPresenterAction.toggleEditMode
        }
        
        let updatedCartItems = self.updatedCartItems(cart: state.dataState.cart, editedCart: editedCart)
    
        let postCartCompletion: ((Result<[CartApiClientType.NetworkModelType]>) -> Void) = { [weak self] result in
            
            guard let strongSelf = self else {
                
                assertionFailure("Failed to get an instance of self")
                return
            }
            
            switch result {
            case .success(let cartArray):
                
                if let cartArray = cartArray, cartArray.count == 1 {
                    
                    let cartDomainModel = strongSelf.domainModelMapper.map(from: cartArray[0])
                    store.dispatch(DataAction.edit(data: cartDomainModel))
                
                } else {
                    
                    // We received an empty payload on a successful response. Probably an http status code of 204(No Content)
                    let cart = CartDomainModel(cartId: "", cartItems: [], totalPriceFormatted: "", totalPrice: 0.00, customData: nil)
                    store.dispatch(DataAction<CartDomainModel>.edit(data: cart))
                }
                
            case .failure(let error):
                
                store.dispatch(CartDataAction.error(error))
            }
        }
        
        apiClient.postCart(body: UpdateCartRequest(items: updatedCartItems, customData: nil), completion: postCartCompletion)
        
        return CartPresenterAction.showLoadingIndicator
    }
    
    fileprivate func updatedCartItems(cart: CartDomainModel, editedCart: CartDomainModel) -> [UpdateCartRequest.CartItem] {
        
        var updatedCartItems = [UpdateCartRequest.CartItem]()
        
        cart.cartItems.forEach { cartItem in
            
            if let indexOfCartItem = editedCart.cartItems.index(where: { $0.id == cartItem.id }) {
                
                if editedCart.cartItems[indexOfCartItem].quantity != cartItem.quantity {
                    
                    let updatedcartRequestCartItem = UpdateCartRequest.CartItem(cartItemId: cartItem.id, quantity: editedCart.cartItems[indexOfCartItem].quantity, deleted: false, customData: nil)
                    updatedCartItems.append(updatedcartRequestCartItem)
                }
                
            } else {
                
                let updatedcartRequestCartItem = UpdateCartRequest.CartItem(cartItemId: cartItem.id, quantity: 0, deleted: true, customData: nil)
                updatedCartItems.append(updatedcartRequestCartItem)
            }
        }
        
        return updatedCartItems
    }
}
