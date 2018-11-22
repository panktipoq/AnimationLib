//
//  CloseButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 11/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

@objc public protocol CloseButtonDelegate: AnyObject {
    func closeButtonClicked()
}

open class CloseButton: UIButton {
    
    var isWhite = false {
        didSet {
            initCloseButtonStyle()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initCloseButtonStyle()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCloseButtonStyle()
    }
    
    func initCloseButtonStyle() {
        let buttonStyle = isWhite ? ResourceProvider.sharedInstance.clientStyle?.closeButtonWhiteStyle : ResourceProvider.sharedInstance.clientStyle?.closeButtonStyle
        configurePoqButton(style: buttonStyle)
    }
    
    open override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {}
    }
    
    open override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraitButton
        }
        set {}
    }
    
    open override var accessibilityLabel: String? {
        get {
            return AccessibilityLabels.close
        }
        set {}
    }
}
