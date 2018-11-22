//
//  MySizeManButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 31/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class MySizeManButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initMySizeManButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initMySizeManButton()
    }
    
    func initMySizeManButton() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.mySizeManButtonStyle)
    }
    
}
