//
//  ImportButton.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/16/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import UIKit

public protocol ImportButtonDelegate: class{
    func importButtonClicked(_ sender: ImportButton!)
}

open class ImportButton: UIButton {
    
    public weak var delegate: ImportButtonDelegate?
    var isPressed:Bool=false
    var buttonTag = 0
    
    fileprivate var isDisabled:Bool = false
    
    open func enableInteraction(_ isEnabled:Bool){
        isDisabled = !isEnabled
        self.isUserInteractionEnabled = isEnabled
        self.setNeedsDisplay()
    }
    
    open override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {}
    }
    
    open override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraitButton
        }
        set {}
    }
    
    open override var accessibilityLabel: String? {
        get {
            return title(for: .normal)
        }
        set {}
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isPressed=true
        self.setNeedsDisplay()
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isPressed=false
        self.setNeedsDisplay()
        delegate?.importButtonClicked(self)
    }
    
    open func setEnable(_ isEnabled:Bool){
        self.isUserInteractionEnabled=isEnabled
        self.isPressed = !isEnabled
        self.setNeedsDisplay()
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isPressed=false
        self.setNeedsDisplay()
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isPressed=false
        self.setNeedsDisplay()
    }
}
