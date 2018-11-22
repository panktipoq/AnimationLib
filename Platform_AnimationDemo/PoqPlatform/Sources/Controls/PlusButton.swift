//
//  PlusButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 12/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class PlusButton: UIButton {
    
    open override func awakeFromNib() {
        
        super.awakeFromNib()
        
        let plusButtonStyle = ResourceProvider.sharedInstance.clientStyle?.plusButtonStyle
        
        configurePoqButton(style: plusButtonStyle)
    }
}
