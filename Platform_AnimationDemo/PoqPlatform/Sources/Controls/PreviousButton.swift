//
//  PreviousButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 07/07/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import UIKit

open class PreviousButton: UIButton {
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        addStyle()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        addStyle()
    }
    
    open override func awakeFromNib() {
        
        super.awakeFromNib()
        
        addStyle()
    }
    
    fileprivate func addStyle() {
        
        let previousButtonStyle = ResourceProvider.sharedInstance.clientStyle?.previousButtonStyle
        
        configurePoqButton(style: previousButtonStyle)
    }
}
