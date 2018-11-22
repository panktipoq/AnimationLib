//
//  UIBarButtonItemExtension.swift
//  PoqCart
//
//  Created by Balaji Reddy on 25/07/2018.
//

import UIKit

extension UIBarButtonItem {
    
    /// This method creates a UIBarButton item with a bordered button as its custom view
    ///
    /// - Parameters:
    ///   - width: The width of the button
    ///   - target: The target that repsonds to the events
    ///   - selector: The selector of the target that handles the event
    /// - Returns: The instace of the bordered UIBarButtonItem
    public static func borderedButtonItem(width: CGFloat =  50, target: Any?, selector: Selector) -> UIBarButtonItem {
        
        let borderedButton = UIButton.navBarButton
        
        borderedButton.addTarget(target, action: selector, for: .touchUpInside)
        
        let barButtonItem =  UIBarButtonItem(customView: borderedButton)
        barButtonItem.width = width
        return barButtonItem
    }
    
    public var borderedButtonItemTitle: String? {
        
        set {
            if let buttonView = self.customView as? UIButton {
                buttonView.setTitle(newValue, for: .normal)
            }
        }
        
        get {
            if let buttonView = self.customView as? UIButton {
                return buttonView.title(for: .normal)
            }
            return nil
        }
    }
}
