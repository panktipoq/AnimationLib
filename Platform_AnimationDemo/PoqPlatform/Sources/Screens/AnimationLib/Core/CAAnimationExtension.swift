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
    
    func configure(delay: Double, duration: Double, timingfunction: TimingFunction, isRemovedOnCompletion: Bool = false) {
        self.beginTime = delay
        self.duration = duration
        self.timingFunction = timingfunction.rawValue
        self.fillMode = FillMode.forwards.rawValue
        self.isRemovedOnCompletion = isRemovedOnCompletion
  }
}
