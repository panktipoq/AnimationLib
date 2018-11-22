//
//  MySizeWoWomanButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 31/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class MySizeWomanButton: UIButton {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initMySizeWomanButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initMySizeWomanButton()
    }
    
    func initMySizeWomanButton() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.mySizeWomanButtonStyle)
    }

}
