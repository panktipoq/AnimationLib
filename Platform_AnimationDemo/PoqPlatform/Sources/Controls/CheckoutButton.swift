//
//  CheckoutButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 11/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class CheckoutButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    fileprivate final func configure() {
        accessibilityIdentifier = AccessibilityLabels.checkoutButton
        let title = AppLocalization.sharedInstance.checkoutButtonText
        let style = ResourceProvider.sharedInstance.clientStyle?.pdpCheckoutButtonStyle
        configurePoqButton(withTitle: title, using: style)
    }
}
