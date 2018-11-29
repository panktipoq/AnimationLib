//
//  PoqAnimator.swift
//  PoqAnimationLib
//
//  Created by Pankti Patel on 16/11/2018.
//  Copyright © 2018 Pankti Patel. All rights reserved.
//

import UIKit

// Animation Block Definition
public typealias AnimClosure = (() -> Void)

/*
This class is responsible to handle multiple animations on the view layer
 
 AnimationType:
            If the type of animation is sequence, it will calculate the beginTime for next animation based on given duration
            If the type of animation is parallel, it will combine the animation duration
 
 addBasicAnimation():
            It is responsible to add basic animation to animationGroup
        Parameters:
            keyPath         : keyPath of the animation of type AnimatorKeyPath
            from            : start value of the animation
            to              : end value of the animation
            duration        : animation duration
            delay           : delay to start aniamtion
            timingFunction  : timingfunction of the animation (Defined timingfunction in class TimingFunction
                                                                can be used or one can define its own custom function
                                                                with control points in TimingFunction class)
 
 addKeyFrameAnimation():
            It is responsible to add keyFrame animation to animationGroup
        Parameters:
                keyPath         : keyPath of the animation of type AnimatorKeyPath
                values          : An array of objects that specify the keyframe values to use for the animation.
                keyTimes        : An optional array of NSNumber objects that define the time at which to apply a given keyframe segment.
                duration        : animation duration
                delay           : delay to start aniamtion
                timingFunction  : timingfunction of the animation (Defined timingfunction in class TimingFunction
                                                                    can be used or one can define its own custom function
                                                                    with control points in TimingFunction class)
 
 startAnimation():
            It is responsible to start group animation added in animations array
        Parameters:
                layer                 : Layer on which the animation should be added
                type                  : Type of the animation, whether sequence or parallel
                isRemovedOnCompletion : When true, the animation is removed from the target layer’s animations once its
                                        active duration has passed
                completion            : Completion of the group animation
 
 stopAnimation()
            It is responsible to stop the running animations
 */

public final class PoqAnimator: NSObject {
    
    override init() {
        super.init()
    }
    
    public enum AnimationType {
        case sequence
        case parallel
        
    }
    // Initializations
    private var animationGroup : CAAnimationGroup?
    private var animations = [CAAnimation]()
    private var layer: CALayer?
    
    public func addBasicAnimation<T: AnimationValueType>(keyPath: AnimatorKeyPath<T>,
                                                 from: T,
                                                 to: T,
                                                 duration: Double,
                                                 delay: Double = 0,
                                                 timingFunction: TimingFunction = .default) -> Self {
        
        let basicAnimtion = CABasicAnimation(keyPath: keyPath.rawValue)
        basicAnimtion.fromValue = from
        basicAnimtion.toValue = to
        basicAnimtion.configure(delay: delay, duration: duration, timingfunction: timingFunction)
        animations.append(basicAnimtion)
        return self
    }
    public func addKeyFrameAnimation<T: AnimationValueType>(keyPath: AnimatorKeyPath<T>,
                                                    values: [T],
                                                    keyTimes: [NSNumber]?,
                                                    duration: Double,
                                                    delay: Double = 0,
                                                    timingFunction: TimingFunction = .default) -> Self {
        
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: keyPath.rawValue)
        keyFrameAnimation.values = values
        keyFrameAnimation.keyTimes = keyTimes
        keyFrameAnimation.configure(delay: delay,
                                    duration: duration,
                                    timingfunction: timingFunction,
                                    isRemovedOnCompletion: false)
        animations.append(keyFrameAnimation)
        return self
        
    }
    
    public func startAnimation(for layer: CALayer,
                               type: AnimationType,
                        isRemovedOnCompletion: Bool = false,
                        completion: AnimClosure? = nil) {
    
        self.layer = layer
        animationGroup = CAAnimationGroup()
        animationGroup?.duration = totalDuration(for: type)
        animationGroup?.animations = self.animations
        animationGroup?.isRemovedOnCompletion = isRemovedOnCompletion
        animationGroup?.fillMode = FillMode.forwards.rawValue
        if type == .sequence {
            calculateBeginTime()
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        if let group = animationGroup{
            layer.add(group, forKey: UUID().uuidString)
        }
        CATransaction.commit()
    }
    
    public func stopAnimation() {
        layer?.removeAllAnimations()
        animationGroup = nil
        animations = []
    }
}

extension PoqAnimator {
    
    // MARK: - Helpers
    
    // This func can be used to provide total duration of the animations in animationGroup
    func totalDuration(for type: AnimationType) -> Double {
        switch type {
        case .sequence:
            return animations.last.map { $0.beginTime + $0.duration } ?? 0
        case .parallel:
            return animations.map { $0.duration }.reduce(0, +)
        }
    }
    
    // This func can be used to provide begin time of the next animation in animationGroup
    // Used for sequnce animation type
    func calculateBeginTime() {
        for (index, anim) in animations.enumerated() where index > 0 {
            let prevAnim = animations[index-1]
            anim.beginTime += prevAnim.beginTime + prevAnim.duration
        }
    }
}
