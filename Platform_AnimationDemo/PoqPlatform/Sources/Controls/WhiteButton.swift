//
//  WhiteButton.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/16/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import UIKit

@objc public protocol WhiteButtonDelegate: AnyObject {
    func whiteButtonClicked(_ sender: Any?)
}

open class WhiteButton: UIButton {
    
    open var fontSize = CGFloat(AppTheme.sharedInstance.whiteButtonFont.pointSize)
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initWhiteButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWhiteButton()
    }
    
    func initWhiteButton() {
        var whiteButtonStyle = PoqButtonStyle(backgroundColor: UIColor.clear)
        
        var whiteButtonDefault: UIImage? = ImageInjectionResolver.loadImage(named: "WhiteButtonDefault")
        
        if whiteButtonDefault == nil {
            // Draw UnPressed Button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawWhiteButton(frame: bounds, pressed: false, buttonText: "", fontSize: fontSize)
            whiteButtonDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        var whiteButtonPressed: UIImage? = ImageInjectionResolver.loadImage(named: "WhiteButtonPressed")
        
        if whiteButtonPressed == nil {
            // Draw pressed button image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawWhiteButton(frame: bounds, pressed: true, buttonText: "", fontSize: fontSize)
            whiteButtonPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        // Set up Style with the images
        if let defaultImage = whiteButtonDefault,
            let pressedImage = whiteButtonPressed {
            
            whiteButtonStyle.backgroundImageForState = [.normal: defaultImage, .highlighted: pressedImage]
        }
        
        whiteButtonStyle.titleColorForState = [.normal: UIColor.black,
                                               .highlighted: UIColor.lightGray]
        
        whiteButtonStyle.font = AppTheme.sharedInstance.whiteButtonFont
        
        configurePoqButton(style: whiteButtonStyle)
    }    
}
