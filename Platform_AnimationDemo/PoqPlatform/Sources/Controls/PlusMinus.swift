//
//  PlusOnShop.swift
//  Poq.iOS
//
//  Created by Jun Seki on 27/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import UIKit

open class PlusMinus: UIImageView {
    
    open var plusImage: UIImage?
    open var minusImage: UIImage?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initPlusMinus()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initPlusMinus()
    }
    
    func initPlusMinus() {
        plusImage = ImageInjectionResolver.loadImage(named: "PlusIndicator")
        
        if plusImage == nil {
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawPlusMinus(frame: bounds, rotatingDegree: 0)
            plusImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        minusImage = ImageInjectionResolver.loadImage(named: "MinusIndicator")
        
        if minusImage == nil {
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawPlusMinus(frame: bounds, rotatingDegree: -90)
            minusImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        image = plusImage
        
    }
    
    open func open() {
        image = minusImage
    }
    
    open func close() {
        image = plusImage
    }
    
}
