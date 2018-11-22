//
//  Tick.swift
//  Poq.iOS
//
//  Created by Jun Seki on 12/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class Tick: UIImageView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initTick()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTick()
    }
    
    func initTick() {
        var tickImage: UIImage? = ImageInjectionResolver.loadImage(named: "Tick")
        
        if tickImage == nil  {
            // Draw image with Paintcode
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawTick(frame: frame)
            tickImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        image = tickImage
    }
    

}
