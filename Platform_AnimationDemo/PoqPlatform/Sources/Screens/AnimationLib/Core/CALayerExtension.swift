//
//  CALayerExtension.swift
//  PoqPlatform
//
//  Created by Pankti Patel on 09/12/2018.
//

import Foundation

extension CALayer{
    
    func runAnimations(for type: AnimationType,
                       animations:[CAAnimation],
                       completion: AnimClosure? = nil)
    {
        let group = CAAnimationGroup()
        group.duration = group.totalDuration(for: type)
        group.animations = animations
        group.isRemovedOnCompletion = false
        self.fillMode = FillMode.forwards.rawValue
        if type == .sequence {
            group.calculateBeginTime()
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.add(group, forKey: UUID().uuidString)
        CATransaction.commit()
    }
    
    func runAnimation(_ animation:CAAnimation,
                      completion: AnimClosure? = nil){
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.add(animation, forKey: UUID().uuidString)
        CATransaction.commit()
    }
}
