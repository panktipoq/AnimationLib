//
//  NextButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 07/07/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import UIKit

public final class NextButton: UIButton {
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        addStyle()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        addStyle()
    }
    
    public override func awakeFromNib() {
        
        super.awakeFromNib()
        
        addStyle()
    }
    
    fileprivate func addStyle() {
        
        let nextButtonStyle = ResourceProvider.sharedInstance.clientStyle?.nextButtonStyle
        
        configurePoqButton(style: nextButtonStyle)
    }
}
