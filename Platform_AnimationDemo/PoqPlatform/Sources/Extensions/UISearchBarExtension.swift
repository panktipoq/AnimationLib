//
//  UISearchBarExtension.swift
//  Poq.iOS
//
//  Created by Nikolay on 28/09/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import UIKit

extension UISearchBar {
    
    @nonobjc
    public func obligatoryText() -> String {
        return text ?? ""
    }
    
    @nonobjc
    public var underlyingTextField: UITextField? {
        func findTextField(within view: UIView) -> UITextField? {
            for subview in view.subviews {
                if let textField = subview as? UITextField ?? findTextField(within: subview) {
                    return textField
                }
            }
            
            return nil
        }
        
        return findTextField(within: self)
    }
}
