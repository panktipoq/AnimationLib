//
//  BackHelper.swift
//  Poq.iOS
//
//  Created by Jun Seki on 06/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

public enum BarButtonType: String {
    
    case Default
    case Bordered
    
    static var currentLeftType: BarButtonType {
        guard let style = BarButtonType(rawValue: AppSettings.sharedInstance.navigationLeftButtonType) else {
            return .Default
        }
        
        return style
    }
    
    static var currentRightType: BarButtonType {
        guard let style = BarButtonType(rawValue: AppSettings.sharedInstance.navigationRightButtonType) else {
            return .Default
        }
        
        return style
    }
    
    public static func type(forPosition position: BarButtonPosition) -> BarButtonType {
        switch position {
        case .left:
            return currentLeftType
        case .right:
            return currentRightType
        }
    }
    
    public static func font(forPosition position: BarButtonPosition) -> UIFont {
        switch position {
        case .left:
            return AppTheme.sharedInstance.naviBarItemFont
        case .right:
            return AppTheme.sharedInstance.naviBarLeftItemFont
        }
    }
    
    public static func color(forPosition position: BarButtonPosition, state: UIControlState) -> UIColor {
        switch position {
        case .left:
            switch state {
            case UIControlState.disabled:
                return AppTheme.sharedInstance.naviBarLeftItemDisabledColor
            case UIControlState.selected:
                return AppTheme.sharedInstance.naviBarLeftItemPressedColor
            default:
                return AppTheme.sharedInstance.naviBarLeftItemColor
            }
        case .right:
            switch state {
            case UIControlState.disabled:
                return AppTheme.sharedInstance.naviBarItemDisabledColor
            case UIControlState.selected:
                return AppTheme.sharedInstance.naviBarItemPressedColor
            default:
                return AppTheme.sharedInstance.naviBarItemColor
            }
        }
    }
}

public enum BarButtonPosition {
    case left
    case right
}

private let defaultBarButtonDimensionSize: CGFloat = 44.0
public let SquareBurButtonRect = CGRect(x: 0.0, y: 0.0, width: defaultBarButtonDimensionSize, height: defaultBarButtonDimensionSize)

private let titleEdgePadding: CGFloat = 130.0

open class NavigationBarHelper {
    
    /// Create back button with proper app style
    public static func setupBackButton(_ delegate: BackButtonDelegate) -> UIBarButtonItem {
        
        let leftView = BackButton(frame: SquareBurButtonRect)
        leftView.delegate = delegate
        
        leftView.accessibilityIdentifier = AccessibilityLabels.backButton
        leftView.accessibilityLabel = AccessibilityLabels.backButton.localizedPoqString
        leftView.isAccessibilityElement = true
        leftView.accessibilityTraits = UIAccessibilityTraitButton
        
        return setupButton(leftView)
    }
    
    public static func setupCloseButtonWithCircleBackground() -> RoundedCloseButton {
        
        // Close Button with Circle Background
        let closeButtonWithCircleX: CGFloat = 8.0
        let closeButtonWithCircleY: CGFloat = 20.0

        let closeButton = RoundedCloseButton(frame: CGRect(x: closeButtonWithCircleX, y: closeButtonWithCircleY, width: defaultBarButtonDimensionSize, height: defaultBarButtonDimensionSize))
        
        return closeButton
    }
    
    public static func setupCloseButton(_ delegate: CloseButtonDelegate, isWhite: Bool = false) -> UIBarButtonItem {
        
        let leftView = CloseButton(frame: SquareBurButtonRect)
        leftView.isWhite = isWhite
        leftView.addTarget(delegate, action: #selector(delegate.closeButtonClicked), for: .touchUpInside)
        
        return setupButton(leftView)
    }
    
    public static func setupButton(_ buttonView: UIView) -> UIBarButtonItem {
        
        buttonView.layoutIfNeeded()
        buttonView.backgroundColor = UIColor.clear
        
        return UIBarButtonItem(customView: buttonView)
    }
    
    /**
     Create right button, with respect to current settings and theme
     - parameter withTitle: title of button itme
     - parameter target: target of action
     - parameter action: action which will be triggered when button pressed
     */
    
    public static func createButtonItem(withTitle title: String, target: AnyObject, action: Selector, position: BarButtonPosition = .right, width: CGFloat? = nil) -> UIBarButtonItem {
        
        let resItem: UIBarButtonItem
        switch BarButtonType.type(forPosition: position) {
        case .Default:
            resItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: target, action: action)
            
            let buttonFont: UIFont = AppTheme.sharedInstance.naviBarItemFont

            let states: [UIControlState] = [.disabled, .normal, .highlighted]

            for state: UIControlState in states {
                let buttonAttr = [NSAttributedStringKey.font: buttonFont, NSAttributedStringKey.foregroundColor: BarButtonType.color(forPosition: position, state: state)]
                resItem.setTitleTextAttributes(buttonAttr, for: state)
            }
            
        case .Bordered:
            resItem = BorderedButton.createButtonItem(withTitle: title, target: target, action: action, width: width)
        }
        
        return resItem
    }
    
