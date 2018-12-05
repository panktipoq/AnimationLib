//
//  PoqAnimator.swift
//  PoqDemoApp
//
//  Created by Pankti Patel on 29/11/2018.
//

import UIKit
import Foundation
import  QuartzCore

struct AnimConfig{
    
    var keyPath          : AnimatorKeyPath
    var fromValue        : Any?
    var toValue          : Any?
    var keyFrameValues   : [Any]?
    var keyTimes         : [NSNumber]?
    var duration         : TimeInterval
    var delay            : Double
    var timingFunction   : TimingFunction
    
    init(keyPath        :AnimatorKeyPath,
         fromValue      :Any? = nil,
         toValue        :Any? = nil,
         keyFrameValues :[Any]? = nil,
         keyTimes       :[NSNumber]? = nil,
         duration       :TimeInterval,
         delay          : Double = 0,
         timingFunction :TimingFunction = .default) {
        
        self.keyPath        = keyPath
        self.fromValue      = fromValue
        self.toValue        = toValue
        self.keyFrameValues = keyFrameValues
        self.keyTimes       = keyTimes
        self.duration       = duration
        self.delay          = delay
        self.timingFunction = timingFunction
    }
}

enum AnimConfigType{
    
    case custom(config:AnimConfig)
    //common
    case OverlayStartOpacity
    case OverlayEndOpacity
    case TabItemSpring
    case TabItemCountScale
    
    // PDP
    case PDPStartScale
    case PDPEndScale
    case PDPImageRadius
    
    // Wishlist
    case WishlistCellStartScale
    case WishlistCellEndScale
    case WishlistCellRadius
    
    var configurtion:AnimConfig?{
        switch self {
        case .OverlayStartOpacity:
            return AnimConfig(keyPath: .opacity, fromValue: 0, toValue: 0.3, duration: 0.4, delay :0, timingFunction : .easeInfast)
        case .OverlayEndOpacity:
            return AnimConfig(keyPath: .opacity, fromValue: 0.3, toValue: 0, duration: 0.4, delay :0, timingFunction : .easeOut)
        case .TabItemSpring:
            return AnimConfig(keyPath: .scale, keyFrameValues: [1, 1.2, 0.9, 1], duration: 0.3)
        case .TabItemCountScale:
            return AnimConfig(keyPath: .scale, fromValue: 0, toValue: 1, duration: 0.5, delay :0, timingFunction : .easeInSlow)
        // PDP
        case .PDPStartScale:
            return AnimConfig(keyPath: .scale, fromValue: 1, toValue: 0.4, duration: 0.3, delay :0, timingFunction : .easeInfast)
        case .PDPEndScale:
            return AnimConfig(keyPath: .scale, fromValue: 0.4, toValue: 0, duration: 0.35)
        case .PDPImageRadius:
            return AnimConfig(keyPath: .radius, fromValue: 1, toValue: 15, duration: 0.3, delay :0, timingFunction : .easeInfast)
            
        // Wishlist
        case .WishlistCellStartScale:
            return AnimConfig(keyPath: .scale, fromValue: 1, toValue: 1.2, duration: 0.3)
        case .WishlistCellEndScale:
            return AnimConfig(keyPath: .scale, fromValue: 0.5, toValue: 0, duration: 0.35)
        case .WishlistCellRadius:
            return AnimConfig(keyPath: .radius, fromValue: 1, toValue: 10, duration: 0.3, delay :0, timingFunction : .easeInfast)
        case .custom(_): return nil
        }
    }
}
enum PoqAnimator1{
    
    static func fetchAnimation(for animType:AnimConfigType) -> CAAnimation{
        
        guard let config = animType.configurtion else{
            fatalError("Configuration for animation does not found")
        }
        
        let basicAnimtion = CABasicAnimation(keyPath: config.keyPath.rawValue)
        basicAnimtion.fromValue = config.fromValue
        basicAnimtion.toValue = config.toValue
        basicAnimtion.configure(delay: config.delay,
                                duration: config.duration,
                                timingfunction: config.timingFunction)
        return basicAnimtion
    }
}


extension CAAnimationGroup{
    
    public enum AnimationType {
        case sequence
        case parallel
        
    }
    func startAnimation(for view: UIView,
                        type: AnimationType,
                        animations:[CAAnimation],
                        completion: AnimClosure? = nil){
        
        self.duration = totalDuration(for: type)
        self.animations = animations
        self.isRemovedOnCompletion = false
        self.fillMode = FillMode.forwards.rawValue
        if type == .sequence {
            calculateBeginTime()
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        view.layer.add(self, forKey: UUID().uuidString)
        CATransaction.commit()
    }
    
    // MARK: - Helpers
    
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

//Testing
class AnimateView{
    
    func animate(){
        let view = UIView()
        let boundsConfig = AnimConfig(keyPath: .boundsSize, fromValue: view.frame.size.width, toValue: 0, keyFrameValues: nil, keyTimes: nil, duration: 0.3)
        let boundsAnim = PoqAnimator1.fetchAnimation(for: .custom(config: boundsConfig))
        let scaleAnim = PoqAnimator1.fetchAnimation(for: .PDPStartScale)
        let radiusAnim = PoqAnimator1.fetchAnimation(for: .WishlistCellRadius)
        let group = CAAnimationGroup()
        group.startAnimation(for: view, type: .sequence, animations: [boundsAnim, scaleAnim, radiusAnim]){
            
        }
    }
}
