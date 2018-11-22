//
//  UICollectionViewCellExtension.swift
//  Poq.iOS.Belk
//
//  Created by Manuel Marcos Regalado on 04/03/2017.
//
//

import Foundation

/*
 This extension will return true/false depending on if any of its
 textfield is currently being the first responder
 */

extension UICollectionViewCell {
    
    @nonobjc
    public func containtFirstResponderTextField() -> Bool {
        return recursivelyTest({
            if let textField = $0 as? UITextField {
                return textField.isFirstResponder
            }
            return false
        })
    }
}
