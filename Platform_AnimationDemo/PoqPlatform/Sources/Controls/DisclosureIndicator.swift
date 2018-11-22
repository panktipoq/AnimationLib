//
//  DisclosureIndicator.swift
//  Poq.iOS
//
//  Created by Jun Seki on 23/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class DisclosureIndicator: UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initDisclosureIndicatorImage()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDisclosureIndicatorImage()
    }
    
    func initDisclosureIndicatorImage() {
        
        let imageView = UIImageView(frame: bounds)
        var disclosureIndicatorImage: UIImage? = ImageInjectionResolver.loadImage(named: "SmallDisclosureIndicator")
        
        if disclosureIndicatorImage == nil {
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawDisclosureIndicator(frame: bounds)
            disclosureIndicatorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        imageView.image = disclosureIndicatorImage
        addSubview(imageView)
        
    }
    
}
