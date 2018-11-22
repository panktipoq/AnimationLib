//
//  BlackButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 07/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

@objc public protocol BlackButtonDelegate: AnyObject {
    func blackButtonClicked(_ sender: Any?)
}

open class BlackButton: UIButton {

    public var buttonTag = 0

    public var borderWidth: CGFloat = 0.5
    
    public var fontSize = CGFloat(AppTheme.sharedInstance.blackButtonFont.pointSize)
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initBlackButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initBlackButton()
    }
    
    func initBlackButton() {
        var blackButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var blackButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "BlackButtonDefault")
        
        if blackButtonDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawBlackButton(frame: bounds, pressed: false, buttonText: "", fontSize: fontSize, borderWidth: borderWidth, disabled: false)
            blackButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var blackButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: "BlackButtonPressed")
        
        if blackButtonPressed == nil {
            // Draw pressed button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawBlackButton(frame: bounds, pressed: true, buttonText: "", fontSize: fontSize, borderWidth: borderWidth, disabled: false)
            blackButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var blackButtonDisabled: UIImage? = ImageInjectionResolver.loadImage(named: "BlackButtonDisabled")
        
        if blackButtonDisabled == nil {
            // Draw pressed button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawBlackButton(frame: bounds, pressed: false, buttonText: "", fontSize: fontSize, borderWidth: borderWidth, disabled: true)
            blackButtonDisabled = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = blackButtonDefault, let pressedImage = blackButtonPressed, let disabledImage = blackButtonDisabled {
            
            blackButtonStyle.backgroundImageForState = [.normal: defaultImage,
                                                        .highlighted: pressedImage,
                                                        .disabled: disabledImage]
        }
        
        blackButtonStyle.titleColorForState = [.normal: UIColor.white]
        
        blackButtonStyle.font = AppTheme.sharedInstance.blackButtonFont
        
        configurePoqButton(style: blackButtonStyle)
    }
}
