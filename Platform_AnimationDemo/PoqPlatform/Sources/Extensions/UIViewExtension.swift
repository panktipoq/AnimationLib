//
//  UIViewExtension.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 5/12/16.
//
//

import Foundation
import UIKit

extension UIView {
    
    @nonobjc
    func makeItCircle() {
        layer.cornerRadius = frame.size.height/2
        layer.masksToBounds = true
    }
    
    /// Recursivly run on all subviews(until the bottom) test closure. First test will be call on itsefl, after on every subview
    /// - parameter: clousere to be executed on sbuview
    /// - returns: true, if at least one of subview or itself pass test. false if all subview failed test
    @nonobjc
    func recursivelyTest(_ test: (UIView) throws -> Bool) rethrows -> Bool {
        
        let pass = try test(self)
        if pass {
            return true
        }
        
        for view in subviews {
            let res: Bool = try view.recursivelyTest(test)
            if res {
                return true
            }
        }
        
        return false
    }
    
    /// Recursivly check all subviews and search for with needed class
    /// Returns first found or nil
    @nonobjc
    func recursivelyFind<T: UIView>() -> [T] {
        
        var res = [T]()
        if let selfT = self as? T {
            res.append(selfT)
        }

        for view in subviews {
            let subviewRes: [T] = view.recursivelyFind()
            res.append(contentsOf: subviewRes)
        }
        
        return res
    }
    
    // MARK: Constraints
    
    /// Create wisht and height constraints and activate them, return applyed constraints
    @discardableResult @nonobjc
    func applySizeConstraints(equaltTo size: CGSize) -> [NSLayoutConstraint] {
        let width = widthAnchor.constraint(equalToConstant: size.width)
        let height = heightAnchor.constraint(equalToConstant: size.height)
        
        let res = [width, height]
        NSLayoutConstraint.activate(res)
        return res
    }
    
    /// Create centerX and centerY constraints related to view
    /// - parameter view: view to be centered with. If pass nill, superview will be used
    @discardableResult @nonobjc
    func applyCenterPositionConstraints(view: UIView? = nil) -> [NSLayoutConstraint] {
        guard let targetView = view ?? superview else {
            return []
        }

        let centerX = centerXAnchor.constraint(equalTo: targetView.centerXAnchor)
        let centerY = centerYAnchor.constraint(equalTo: targetView.centerYAnchor)
        let res = [centerX, centerY]
        NSLayoutConstraint.activate(res)
        return res
    }
    
    /// Create width and height constraints equal to view sizes
    /// - parameter view: view to be centered with. If pass nill, superview will be used
    @discardableResult @nonobjc
    func applySizeConstraints(equalTo view: UIView? = nil) -> [NSLayoutConstraint] {
        guard let targetView = view ?? superview else {
            return []
        }
        
        let width = widthAnchor.constraint(equalTo: targetView.widthAnchor)
        let height = heightAnchor.constraint(equalTo: targetView.heightAnchor)
        let res = [width, height]
        NSLayoutConstraint.activate(res)
        return res
    }
    
    /// Take Screenshot of the view
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        // Get Image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
