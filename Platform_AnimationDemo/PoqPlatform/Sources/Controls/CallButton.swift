//
//  CallButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 27/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

public protocol CallButtonDelegate: AnyObject {
    func callButtonClicked(_ sender: Any?)
}

open class CallButton: UIButton {

    public var fontSize = CGFloat(AppTheme.sharedInstance.callButtonFont.pointSize)
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initCallButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCallButton()
    }
    
    func initCallButton() {
        
        var callButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var defaultImageName: String = "CallButtonDefault"
        var pressedImageName: String = "CallButtonPressed"
        var disabledImageName: String = "CallButtonDisabled"
        
        if title(for: .normal) == nil {
            defaultImageName = "CallIconDefault"
            pressedImageName = "CallIconPressed"
            disabledImageName = "CallIconDisabled"
        }
        
        var callButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: defaultImageName)
        
        if callButtonDefault == nil {
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawCallButton(frame: bounds, pressed: false, buttonText: "", fontSize: fontSize, disabled: false)
            callButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var callButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: pressedImageName)
        
        if callButtonPressed == nil {
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawCallButton(frame: bounds, pressed: true, buttonText: "", fontSize: fontSize, disabled: false)
            callButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var callButtonDisabled: UIImage? = ImageInjectionResolver.loadImage(named: disabledImageName)
        
        if callButtonDisabled == nil {
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawCallButton(frame: bounds, pressed: false, buttonText: "", fontSize: fontSize, disabled: true)
            callButtonDisabled = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        if let defaultImage = callButtonDefault, let pressedImage = callButtonPressed, let disabledImage = callButtonDisabled {
            callButtonStyle.backgroundImageForState = [.normal: defaultImage, .highlighted: pressedImage, .disabled: disabledImage]
        }
        
        callButtonStyle.font = AppTheme.sharedInstance.callButtonFont
        
        callButtonStyle.titleColorForState = [.normal: AppTheme.sharedInstance.callButtonTextColor]
        
        configurePoqButton(style: callButtonStyle)
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
            return AccessibilityLabels.call
        }
        set {}
    }
    
    override open func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        initCallButton()
    }
}
