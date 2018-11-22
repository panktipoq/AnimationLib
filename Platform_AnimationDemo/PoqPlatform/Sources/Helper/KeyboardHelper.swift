//
//  KeyboardHelper.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 1/13/16.
//  Copyright © 2016 Poq. All rights reserved.
//

import Foundation

@objc
public protocol KeyboardEventsListener: AnyObject {
    func keyboardWillShow(_ notification: Notification)
    func keyboardWillHide(_ notification: Notification)
}

open class KeyboardHelper {

    open class func addKeyboardNotification(_ observer: KeyboardEventsListener, iPhoneOnly: Bool = true) {
        if !iPhoneOnly || !DeviceType.IS_IPAD {
            NotificationCenter.default.addObserver(observer, selector: #selector(KeyboardEventsListener.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(observer, selector: #selector(KeyboardEventsListener.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        }
    }

    open class func removeKeyboardNotification(_ observer: KeyboardEventsListener) {
        
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}
