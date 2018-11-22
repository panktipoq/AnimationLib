//
//  TimingFunction.swift
//  PoqAnimationLib
//
//  Created by Pankti Patel on 16/11/2018.
//  Copyright © 2018 Pankti Patel. All rights reserved.
//

import QuartzCore


/*
 This class is responsible to provide some predefine TimingFunctions using given control points
 Also it gives support to swift version < 4.2
 
*/

public struct TimingFunction {
    
    #if swift(>=4.2)
    public typealias  NameValue = CAMediaTimingFunctionName
    public static let `default` = TimingFunction(name: .default)
    public static let linear = TimingFunction(name: .linear)
    public static let easeIn = TimingFunction(name: .easeIn)
    public static let easeOut = TimingFunction(name: .easeOut)
    public static let easeInOut = TimingFunction(name: .easeInEaseOut)
    #else
    public typealias  NameValue = String
    public static let `default` = TimingFunction(name: kCAMediaTimingFunctionDefault)
    public static let linear = TimingFunction(name: kCAMediaTimingFunctionLinear)
    public static let easeIn = TimingFunction(name: kCAMediaTimingFunctionEaseIn)
    public static let easeOut = TimingFunction(name: kCAMediaTimingFunctionEaseOut)
    public static let easeInOut = TimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    #endif

    public let name: NameValue
    public let rawValue: CAMediaTimingFunction
    
     init(name: NameValue) {
        self.name = name
        self.rawValue = CAMediaTimingFunction(name: name)
    }
     init(name: NameValue, rawValue: CAMediaTimingFunction) {
        self.name = name
        self.rawValue = rawValue
    }
    public init(name: NameValue, controlPoints c1x: Float, _ c1y: Float, _ c2x: Float, _ c2y: Float) {
        self.name = name
        self.rawValue = CAMediaTimingFunction(controlPoints: c1x, c1y, c2x, c2y)
    }

}

extension TimingFunction {
    
    static let easeInfast =  TimingFunction(name: TimingFunction.NameValue("easeInfast"), controlPoints: 0.5, 0.9, 0.7, 1)
    static let easeInSlow =  TimingFunction(name: TimingFunction.NameValue("easeInSlow"), controlPoints: 0.25, 0.1, 0.25, 0.1)
    static let easeInNormalfast =  TimingFunction(name: TimingFunction.NameValue("easeInNormalfast"), controlPoints: 0.7, 0.8, 0.7, 1)
}
