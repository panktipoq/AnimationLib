//
//  LookbookButton.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/16/15.
//  Copyright © 2015 Poq. All rights reserved.
//


import UIKit

/// A instance of a lookbook clickable area
open class LookbookButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initLookbookButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLookbookButton()
    }
    
    /// Sets up the look book buton
    func initLookbookButton() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.lookbookButtonStyle)
        setTitle(AppLocalization.sharedInstance.lookbookShopButtonTitle, for: .normal)
        setTitle(AppLocalization.sharedInstance.lookbookHideButtonTitle, for: .selected)
    }
    
}
