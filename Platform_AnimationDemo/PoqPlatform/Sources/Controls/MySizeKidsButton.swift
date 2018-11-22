//
//  MySizeKidButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 31/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class MySizeKidsButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initMySizeKidsButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initMySizeKidsButton()
    }
    
    func initMySizeKidsButton() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.mySizeKidsButtonStyle)
    }
    

}
