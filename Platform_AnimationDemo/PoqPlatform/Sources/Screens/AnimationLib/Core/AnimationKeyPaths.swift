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
 
 AnimationKeyPaths is responsible to create custom AnimatorKeyPath
 NOTE: value type defined for AnimatorKeyPath should confirm to AnimationValueType
 */
open class AnimationKeyPaths {
    fileprivate init() {}
}

/*
 
 AnimationValueType specifies the value type of the AnimatorKeyPath
 */

public protocol AnimationValueType {}


/*
 
 AnimatorKeyPath returns the keypath of the animation
 NOTE: Value type defined for AnimatorKeyPath should confirm to AnimationValueType
 for e.g if Using backgroundColor as keyPath, CGColor should confirm to AnimationValueType
 Parameters :
    ValueType : This is the type of the animation values, it can be used to restrict specific value type for keypath.
                for e.g When backgroundColor keyPath is used, the from and to animation values has to be CGColor type only
 */
public final class AnimatorKeyPath<ValueType: AnimationValueType> : AnimationKeyPaths {
    let rawValue: String
    init(keyPath: String) {
        rawValue = keyPath
    }
}

extension Array: AnimationValueType {}
extension Dictionary: AnimationValueType {}
extension Bool: AnimationValueType {}
extension CGPoint: AnimationValueType {}
extension CGSize: AnimationValueType {}
extension CGColor: AnimationValueType {}
extension CGFloat: AnimationValueType {}
extension CATransform3D: AnimationValueType {}
extension Int: AnimationValueType {}
extension Double: AnimationValueType {}

extension AnimationKeyPaths {
    public static let opacity = AnimatorKeyPath<CGFloat>(keyPath: #keyPath(CALayer.opacity))
    public static let radius = AnimatorKeyPath<CGFloat>(keyPath: #keyPath(CALayer.cornerRadius))
    public static let position = AnimatorKeyPath<CGPoint>(keyPath: #keyPath(CALayer.position))
    public static let backgroundColor = AnimatorKeyPath<CGColor>(keyPath: #keyPath(CALayer.backgroundColor))
    public static let transform = AnimatorKeyPath<CATransform3D>(keyPath: #keyPath(CALayer.transform))
}

extension AnimationKeyPaths {
    public static let positionX = AnimatorKeyPath<CGFloat>(keyPath: "\(#keyPath(CALayer.position)).x")
    public static let positionY = AnimatorKeyPath<CGFloat>(keyPath: "\(#keyPath(CALayer.position)).y")
}

extension AnimationKeyPaths {
    public static let boundsOrigin     = AnimatorKeyPath<CGPoint>(keyPath: "\(#keyPath(CALayer.bounds)).origin")
    public static let boundsOriginX    = AnimatorKeyPath<CGFloat>(keyPath: "\(#keyPath(CALayer.bounds)).origin.x")
    public static let boundsOriginY    = AnimatorKeyPath<CGFloat>(keyPath: "\(#keyPath(CALayer.bounds)).origin.y")
    public static let boundsSize       = AnimatorKeyPath<CGSize>(keyPath: "\(#keyPath(CALayer.bounds)).size")
    public static let boundsSizeWidth  = AnimatorKeyPath<CGFloat>(keyPath: "\(#keyPath(CALayer.bounds)).size.width")
    public static let boundsSizeHeight = AnimatorKeyPath<CGFloat>(keyPath: "\(#keyPath(CALayer.bounds)).size.height")
}

extension AnimationKeyPaths {
    public static let scale  = AnimatorKeyPath<CGFloat>(keyPath: "\(#keyPath(CALayer.transform)).scale")
    public static let scaleX = AnimatorKeyPath<CGFloat>(keyPath: "\(#keyPath(CALayer.transform)).scale.x")
    public static let scaleY = AnimatorKeyPath<CGFloat>(keyPath: "\(#keyPath(CALayer.transform)).scale.y")
    public static let scaleZ = AnimatorKeyPath<CGFloat>(keyPath: "\(#keyPath(CALayer.transform)).scale.z")
}
