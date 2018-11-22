//
//  SolidLine.swift
//  Poq.iOS
//
//  Created by Jun Seki on 20/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class SolidLine: UIView {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = AppTheme.sharedInstance.solidLineColor
    }
    
    override open var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 1.0/UIScreen.main.scale)
    }
}
