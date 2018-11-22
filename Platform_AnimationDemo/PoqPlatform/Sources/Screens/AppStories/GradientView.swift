//
//  GradientView.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 8/25/17.
//
//

import Foundation
import QuartzCore
import UIKit

public final class GradientView: UIView {
    
    public var gradientLayer: CAGradientLayer? {
        return layer as? CAGradientLayer
    }
    
    
    public var locations: [Double]? {
        didSet {
            let numbers = locations?.map( { return NSNumber(value: $0) } )
            gradientLayer?.locations = numbers
        }
    }
    
    public var colors = [UIColor]() {
        didSet {
            let cgColors = colors.map( { $0.cgColor } )
            gradientLayer?.colors = cgColors
        }
    }

    public override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }
    
}

