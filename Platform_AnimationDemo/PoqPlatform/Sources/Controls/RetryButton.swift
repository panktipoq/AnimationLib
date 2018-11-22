//
//  RetryButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 06/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class RetryButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initRetryButton()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initRetryButton()
    }
    
    func initRetryButton() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.retryButtonStyle)
    }

}
