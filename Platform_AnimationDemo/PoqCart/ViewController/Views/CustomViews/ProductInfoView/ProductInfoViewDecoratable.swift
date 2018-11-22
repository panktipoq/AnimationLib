//
//  ProductTitleViewDecorator.swift
//  PoqCart
//
//  Created by Balaji Reddy on 13/05/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import Foundation
import UIKit
import Cartography

/**
    This protocol represents a type that can lay out the constraints of a ProductInfoView
 */
protocol ProductInfoViewDecoratable {
    func layout(productInfoView: ProductInfoView)
}

/**
    This is the concrete platform implementation of the ProductInfoViewDecoratable protocol
 */
struct ProductInfoViewDecorator: ProductInfoViewDecoratable {
    
    /// This method lays out the constraints for a ProductInfoView
    ///
    /// - Parameter productInfoView: The ProductInfoView whose constraints are to be laid out
    func layout(productInfoView: ProductInfoView) {
        
        guard
            let brandLabel = productInfoView.brandLabel,
            let colorLabel = productInfoView.colorLabel,
            let sizeLabel = productInfoView.sizeLabel
        else {
            
            assertionFailure("ProductInfoView does not have the right views for this decorator")
            return
        }
        
        let titleLabel = productInfoView.titleLabel
        
        brandLabel.setContentHuggingPriority(.required, for: .vertical)
        brandLabel.setContentHuggingPriority(.required, for: .horizontal)
        brandLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        colorLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        colorLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        colorLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        colorLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        sizeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        sizeLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        sizeLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        sizeLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        constrain(productInfoView as UIView, brandLabel, titleLabel, colorLabel, sizeLabel) { productInfoView, brandLabel, titleLabel, colorLabel, sizeLabel in
            
            brandLabel.top == productInfoView.top
            brandLabel.leading == productInfoView.leading
            
            titleLabel.leading == productInfoView.leading
            titleLabel.top == brandLabel.bottom + 2
            titleLabel.trailing == productInfoView.trailing
            brandLabel.trailing == productInfoView.trailing
            titleLabel.height >= 20
            
            sizeLabel.leading == productInfoView.leading
            colorLabel.top == titleLabel.bottom + 4 ~ .required
            
            colorLabel.leading == sizeLabel.trailing + 2
            
            sizeLabel.top == titleLabel.bottom + 4 ~ .required
            
            colorLabel.bottom == productInfoView.bottom ~ .required
            sizeLabel.bottom == productInfoView.bottom ~ .required
        }
    }
}
