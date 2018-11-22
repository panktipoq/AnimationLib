//
//  ShareButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 23/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class ShareButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initShareButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initShareButton()
    }
    
    func initShareButton() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.pdpShareButtonStyle)
    }
    
}

