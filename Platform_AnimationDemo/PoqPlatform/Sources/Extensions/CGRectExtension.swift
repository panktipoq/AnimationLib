//
//  CGRectExtension.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 03/08/2017.
//
//

import Foundation
import CoreGraphics

extension CGRect {
    /// Calculate distance from point to rect border
    /// Return 0 if point in rect or on border
    func distance(to point: CGPoint) -> CGFloat {
    
        // There 9 option, where points might be
        
        //  1  |   2   |   3
        //_____|_______|______
        //     |       |
        //  4  |   5   |   6
        //_____|_______|______
        //     |       |
        //  7  |   8   |   9
    
        // To find distance in any of them. We need find distance to 2 closes edges: vertical nad horizontal
        // If point in 2 or 8, distance to vertical edges 0, for example.
        
        let verticalDistance: CGFloat
        if point.y < minY {
            verticalDistance = minY - point.y
        } else if point.y > maxY {
            verticalDistance = point.y - maxY
        } else {
            verticalDistance = 0
        }
        
        let horizontalDistance: CGFloat
        if point.x < minX {
            horizontalDistance = minX - point.x
        } else if point.x > maxX {
            horizontalDistance = point.x - maxX
        } else {
            horizontalDistance = 0
        }

        return sqrt(horizontalDistance * horizontalDistance + verticalDistance * verticalDistance)
    }
    
    /// Shift every edge inside of rect on specific inset
    /// Might be usefull to get area inside bounds with particular margins
    func insetRect(with insets: UIEdgeInsets) -> CGRect {
        return CGRect(x: origin.x + insets.left,
                      y: origin.y + insets.top,
                      width: size.width - insets.left - insets.right,
                      height: size.height - insets.top - insets.bottom)
    }
}
