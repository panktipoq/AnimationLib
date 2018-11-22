//
//  Direction.swift
//  Poq.iOS
//
//  Created by Jun Seki on 27/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class DirectionButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initDirectionButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDirectionButton()
    }
    
    func initDirectionButton() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.directionButtonStyle)
    }

}
