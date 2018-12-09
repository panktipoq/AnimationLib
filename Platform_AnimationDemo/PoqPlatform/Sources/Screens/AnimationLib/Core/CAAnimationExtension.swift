//
//  CAAnimationExtension.swift
//  PoqAnimationLib
//
//  Created by Pankti Patel on 16/11/2018.
//  Copyright © 2018 Pankti Patel. All rights reserved.
//

import QuartzCore


/*
 Configuring CAAnimation with the given paramaeters:
 Parameters:
    delay:                  delay to start the animation
    duration:               duration of the animation
    timingfunction:         timingfunction of the animation (Defined timingfunction in class TimingFunction
                                                            can be used or one can define its own custom function
                                                            with control points in TimingFunction class)
    isRemovedOnCompletion:  When true, the animation is removed from the target layer’s animations once its
                            active duration has passed
 
 */
extension CAAnimation {
    
    
    static func startAddToBagAnimation(with settings: PDPAddToBagAnimatorViewSettings,
                                       completion:@escaping AnimClosure) {
        
        let addToBagAnimatorView = PDPAddToBagAnimatorView(frame: UIScreen.main.bounds)
        guard  let window = UIApplication.shared.keyWindow else {
            fatalError("window not found")
        }
        window.addSubview(addToBagAnimatorView)
        addToBagAnimatorView.startAnimation(with: settings,
                                            completion: completion)
        
    }
    
    static func startAddToBagAnimation(with settings: WishlistAddToBagAnimatorViewSettings,
                                       completion:@escaping AnimClosure) {
        
        let addToBagAnimatorView = WishlistAddToBagAnimatorView(frame: UIScreen.main.bounds)
        guard  let window = UIApplication.shared.keyWindow else {
            fatalError("window not found")
        }
        window.addSubview(addToBagAnimatorView)
        addToBagAnimatorView.startAnimation(with: settings,
                                            completion: completion)
        
    }
    
}
extension CAAnimation{
    func configure(delay: Double, duration: Double, timingfunction: TimingFunction, isRemovedOnCompletion: Bool = false) {
        self.beginTime = delay
        self.duration = duration
        self.timingFunction = timingfunction.rawValue
        self.fillMode = FillMode.forwards.rawValue
        self.isRemovedOnCompletion = isRemovedOnCompletion
    }
    
    static func basicAnimation(for config: AnimConfig) -> CABasicAnimation{
        
        let basicAnimation = CABasicAnimation(keyPath: config.keyPath.rawValue)
        basicAnimation.fromValue = config.fromValue
        basicAnimation.toValue = config.toValue
        basicAnimation.configure(delay: config.delay,
                                 duration: config.duration,
                                 timingfunction: config.timingFunction)
        return basicAnimation
    }
    
    static func keyFrameAnimation(for config: AnimConfig) -> CAKeyframeAnimation{
        
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: config.keyPath.rawValue)
        keyFrameAnimation.values = config.keyFrameValues
        keyFrameAnimation.keyTimes = config.keyTimes
        keyFrameAnimation.configure(delay: config.delay,
                                    duration: config.duration,
                                    timingfunction: config.timingFunction)
        return keyFrameAnimation
    }
    
    static func PDPStartScaleAnimation() -> CAAnimation{
        return basicAnimation(for: AnimConfig(keyPath: .scale,
                                                        fromValue: 1,
                                                        toValue: 0.4,
                                                        duration: 0.3,
                                                        delay :0,
                                                        timingFunction : .easeInfast))
    }
    
    static func PDPEndScaleAnimation() -> CAAnimation{
        return basicAnimation(for: AnimConfig(keyPath: .scale,
                                                        fromValue: 0.4,
                                                        toValue: 0,
                                                        duration: 0.35))
    }
    
    static func PDPImageRadiusAnimation() -> CAAnimation{
        return basicAnimation(for: AnimConfig(keyPath: .radius,
                                                        fromValue: 1,
                                                        toValue: 15,
                                                        duration: 0.3,
                                                        delay :0,
                                                        timingFunction : .easeInfast))
    }
    
    static func OverlayStartOpacityAnimation() -> CAAnimation{
        return basicAnimation(for: AnimConfig(keyPath: .opacity,
                                                        fromValue: 0,
                                                        toValue: 0.3,
                                                        duration: 0.4,
                                                        delay :0,
                                                        timingFunction : .easeInfast))
    }
    
    static func OverlayEndOpacityAnimation() -> CAAnimation{
        return basicAnimation(for: AnimConfig(keyPath: .opacity,
                                                        fromValue: 0.3,
                                                        toValue: 0,
                                                        duration: 0.4,
                                                        delay :0,
                                                        timingFunction : .easeOut))
    }
    
    static func TabItemSpringAnimation() -> CAAnimation{
        return basicAnimation(for: AnimConfig(keyPath: .scale,
                                                        keyFrameValues: [1, 1.2, 0.9, 1],
                                                        duration: 0.3))
    }
    
    static func BadgeCountScaleAnimation() -> CAAnimation{
        return basicAnimation(for: AnimConfig(keyPath: .scale,
                                                        fromValue: 0,
                                                        toValue: 1,
                                                        duration: 0.5,
                                                        delay :0,
                                                        timingFunction : .easeInSlow))
    }
    
    static func WishlistCellStartScaleAnimation() -> CAAnimation{
        return basicAnimation(for: AnimConfig(keyPath: .scale,
                                                        fromValue: 1,
                                                        toValue: 1.2,
                                                        duration: 0.3))
    }
    
    static func WishlistCellEndScaleAnimation() -> CAAnimation{
        return basicAnimation(for: AnimConfig(keyPath: .scale,
                                                        fromValue: 0.5,
                                                        toValue: 0,
                                                        duration: 0.35))
    }
    
    static func WishlistCellRadiusAnimation() -> CAAnimation{
        return basicAnimation(for: AnimConfig(keyPath: .radius,
                                                        fromValue: 1,
                                                        toValue: 10,
                                                        duration: 0.3,
                                                        delay :0,
                                                        timingFunction : .easeInfast))
    }
}
