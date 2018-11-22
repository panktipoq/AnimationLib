//
//  RightSideMenu.swift
//  Poq.iOS
//
//  Created by Jun Seki on 27/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

@objc
public protocol RightSideMenuDelegate: AnyObject {
    func rightSideMenuButtonClicked()
}

open class RightSideMenu: UIButton, BadgedControl, BarButtonItemProvider {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateButtonImages()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        updateButtonImages()
    }
    
    var theBadgeNumber: String = ""
    public var badgeNumber: String {
        get {
            return theBadgeNumber
        }
        set(badgeValue) {
            theBadgeNumber = Int(badgeValue) == 0 ? "" : badgeValue
            updateButtonImages()
        }
    }
    
    public func setBadgeNumber(_ badgeNumber: String, animated: Bool) {
        self.badgeNumber = badgeNumber
    }

    public func createBarButtonitem() -> UIBarButtonItem? {
        let barItem = UIBarButtonItem(customView: self)
        
        barItem.accessibilityIdentifier = AccessibilityLabels.navbarRightMenuItem
        barItem.accessibilityLabel = AccessibilityLabels.navbarRightMenuItem.localizedPoqString
        barItem.isAccessibilityElement = true
        barItem.accessibilityTraits = UIAccessibilityTraitButton
        
        return barItem
    }

    /// Recreate images with badge value. Should be called when button created and badge udpdated
    fileprivate func updateButtonImages() {
        
        let imageRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 44, height: 44))
        
        var rightMenuDefault: UIImage? = ImageInjectionResolver.loadImage(named: "RightMenuDefault")

        if rightMenuDefault == nil {
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawRightMenu(frame: imageRect, pressed: false, badgeNumber: badgeNumber)
            rightMenuDefault = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        setImage(rightMenuDefault, for: .normal)
        
        var rightMenuPressed: UIImage? = ImageInjectionResolver.loadImage(named: "RightMenuPressed")

        if rightMenuDefault == nil {
            UIGraphicsBeginImageContextWithOptions(SquareBurButtonRect.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawRightMenu(frame: imageRect, pressed: true, badgeNumber: badgeNumber)
            rightMenuPressed = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        setImage(rightMenuPressed, for: .highlighted)
    }
}
