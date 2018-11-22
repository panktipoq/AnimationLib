//
//  UITableViewCellExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/20/16.
//
//

import Foundation

extension UITableViewCell {
    
    /// this functionality ased alot across many screens. We will send indent to separator, enough to remove it from screen
    @nonobjc
    public func hideNativeSeparator() {
        separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.size.width, bottom: 0, right: 0)
    }
    
    /// Create accessory view of POQ style, according to design guidline
    @objc
    open func createAccessoryView() {
        
        //Use custom view for the indicator
        accessoryType = UITableViewCellAccessoryType.none
        accessoryView = DisclosureIndicator(frame:CGRect(x: 0, y: 0, width: 11, height: 19))
        accessoryView?.backgroundColor = UIColor.clear
    }
    
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
