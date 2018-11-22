//
//  BagCellPresenter.swift
//  PoqCart
//
//  Created by Balaji Reddy on 27/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

/**
    This protocol represents a type that acts as a delegate for a Bag item cell
 */
public protocol CartItemCellPresenter: AnyObject {
    func updateQuantity(of bagItemId: String, to quantity: Int)
    func deleteCartItem(id: String)
    func didTapOnCartItem(id: String)
    func wishlistItem(id: String)
}

/**
 
    This protocol is the aggregate protocol that represents a type that acts as a delegate for all the cells in a Bag screen
 */
public protocol CartCellPresenter: CartItemCellPresenter { }

/**
    This protocol represents a type that acts as a delegate for the Bag screen
 */
public protocol CartPresenter {
    
    func checkoutButtonTapped()
    func startShoppingButtonTapped()
    func refresh()
}
