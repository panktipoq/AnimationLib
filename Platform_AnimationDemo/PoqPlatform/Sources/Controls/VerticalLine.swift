//
//  VerticalLine.swift for PLP
//  Poq.iOS
//
//  Created by Jun Seki on 06/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class VerticalLine: UIView {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initVerticalLine()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initVerticalLine()
    }
    
    func initVerticalLine() {
        let imageView = UIImageView(frame: bounds)
        var verticalLineImage = ImageInjectionResolver.loadImage(named: "VerticalLine")
        
        if verticalLineImage == nil {
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawVerticalLine(frame: bounds)
            verticalLineImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        imageView.image = verticalLineImage
        
        addSubview(imageView)
    }

}
