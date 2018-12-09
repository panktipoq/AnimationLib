//
//  AnimationConfiguration.swift
//  PoqPlatform
//
//  Created by Pankti Patel on 09/12/2018.
//

import Foundation

public typealias AnimClosure = (() -> Void)

public enum AnimationType {
    case sequence
    case parallel
}

public struct AnimConfig{
    
    var keyPath          : AnimatorKeyPath
    var fromValue        : Any?
    var toValue          : Any?
    var keyFrameValues   : [Any]?
    var keyTimes         : [NSNumber]?
    var duration         : TimeInterval
    var delay            : Double
    var timingFunction   : TimingFunction
    
    init(keyPath        :AnimatorKeyPath,
         fromValue      :Any,
         toValue        :Any,
         duration       :TimeInterval,
         delay          : Double = 0,
         timingFunction :TimingFunction = .default) {
        
        self.keyPath        = keyPath
        self.fromValue      = fromValue
        self.toValue        = toValue
        self.duration       = duration
        self.delay          = delay
        self.timingFunction = timingFunction
        
    }
    
    init(keyPath        :AnimatorKeyPath,
         keyFrameValues :[Any],
         keyTimes       :[NSNumber]? = nil,
         duration       :TimeInterval = 1,
         delay          : Double = 0,
         timingFunction :TimingFunction = .default) {
        
        self.keyPath        = keyPath
        self.keyFrameValues = keyFrameValues
        self.keyTimes       = keyTimes
        self.duration       = duration
        self.delay          = delay
        self.timingFunction = timingFunction
        
    }
}

