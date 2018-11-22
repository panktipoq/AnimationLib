//
//  QuantityViewDecorator.swift
//  PoqCart
//
//  Created by Balaji Reddy on 15/05/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import Foundation
import UIKit
import Cartography

/**
  This protocol represents a type that can layout the constraints for a QuantityView
 */
protocol QuantityViewDecoratable {
 
    func layout(quantityView: QuantityView)
}

/**
    This is the concrete platform implementation of the QuantityViewDecoratable protocol
 */
struct QuantityViewDecorator: QuantityViewDecoratable {
    
    /// This method lays out the constraint of a QuantityView
    ///
    /// - Parameter quantityView: The QuantityView whose constraints are to be laid out
    func layout(quantityView: QuantityView) {
        
        if
            let quantityLabel = quantityView.quantityLabel,
            let quantityTextField = quantityView.quantityTextField,
            let increaseButton = quantityView.increaseButton,
            let decreaseButton = quantityView.decreaseButton {
        
            quantityTextField.setContentCompressionResistancePriority(.required, for: .horizontal)
            quantityTextField.setContentCompressionResistancePriority(.required, for: .vertical)
            quantityTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
            quantityTextField.setContentHuggingPriority(.defaultLow, for: .vertical)
            
            quantityLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            quantityLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            quantityLabel.setContentHuggingPriority(.required, for: .horizontal)
            quantityLabel.setContentHuggingPriority(.required, for: .vertical)
            
            constrain(quantityView as UIView,
                      quantityLabel,
                      quantityTextField,
                      increaseButton,
                      decreaseButton) {
                        
                        quantityView,
                        quantityLabel,
                        quantityTextField,
                        increaseButton,
                        decreaseButton
                        in
                        
                            quantityLabel.top == quantityView.top
                            quantityLabel.bottom == quantityView.bottom
                            quantityLabel.leading == quantityView.leading
                            quantityLabel.trailing == quantityView.trailing
                        
                            quantityTextField.top == quantityView.top
                            quantityTextField.bottom == quantityView.bottom
                            quantityTextField.centerX == quantityView.centerX
                            quantityTextField.width == 30

                            decreaseButton.leading == quantityView.leading
                            decreaseButton.top == quantityView.top
                            decreaseButton.width == 20
                            decreaseButton.height == decreaseButton.width
                            decreaseButton.trailing == quantityTextField.leading - 5

                            increaseButton.trailing == quantityView.trailing
                            increaseButton.top == quantityView.top
                            increaseButton.width == decreaseButton.width
                            increaseButton.height == decreaseButton.height
                            increaseButton.leading == quantityTextField.trailing + 5
            }
        }
    }
}
