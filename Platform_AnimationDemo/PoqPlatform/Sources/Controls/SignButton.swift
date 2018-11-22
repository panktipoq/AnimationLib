//
//  SignButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 13/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

@objc public protocol SignButtonDelegate: AnyObject {
    func signButtonClicked(_ sender: Any?)
}

open class SignButton: UIButton {
    
    open var buttonTag = 0
    
    open var fontSize = CGFloat(AppSettings.sharedInstance.signButtonFontSize)
    
    open var forceWhiteBackground: Bool = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initSignButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSignButton()
    }
    
    func initSignButton() {
        
        let signButton: UIButton
        if forceWhiteBackground || AppSettings.sharedInstance.submitButtonType == SubmitButtonType.white.rawValue {
            signButton = WhiteButton(frame: frame)
        } else {
            signButton = BlackButton(frame: frame)
        }
        
        configureStyle(signButton)
    }
    
    func configureStyle(_ button: UIButton) {
        
        setBackgroundImage(button.backgroundImage(for: UIControlState()), for: UIControlState())
        setTitleColor(button.titleColor(for: UIControlState()), for: UIControlState())
        titleLabel?.font = button.titleLabel?.font
    }
}
