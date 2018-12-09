//
//  AnimationKeyPaths.swift
//  PoqAnimationLib
//
//  Created by Pankti Patel on 16/11/2018.
//  Copyright © 2018 Pankti Patel. All rights reserved.
//

import Foundation
import UIKit

/*
 AnimatorKeyPath returns the keypath of the animation
 NOTE: Value type defined for AnimatorKeyPath should confirm to AnimationValueType
 for e.g if Using backgroundColor as keyPath, CGColor should confirm to AnimationValueType
 Parameters :
    ValueType : This is the type of the animation values, it can be used to restrict specific value type for keypath.
                for e.g When backgroundColor keyPath is used, the from and to animation values has to be CGColor type only
 */


public struct AnimatorKeyPath {
    let rawValue: String
    init(keyPath: String) {
        rawValue = keyPath
    }
}

extension AnimatorKeyPath {
    public static let opacity = AnimatorKeyPath(keyPath: #keyPath(CALayer.opacity))
    public static let radius = AnimatorKeyPath(keyPath: #keyPath(CALayer.cornerRadius))
    public static let position = AnimatorKeyPath(keyPath: #keyPath(CALayer.position))
    public static let backgroundColor = AnimatorKeyPath(keyPath: #keyPath(CALayer.backgroundColor))
    public static let transform = AnimatorKeyPath(keyPath: #keyPath(CALayer.transform))
}

extension AnimatorKeyPath {
    public static let positionX = AnimatorKeyPath(keyPath: "\(#keyPath(CALayer.position)).x")
    public static let positionY = AnimatorKeyPath(keyPath: "\(#keyPath(CALayer.position)).y")
}

extension AnimatorKeyPath {
    public static let boundsOrigin     = AnimatorKeyPath(keyPath: "\(#keyPath(CALayer.bounds)).origin")
    public static let boundsOriginX    = AnimatorKeyPath(keyPath: "\(#keyPath(CALayer.bounds)).origin.x")
    public static let boundsOriginY    = AnimatorKeyPath(keyPath: "\(#keyPath(CALayer.bounds)).origin.y")
    public static let boundsSize       = AnimatorKeyPath(keyPath: "\(#keyPath(CALayer.bounds)).size")
    public static let boundsSizeWidth  = AnimatorKeyPath(keyPath: "\(#keyPath(CALayer.bounds)).size.width")
    public static let boundsSizeHeight = AnimatorKeyPath(keyPath: "\(#keyPath(CALayer.bounds)).size.height")
}

extension AnimatorKeyPath {
    public static let scale  = AnimatorKeyPath(keyPath: "\(#keyPath(CALayer.transform)).scale")
    public static let scaleX = AnimatorKeyPath(keyPath: "\(#keyPath(CALayer.transform)).scale.x")
    public static let scaleY = AnimatorKeyPath(keyPath: "\(#keyPath(CALayer.transform)).scale.y")
    public static let scaleZ = AnimatorKeyPath(keyPath: "\(#keyPath(CALayer.transform)).scale.z")
}
