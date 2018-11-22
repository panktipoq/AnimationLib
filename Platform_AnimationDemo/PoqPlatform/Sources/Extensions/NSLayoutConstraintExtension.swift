//
//  NSLayoutConstraintExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 08/02/2016.
//
//

import UIKit

public extension NSLayoutConstraint {
    
    @nonobjc
    public class func constraintsForView(_ view: UIView, withInsetsInContainer: UIEdgeInsets) -> [NSLayoutConstraint] {
        
        let views: [String : AnyObject] = ["view": view]
        let metrics: [String : AnyObject] = ["letf": withInsetsInContainer.left as AnyObject,
                                             "top": withInsetsInContainer.top as AnyObject,
                                             "right": withInsetsInContainer.right as AnyObject,
                                             "bottom": withInsetsInContainer.bottom as AnyObject]
        var horConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(letf)-[view]-(right)-|",
            options: NSLayoutFormatOptions.alignAllLeft,
            metrics: metrics,
            views: views)

        let verConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[view]-(bottom)-|",
            options: NSLayoutFormatOptions.alignAllLeft,
            metrics: metrics,
            views: views)
        
        horConstraints.append(contentsOf: verConstraints)
        
        return horConstraints
    }
}

