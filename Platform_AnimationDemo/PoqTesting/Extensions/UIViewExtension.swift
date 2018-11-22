//
//  UIViewExtension.swift
//  PoqTesting
//
//  Created by Nikolay Dzhulay on 8/30/17.
//

import UIKit
import XCTest
@testable import PoqPlatform

extension UIView {
    
    /// Returns the desired view, if it exists, from within the current window's view heirarchy.
    /// - parameter identifier: The desired view's accessibility identifier.
    /// - returns: The found view or nil if it does not exist.
    static func view(withIdentifier identifier: String) -> UIView? {
        guard let window = UIApplication.shared.delegate?.window ?? nil else {
            XCTFail("Window is required for any iOS app")
            return nil
        }
        
        return window.view(withIdentifier: identifier)
    }
    
    /// Returns the desired view, if it exists, from within this view's heirarchy.
    /// - parameter identifier: The desired view's accessibility identifier.
    /// - returns: The found view or nil if it does not exist.
    func view(withIdentifier identifier: String) -> UIView? {
        if accessibilityIdentifier == identifier {
            return self
        }
        
        for subview in subviews {
            if let foundView = subview.view(withIdentifier: identifier) {
                return foundView
            }
        }
        
        return nil
    }
}

