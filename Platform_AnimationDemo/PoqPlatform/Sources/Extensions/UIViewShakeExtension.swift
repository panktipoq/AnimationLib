//
//  UIViewShakeExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/19/16.
//
//

import Foundation

protocol Shakable {
    func shake()
}

extension UIView: Shakable {
    
    @nonobjc
    public func shake() {
        
        let shift: CGFloat = 20
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 1
        //animation.keyTimes = [0, 0.125, 0.250, 0.365, 0.5, 0.625, ]
        animation.values = [0, -shift, shift, -0.75 * shift, 0.75 * shift, -0.3 * shift, 0.3 * shift, -0.15 * shift, 0.0]
        layer.add(animation, forKey: "shake")
        
    }
}
