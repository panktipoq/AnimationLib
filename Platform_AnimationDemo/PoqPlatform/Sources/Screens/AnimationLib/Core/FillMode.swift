//
//  FillMode.swift
//  PoqAnimationLib
//
//  Created by Pankti Patel on 16/11/2018.
//  Copyright © 2018 Pankti Patel. All rights reserved.
//

import QuartzCore


/*
 Since swift 4.2 the new raw values introduced for CAMediaTimingFillMode
 This structure is responsible to give the backward swift compatibility
 */

public struct FillMode {
    
    #if swift(>=4.2)
    typealias RawValue = CAMediaTimingFillMode
    public static let forwards = FillMode(rawValue:.forwards)
    public static let backwards = FillMode(rawValue:.backwards)
    #else
    typealias RawValue = String
    public static let forwards = FillMode(rawValue:kCAFillModeForwards)
    public static let backwards = FillMode(rawValue:kCAFillModeBackwards)
    #endif
    let rawValue: RawValue
}
