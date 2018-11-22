//
//  SearchScanButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 01/05/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

@objc public protocol SearchScanButtonDelegate: AnyObject {
    func searchScanButtonClicked(_ sender: Any?)
}

open class SearchScanButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initSearchScanButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSearchScanButton()
    }
    
    open func initSearchScanButton() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.scannerButtonStyle)
    }    
}
