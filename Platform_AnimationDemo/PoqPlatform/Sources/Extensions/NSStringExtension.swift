//  NSStringExtension.swift
//  Poq.iOS
//
//  Created by Nikolay on 30/09/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation

public extension NSString {
    
    /**
     Calculate the size of a string depending on its font, text and container size.
     
     - Parameter font: The font of the string text.
     - Parameter boundingRectSize: The size of the rectangle where the text should fit.
     
     - Returns: The size of the text.
     */
    @nonobjc
    public func sizeForText(font: UIFont, boundingRectSize: CGSize) -> CGSize {
        
        let textRect = boundingRect(with: boundingRectSize,
                                            options: [
                                                NSStringDrawingOptions.usesLineFragmentOrigin,
                                                NSStringDrawingOptions.usesFontLeading],
                                            attributes: [NSAttributedStringKey.font: font],
                                            context: nil)
        
        return textRect.size
    }
    
    @nonobjc
    public func stringFromNSString() -> String {
        return String(describing: self)
    }
}
