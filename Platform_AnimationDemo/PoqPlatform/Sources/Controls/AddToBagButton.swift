//
//  AddToBagButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 12/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

public protocol AddToBagButtonDelegate: AnyObject {
    func addToBagButtonClicked(_ sender: Any?)
}

open class AddToBagButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initAddToBagButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initAddToBagButton()
    }
    
    func initAddToBagButton() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.primaryButtonStyle)
        setTitle(AppLocalization.sharedInstance.addToBagButtonText, for: .normal)
        setTitle(AppLocalization.sharedInstance.pdpSoldOutMessage, for: .disabled)
        accessibilityIdentifier = AccessibilityLabels.pdpAddToBag
        isEnabled = true
    }
}