    public static func setUpUIBarButton(_ title: String, targetName: AnyObject?, actionName: Selector) -> UIBarButtonItem {
        
        let barButtonItem = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.plain, target: targetName, action: actionName)
        let naviBarItemFontDict = [NSAttributedStringKey.font: AppTheme.sharedInstance.naviBarItemFont, NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.naviBarItemColor] 
        barButtonItem.setTitleTextAttributes(naviBarItemFontDict, for: UIControlState())
        let naviBarItemPressedDict = [NSAttributedStringKey.font: AppTheme.sharedInstance.naviBarItemFont, NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.naviBarItemPressedColor]
        barButtonItem.setTitleTextAttributes(naviBarItemPressedDict, for: .selected)
        
        return barButtonItem
    }
    
    public static func setupTopRightBarButton(_ type: UIBarButtonSystemItem, targetName: AnyObject?, actionName: Selector) -> UIBarButtonItem {
        
        let systemButton = UIBarButtonItem(barButtonSystemItem: type, target: targetName, action: actionName)
        systemButton.tintColor = UIColor.black
        
        return systemButton
    }
    
    public static func checkAvailability(_ controller: UIViewController, tabbarItem: TabbarItem) {
        
        // If the requested tabbar item is set
        let isInTabbar = tabbarItem.rawValue == AppSettings.sharedInstance.tab1 ||
                         tabbarItem.rawValue == AppSettings.sharedInstance.tab2 ||
                         tabbarItem.rawValue == AppSettings.sharedInstance.tab3 ||
                         tabbarItem.rawValue == AppSettings.sharedInstance.tab4 ||
                         tabbarItem.rawValue == AppSettings.sharedInstance.tab5
        
        // If the controller is implementing the delegate
        if let delegate = controller as? BackButtonDelegate, !isInTabbar {
            
            controller.navigationItem.leftBarButtonItem = setupBackButton(delegate)
        } else {
            
            controller.navigationItem.leftBarButtonItem = nil
        }
    }
    
    public static func setupMultilineTitleView(_ title: String,
                                               titleFont: UIFont = AppTheme.sharedInstance.naviBarTitleFont,
                                               titleColor: UIColor = AppTheme.sharedInstance.naviBarTitleColor) -> UIView {
        
        let screenWidth = UIScreen.main.bounds.width
        
        let titleView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth - titleEdgePadding, height: defaultBarButtonDimensionSize))
        
        let textTitleView = NavigationBarHelper.setupTitleView(title, titleFont: titleFont, titleColor: titleColor)
        textTitleView.frame = titleView.frame
        titleView.addSubview(textTitleView)
        
        return titleView
    }
    
    public static func setupTruncatedTitleView(_ title: String,
                                               titleFont: UIFont = AppTheme.sharedInstance.naviBarTitleFont,
                                               titleColor: UIColor = AppTheme.sharedInstance.naviBarTitleColor) -> UIView {
        
        let screenWidth = UIScreen.main.bounds.width
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = titleFont
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.textColor = titleColor
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = title
        titleLabel.setTruncatedText(title, forWidth: screenWidth - titleEdgePadding)
        titleLabel.numberOfLines = 1

        return titleLabel
    }
    
    public static func setupTitleView(_ title: String,
                                      titleFont: UIFont = AppTheme.sharedInstance.naviBarTitleFont,
                                      titleColor: UIColor = AppTheme.sharedInstance.naviBarTitleColor,
                                      numberOfLines: Int = 0) -> UILabel {
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = titleFont
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = titleColor
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.layoutIfNeeded()
        titleLabel.sizeToFit()
        titleLabel.numberOfLines = numberOfLines
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return titleLabel
    }
}

extension UINavigationBar {
    
    public func setBackgroundImage(toColor color: UIColor, for barMetrics: UIBarMetrics = .default) {
        let image = UIImage.getImageWithColor(color, size: CGSize(width: 1, height: 1))
        setBackgroundImage(image, for: barMetrics)
    }
    
    public func setShadowImage(toColor color: UIColor) {
        let image = UIImage.getImageWithColor(color, size: CGSize(width: 1, height: 0.5))
        shadowImage = image
    }
    
    public func resetImages() {
        setBackgroundImage(nil, for: .default)
        shadowImage = nil
    }
}
