//
//  UIButtonExtension.swift
//  PoqCart
//
//  Created by Balaji Reddy on 25/07/2018.
//

import UIKit

extension UIButton {
    
    /// This method returns an instance of bordered UIButton with rounded corners that can be used as the customView of a UIBarButtonItem
    public static var navBarButton: UIButton {
        
        // We need to provide appropriate width and height for iOS 10. CGRect.zero will do for iOS 11
        let navBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 35))
        navBarButton.navBarButtonStyle()
        
        return navBarButton
    }
    
    /// This method styles the button to be a bordered button with rounded corners
    ///
    /// - Returns: The instance of the button
    @discardableResult
    public func navBarButtonStyle() -> Self {
        
        // TODO: Move to App Styling once implemented
        titleLabel?.font = UIFont(name: "HelveticaNeue", size: 12)
        tintColor = UIColor.gray
        setTitleColor(UIColor.gray, for: .disabled)
        setTitleColor(UIColor.gray, for: .selected)
        setTitleColor(UIColor.black, for: .normal)
        
        roundedStyle()
        
        borderedStyle()
    
        return paddedTitleStyle()
    }
    
    /// This method styles the button such that there is padidng before and after the button title
    ///
    /// - Returns: The instance of the button
    @discardableResult
    public func paddedTitleStyle() -> Self {
        
        titleLabel?.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10)
        titleLabel?.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        
        titleLabel?.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return self
    }
}

extension UIView {
    
    /// This method styles the view such that the corners are rounded
    ///
    /// - Returns: The instance of the view
    @discardableResult
    public func roundedStyle() -> Self {
        
        layer.cornerRadius = 4.0
        return self
    }
    
    /// This method styles the button such that the view is bordered
    ///
    /// - Returns: The instance of the view
    @discardableResult
    public func borderedStyle() -> Self {
        
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5
        
        return self
    }
    
    /// This method styles the button such that it relies on the autoResizeMask for layout
    ///
    /// - Returns: The instance of the view
    @discardableResult
    public func autoresizeMaskStyle() -> Self {
        
        translatesAutoresizingMaskIntoConstraints = true
        return self
    }
}
