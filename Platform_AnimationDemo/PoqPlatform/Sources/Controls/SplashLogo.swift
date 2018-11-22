//
//  SplashLogo.swift
//  Poq.iOS
//
//  Created by Jun Seki on 23/07/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation

open class SplashLogo: UIImageView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initSplashLogoImage()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSplashLogoImage()
    }
    
    func initSplashLogoImage() {
        var splashLogoImage: UIImage? = ImageInjectionResolver.loadImage(named: "SplashLogo")
        
        if splashLogoImage == nil  {
            // Draw image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawSplashLogo(frame: frame)
            splashLogoImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        image = splashLogoImage
    }
    
}
