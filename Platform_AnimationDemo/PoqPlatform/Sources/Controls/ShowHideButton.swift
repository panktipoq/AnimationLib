//
//  ShowHideButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 24/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class ShowHideButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initShowHideButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initShowHideButton()
    }
    
    func initShowHideButton() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.showHideButtonStyle)
        accessibilityLabel = AppLocalization.sharedInstance.signUpShowText
    }

}
