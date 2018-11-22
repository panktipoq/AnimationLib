//
//  PoqButton.swift
//  Poq.iOS.Belk
//
//  Created by Balaji Reddy on 14/11/2016.
//
//

import PoqModuling
import PoqUtilities
import UIKit

public struct PoqButtonStyle {
    
    public var backgroundColor: UIColor?
    public var tintColor: UIColor?
    public var titleColorForState: [UIControlState: UIColor]?
    public var backgroundImageForState: [UIControlState: UIImage?]?
    public var imageForState: [UIControlState: UIImage]?
    public var cornerRadius: CGFloat?
    public var borderWidth: CGFloat?
    public var borderColor: UIColor?
    public var font: UIFont?
    public var shouldAddDropShadow: Bool?
    public var clipsToBounds: Bool?
    public var imageEdgeInsets: UIEdgeInsets?
    
    
    public init(backgroundColor: UIColor? = nil,
                tintColor: UIColor? = nil,
                titleColorForState: [UIControlState: UIColor]? = nil,
                backgroundImageForState: [UIControlState: UIImage]? = nil,
                imageForState: [UIControlState: UIImage]? = nil,
                cornerRadius: CGFloat? = nil,
                borderWidth: CGFloat? = nil,
                borderColor: UIColor? = nil,
                font: UIFont? = nil,
                shouldAddDropShadow: Bool? = false,
                clipsToBounds: Bool? = true,
                imageEdgeInsets: UIEdgeInsets? = nil) {
        
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.titleColorForState = titleColorForState
        self.backgroundImageForState = backgroundImageForState
        self.imageForState = imageForState
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.font = font
        self.shouldAddDropShadow = shouldAddDropShadow
        self.clipsToBounds = clipsToBounds
        self.imageEdgeInsets = imageEdgeInsets
    }
}

extension UIButton {
    
    @nonobjc
    public func configurePoqButton(withTitle title: String, using style: PoqButtonStyle?) {
        
        setTitle(title, for: UIControlState())
        
        configurePoqButton(style: style)
    }
    
    @nonobjc
    public func configurePoqButton(style: PoqButtonStyle?) {
        
        guard let buttonStyle = style else {
            
            Log.warning("UIButtonType not Custom. Cannot be configured as PoqButton.")
            return
        }
        
        if let backgroundColorUnwrapped = buttonStyle.backgroundColor {
            backgroundColor = backgroundColorUnwrapped
        }
        
        if let tintColorUnwrapped = buttonStyle.tintColor {
            tintColor = tintColorUnwrapped
        }
        
        if let titleColors = buttonStyle.titleColorForState {
            
            for (state, color) in titleColors {
                
                setTitleColor(color, for: state)
            }
        }
        
        if let images = buttonStyle.imageForState {
            
            for (state, image) in images {
                
                setImage(image, for: state)
            }
        }
        
        if let backgroundImages = buttonStyle.backgroundImageForState {
            
            for (state, image) in backgroundImages {
                
                setBackgroundImage(image, for: state)
            }
        }
        
        if let imageEdgeInsetsUnwrapped = buttonStyle.imageEdgeInsets {
            imageEdgeInsets = imageEdgeInsetsUnwrapped
        }
        
        if let cornerRadiusUnwrapped = buttonStyle.cornerRadius {
            layer.cornerRadius = cornerRadiusUnwrapped
        }
        
        if let borderWidthUnwrapped = buttonStyle.borderWidth {
            layer.borderWidth = borderWidthUnwrapped
        }
        
        if let borderColorUnwrapped = buttonStyle.borderColor?.cgColor {
            layer.borderColor = borderColorUnwrapped
        }
        
        if buttonStyle.shouldAddDropShadow == true {
            
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 2, height: 2)
            layer.shadowRadius = 2
            layer.shadowOpacity = 0.4
        }
        
        clipsToBounds = buttonStyle.clipsToBounds ?? false
        titleLabel?.font = buttonStyle.font
    }
}
