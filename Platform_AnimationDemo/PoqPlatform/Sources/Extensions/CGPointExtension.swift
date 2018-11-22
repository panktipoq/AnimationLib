//
//  CGPointExtension.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 03/08/2017.
//
//

import Foundation
import CoreGraphics

public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
