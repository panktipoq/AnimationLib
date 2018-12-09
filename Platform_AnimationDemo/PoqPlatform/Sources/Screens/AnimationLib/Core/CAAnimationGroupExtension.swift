//
//  CAAnimationGroupExtension.swift
//  PoqPlatform
//
//  Created by Pankti Patel on 09/12/2018.
//

import Foundation

extension CAAnimationGroup{
    
    // This func can be used to provide total duration of the animations in animationGroup
    func totalDuration(for type: AnimationType) -> Double {
        switch type {
        case .sequence:
            return self.animations?.last.map { $0.beginTime + $0.duration } ?? 0
        case .parallel:
            return self.animations?.map { $0.duration }.reduce(0, +) ?? 0
        }
    }
    
    // This func can be used to provide begin time of the next animation in animationGroup
    // Used for sequnce animation type
    func calculateBeginTime() {
        if let animations = self.animations{
            for (index, anim) in animations.enumerated() where index > 0 {
                let prevAnim = animations[index-1]
                anim.beginTime += prevAnim.beginTime + prevAnim.duration
            }
        }
    }
}
