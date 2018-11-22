//
//  ScanFrame.swift
//  Poq.iOS
//
//  Created by Jun Seki on 07/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class ScanFrame: UIImageView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initScanFrameImage()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initScanFrameImage()
    }
    
    func initScanFrameImage() {
        
        var scanFrameImage: UIImage? = ImageInjectionResolver.loadImage(named: "ScanFrame")
        
        if scanFrameImage == nil  {
            // Draw image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawScanFrame(frame: frame)
            scanFrameImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        image = scanFrameImage
    }
    
}
