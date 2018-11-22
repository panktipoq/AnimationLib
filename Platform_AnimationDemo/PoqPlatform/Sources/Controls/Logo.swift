//
//  Logo.swift
//  Poq.iOS
//
//  Created by Jun Seki on 28/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqUtilities
import UIKit

open class Logo: UIView {
    
    override open func draw(_ rect: CGRect) {
        // Drawing code
        ResourceProvider.sharedInstance.homePageStyle?.drawLogo(frame: rect)
    }


}
