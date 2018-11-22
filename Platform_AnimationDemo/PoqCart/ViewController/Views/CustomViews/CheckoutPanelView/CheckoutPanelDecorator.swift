//
//  CheckoutPanelDecorator.swift
//  PoqCart
//
//  Created by Balaji Reddy on 24/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import UIKit
import Cartography

/**
    This protocol represents a type that can lay out the constraints for a CheckoutPanelView
 */
protocol CheckoutPanelDecoratable {
    func layout(checkoutPanelView: CheckoutPanelView)
    func toggleInternalHeightConstraints(checkoutPanelView: CheckoutPanelView, collapse: Bool)
}

/**
 
    This is the concrete platform implementation of the CheckoutPanelDecoratable protocol
 */
public class CheckoutPanelDecorator: CheckoutPanelDecoratable {
    
    var heightConstraintGroup: ConstraintGroup?
    let topPadding: CGFloat = 7
    let bottomPadding: CGFloat = 15
    let paddingBetweenLabelsAndButton: CGFloat = 5
    let separatorHeight: CGFloat = 0.5
    
    typealias ConstrainBlockType = (SupportsPositioningLayoutProxy, SupportsPositioningLayoutProxy, SupportsPositioningLayoutProxy, SupportsPositioningLayoutProxy, SupportsPositioningLayoutProxy) -> Void

    fileprivate func constrainHeight(collapsed: Bool = false) -> ConstrainBlockType {

        return { checkoutPanelView, checkoutButton, numberOfItemsLabel, totalPriceLabel, separator in
            totalPriceLabel.top == separator.top + (collapsed ? 0 : self.topPadding)
            totalPriceLabel.bottom == checkoutButton.top - (collapsed ? 0 : self.paddingBetweenLabelsAndButton)
            
            numberOfItemsLabel.top == separator.top + (collapsed ? 0 : self.topPadding)
            numberOfItemsLabel.bottom == checkoutButton.top - (collapsed ? 0 : self.paddingBetweenLabelsAndButton)
            checkoutPanelView.bottom == checkoutButton.bottom + (collapsed ? 0 : self.bottomPadding)
            
            separator.height == (collapsed ? 0 : self.separatorHeight)
        }
        
    }
    
    func layout(checkoutPanelView: CheckoutPanelView) {
        
        guard
            let checkoutButton = checkoutPanelView.checkoutButton,
            let numberOfItemsLabel = checkoutPanelView.numberOfItemsLabel,
            let totalPriceLabel = checkoutPanelView.totalPriceLabel,
            let separator = checkoutPanelView.separator,
            let payWithCardButton = checkoutPanelView.payWithCardButton,
            let applePayButton = checkoutPanelView.applePayButton
        else {
            
            assertionFailure("Checkout Panel does not have the required views to be laid out by this decorator")
            return
        }
        
        constrain(checkoutPanelView, checkoutButton, numberOfItemsLabel, totalPriceLabel, separator, payWithCardButton, applePayButton) { checkoutPanelView, checkoutButton, numberOfItemsLabel, totalPriceLabel, separator, payWithCardButton, applePayButton in
            
            separator.top == checkoutPanelView.top
            separator.leading == checkoutPanelView.leading
            separator.trailing == checkoutPanelView.trailing
            
            checkoutPanelView.leading == checkoutButton.leading - 15
            checkoutPanelView.trailing == checkoutButton.trailing + 15
            
            align(leading: checkoutButton, numberOfItemsLabel)
            
            align(trailing: checkoutButton, totalPriceLabel)
        
            align(leading: checkoutButton, payWithCardButton)
            align(trailing: checkoutButton, applePayButton)
            align(top: checkoutButton, payWithCardButton, applePayButton)
            align(bottom: checkoutButton, payWithCardButton, applePayButton)
        
            payWithCardButton.width == checkoutButton.width/2 - 5
            applePayButton.width == checkoutButton.width/2 - 5
        }
        
        heightConstraintGroup = constrain(checkoutPanelView, checkoutButton, numberOfItemsLabel, totalPriceLabel, separator, block: constrainHeight(collapsed: false))
    }
    
    func toggleInternalHeightConstraints(checkoutPanelView: CheckoutPanelView, collapse: Bool) {
        
        guard let heightConstraintGroup = heightConstraintGroup else {
            assertionFailure("No heightConstraintGroup to change constraints")
            return
        }
        
        guard
            let checkoutButton = checkoutPanelView.checkoutButton,
            let numberOfItemsLabel = checkoutPanelView.numberOfItemsLabel,
            let totalPriceLabel = checkoutPanelView.totalPriceLabel,
            let separator = checkoutPanelView.separator
        else {
                
                assertionFailure("Checkout Panel does not have the required views to be laid out by this decorator")
                return
        }
       
        constrain(checkoutPanelView, checkoutButton, numberOfItemsLabel, totalPriceLabel, separator, replace: heightConstraintGroup, block: constrainHeight(collapsed: collapse))
    }
}
