//
//  HorizontalLine.swift
//  Poq.iOS
//
//  Created by Jun Seki on 06/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class HorizontalLine: UIView {
    
    var imageView: UIImageView?
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        initHorizontalLine()
    }
    
    func initHorizontalLine() {
        
        imageView?.removeFromSuperview()
        imageView = UIImageView(frame: bounds)
        
        var horizontalLineImage = ImageInjectionResolver.loadImage(named: "HorizontalLine")
        
        if horizontalLineImage == nil {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawHorizontalLine(frame: bounds)
            horizontalLineImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        imageView?.image = horizontalLineImage
        
        if let imageViewUnwrapped = imageView {
            insertSubview(imageViewUnwrapped, at: 0)
        }
    }
}
