//
//  MinusButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 12/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class MinusButton: UIButton {
    
    open override func awakeFromNib() {
        
        super.awakeFromNib()
        
        let minusButtonStyle = ResourceProvider.sharedInstance.clientStyle?.minusButtonStyle
        
        configurePoqButton(style: minusButtonStyle)
    }
}
