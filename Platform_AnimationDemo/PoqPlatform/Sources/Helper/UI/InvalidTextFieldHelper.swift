//
//  InvalidTextFieldHelper.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 9/10/15.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation

open class InvalidTextFieldHelper {
    
    @discardableResult
    public static func shakeInvalidTextField(_ textField: FloatLabelTextField?) -> Bool {
        textField?.titleActiveTextColour = AppTheme.sharedInstance.invalidTextFieldColor
        textField?.shake()
        textField?.becomeFirstResponder()
        return false
    }

}
