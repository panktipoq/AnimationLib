//
//  TextViewHelper.swift
//  Poq.iOS.Platform
//
//  Created by Manuel Marcos Regalado on 01/03/2017.
//
//

import Foundation

/*
 This extension will add a tappable web link to a given portion of the whole text
 */

public extension UITextView {
    
    @nonobjc
    public func addWebLink(linkUrl url: String, forText: String, withColor: UIColor = UIColor.black, withFont: UIFont? = nil) {
        
        // In order to add a link, the TextView must be selectable a non editable
        isSelectable = true
        isEditable = false
        // Add attributed text and link to terms and conditions
        let mutableString = NSMutableAttributedString(string: self.text)
        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.link: url,
            NSAttributedStringKey.foregroundColor: withColor
            ]
        let range = NSString(string: text).range(of: forText)
        mutableString.addAttributes(attributes, range: range)
        if let withFontUnwraped = withFont {
            mutableString.addAttribute(NSAttributedStringKey.font, value: withFontUnwraped, range: range)
        }
        attributedText = mutableString
    }
}
