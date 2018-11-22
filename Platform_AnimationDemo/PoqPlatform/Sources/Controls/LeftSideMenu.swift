//
//  LeftSideMenu.swift
//  Poq.iOS
//
//  Created by Jun Seki on 27/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class LeftSideMenu: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initLeftSideMenu()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLeftSideMenu()
    }
    
    func initLeftSideMenu() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.leftSideMenuStyle)
    }

}
