//
//  BagViewDecorator.swift
//  PoqCart
//
//  Created by Balaji Reddy on 24/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import UIKit
import Cartography

/**
 
    This protocol represents a type the can lay out the constraints for a Bag view instance
 */
public protocol CartViewDecoratable {
    func layout(cartView: CartView)
    func toggleCheckoutPanelHeight(checkoutPanelView: UIView, collapse: Bool)
}

/**
    This is the default platform implementation of the BagViewDecoratable protocol
 */
public class CartViewDecorator: CartViewDecoratable {
    
    static let checkoutPanelViewHeight: CGFloat = 96.0
    var checkoutPanelHeightConstraintGroup: ConstraintGroup?
    
    public init() { }
    
    /// This method lays out the constraints for a Bag View instance
    ///
    /// - Parameter cartView: The cart view instance whose constraints are to be laid out
    public func layout(cartView: CartView) {
        
        constrain(cartView, cartView.cartContentTable, cartView.checkoutPanel as UIView, cartView.emptyCartView as UIView) { cartView, tableView, checkoutPanelView, emptyCartView in
            
            tableView.top == cartView.safeAreaLayoutGuide.top
            tableView.leading == cartView.safeAreaLayoutGuide.leading
            tableView.trailing == cartView.safeAreaLayoutGuide.trailing
            
            checkoutPanelView.bottom == cartView.safeAreaLayoutGuide.bottom
            checkoutPanelView.leading == cartView.safeAreaLayoutGuide.leading
            checkoutPanelView.trailing == cartView.safeAreaLayoutGuide.trailing
            
            emptyCartView.top == cartView.safeAreaLayoutGuide.top
            emptyCartView.leading == cartView.safeAreaLayoutGuide.leading
            emptyCartView.trailing == cartView.safeAreaLayoutGuide.trailing
            emptyCartView.bottom == checkoutPanelView.top
            
            tableView.bottom == checkoutPanelView.top
        }
        
       checkoutPanelHeightConstraintGroup = constrain(cartView.checkoutPanel as UIView) { checkoutPanelView in
            
            checkoutPanelView.height == CartViewDecorator.checkoutPanelViewHeight
        }
    }
    
    public func toggleCheckoutPanelHeight(checkoutPanelView: UIView, collapse: Bool) {
        
        guard let checkoutPanelHeightConstraintGroup = checkoutPanelHeightConstraintGroup else {
            assertionFailure("No CheckoutPanelConstraintGroup to change constraints")
            return
        }
        
        constrain(checkoutPanelView, replace: checkoutPanelHeightConstraintGroup) { checkoutPanelView in
            
            checkoutPanelView.height == (collapse ? 0 : CartViewDecorator.checkoutPanelViewHeight)
        }
    }
}
