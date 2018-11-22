//
//  PriceViewDecorator.swift
//  PoqCart
//
//  Created by Balaji Reddy on 14/05/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import Foundation
import UIKit
import Cartography

/**
    This protocol represents a type that can layout the constraints for a PriceView
 */
public protocol PriceViewDecoratable {
    func layout(priceView: PriceView)
}

/**
    This is the concrete platform implementation of the PriceViewDecoratable protocol
 */
struct PoqPriceViewDecorator: PriceViewDecoratable {
    
    /// This method lays out the constraints for the PriceView
    ///
    /// - Parameter priceView: The PriceView instance whose constraints are to be laid out
    func layout(priceView: PriceView) {
        
        let nowPriceLabel = priceView.nowPriceLabel
        let wasPriceLabel = priceView.wasPriceLabel
        
        nowPriceLabel.setContentHuggingPriority(.required, for: .horizontal)
        nowPriceLabel.setContentHuggingPriority(.required, for: .vertical)
        
        wasPriceLabel.setContentHuggingPriority(.required, for: .horizontal)
        wasPriceLabel.setContentHuggingPriority(.required, for: .vertical)
        
        nowPriceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        wasPriceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        nowPriceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        wasPriceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        constrain(priceView as UIView, nowPriceLabel, wasPriceLabel) { priceView, nowPriceLabel, wasPriceLabel in
            
            wasPriceLabel.leading == priceView.leading
            wasPriceLabel.top == priceView.top
            wasPriceLabel.bottom == priceView.bottom
            
            nowPriceLabel.leading ==  wasPriceLabel.trailing + 5
            
            nowPriceLabel.top == priceView.top
            nowPriceLabel.trailing == priceView.trailing
            nowPriceLabel.bottom == priceView.bottom
        }
    }
}
