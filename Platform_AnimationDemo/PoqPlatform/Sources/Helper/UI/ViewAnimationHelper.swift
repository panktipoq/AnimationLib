//
//  ViewAnimationHelper.swift
//  Poq.iOS
//
//  Created by Jun Seki on 11/12/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation

public final class ViewAnimationHelper {

    public static func backgroundBlur(_ targetView: UIView) {
        
        //ios 8 only
        targetView.backgroundColor=UIColor.clear
        //adding blurring effects
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        targetView.insertSubview(blurView, at: 0)
        
        //add the contraints to the layout
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(item: targetView, attribute: .centerX, relatedBy: .equal,
            toItem: targetView, attribute: .centerX, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: targetView, attribute: .centerY, relatedBy: .equal,
            toItem: targetView, attribute: .centerY, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: blurView,
            attribute: .height, relatedBy: .equal, toItem: targetView,
            attribute: .height, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: blurView,
            attribute: .width, relatedBy: .equal, toItem: targetView,
            attribute: .width, multiplier: 1, constant: 0))
        
        
        targetView.addConstraints(constraints)
    }

}
