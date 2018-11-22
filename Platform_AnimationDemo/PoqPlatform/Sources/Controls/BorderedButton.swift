//
//  BorderedButton.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 9/29/16.
//
//

import Foundation
import UIKit

/// Button with white color inside and colored border
/// We will use tint color for it
open class BorderedButton: UIButton {
    
    static let maxHeight: CGFloat = 28
    
    var createButtonWidth: CGFloat?
    
    open var cornerRadius = CGFloat(AppSettings.sharedInstance.navigationBorderedButtonCornerRadius) {
        didSet {
            updateBorder()
        }
    }

    var borderWidth = CGFloat(AppSettings.sharedInstance.navigationBorderedButtonBorderWidth) {
        didSet {
            updateBorder()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        updateButtonStyle()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateButtonStyle()
    }
    
    /// By default we are using tintColor, which is independed from state.
    /// This dictionary should help us provide different colors for different states.
    open var colorPerState = [UIControlState: UIColor]() {
        didSet {
            updateButtonStyle()
        }
    }
}

// MARK: - convenience API

extension BorderedButton {
    
    /// Create BorderedButton with target and action, after create UIBarButtonItem and return result
    open class func createButtonItem(withTitle title: String, target: AnyObject, action: Selector, position: BarButtonPosition = .right, width: CGFloat? = nil) -> UIBarButtonItem {

        let button = BorderedButton(frame: CGRect.zero)
        button.translatesAutoresizingMaskIntoConstraints = true
        
        button.titleLabel?.font = AppTheme.sharedInstance.borderedBarButtonFont
        button.tintColor = AppTheme.sharedInstance.mainColor
        
        let states: [UIControlState] = [.disabled, .highlighted] 
        for state: UIControlState in states {
            button.colorPerState[state] = BarButtonType.color(forPosition: position, state: state)
        }
        
        button.setTitle(title, for: UIControlState())

        button.addTarget(target, action: action, for: .touchUpInside)
        button.sizeToFit()

        if let buttonWidth = width {
            button.createButtonWidth = buttonWidth
            button.frame.size = CGSize(width: buttonWidth, height: button.frame.height)
        } else {
            // Update the Button Size to avoid small buttons based on small texts.
            // Minimum Button Size can be changed in Client through a ClientStyleProvider.
            if let size = ResourceProvider.sharedInstance.clientStyle?.adjustBorderedNavigationBarButtonSize(basedOn: button.frame.size) {
                button.frame.size = size
            }
        }
        
        return BorderedBarButtonItem(withButton: button)
    }
    
    override open var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set(value) {
            super.isEnabled = value
            updateBorder()
        }
    }
    
    override open var isHighlighted: Bool {
        didSet {
            updateBorder()
        }
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateButtonStyle()
    }
    
    override open func sizeToFit() {
        var newFrame = frame
        newFrame.size = sutableSize
        frame = newFrame
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return sutableSize
    }
    
    override open var intrinsicContentSize: CGSize {
        return sutableSize
    }
    
    open override func setTitle(_ title: String?, for state: UIControlState) {
        
        // Store current frame.
        let oldFrame = frame
        
        super.setTitle(title, for: state)
        
        // In case the new text needs a bigger button.
        self.sizeToFit()
        
        // Use the width provided with the init method.
        if let buttonWidth = createButtonWidth {
            frame.size.width = buttonWidth
        // To avoid having an smaller button.
        } else if frame.size.width < oldFrame.size.width {
            if let size = ResourceProvider.sharedInstance.clientStyle?.adjustBorderedNavigationBarButtonSize(basedOn: self.frame.size) {
                frame.size = size
            }
        }
    }
}

// MARK: - Private

extension BorderedButton {
    
    /**
     Draw colored rect
     - parameter color: of rect
     - returns: resizable image
     */
    fileprivate static func createColorImage(_ color: UIColor?) -> UIImage? {
        
        let imageColor = color ?? AppTheme.sharedInstance.mainColor
        
        return UIImage.createResizableColoredImage(imageColor)
    }

    /// Update title color, background image and border
    fileprivate final func updateButtonStyle() {

        // Disable specific case, we can't allow the same color, it really will confuse user
        if colorPerState[.disabled] == nil {
            colorPerState[.disabled] = (colorPerState[UIControlState()] ?? tintColor)?.colorWithAlpha(0.3)
        }
        
        // Set AppTheme mainColor  as the BorderedButton .normal color.
        if colorPerState[.normal] == nil {
            colorPerState[.normal] = (colorPerState[UIControlState()] ?? BarButtonType.color(forPosition: .right, state: .normal))
        }
        
        // Setup colors already on colorPerState as the tint color of the button
        let states: [UIControlState] = [.highlighted, .disabled, .normal]
        for state in states {
            // Title
            setTitleColor((colorPerState[state] ?? tintColor), for: state)
            
            setBackgroundImage(nil, for: state)
        }
        
        // Selected state is special case, text here shuld change color, since we will fulfill background
        setBackgroundImage(BorderedButton.createColorImage(tintColor), for: .highlighted)
        setTitleColor(UIColor.white, for: .highlighted)

        updateBorder()
    }
    
    fileprivate final func updateBorder() {
        
        var simpleState = UIControlState()
        
        if !isEnabled {
            simpleState = .disabled
        } else if isHighlighted {
            simpleState = .highlighted
        }
        
        let borderColor: UIColor? = colorPerState[simpleState]
        layer.borderColor = borderColor?.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
    }
    
    @nonobjc
    fileprivate var sutableSize: CGSize {
        guard let title = title(for: UIControlState()), let font = titleLabel?.font else {
            // Lets make an empty square
            return CGSize(width: BorderedButton.maxHeight, height: BorderedButton.maxHeight)
        }
        
        let textFrame = (title as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: BorderedButton.maxHeight),
                                                                 options: [],
                                                                 attributes: [NSAttributedStringKey.font: font],
                                                                 context: nil)
        
        let size = CGSize(width: textFrame.size.width + 10, height: BorderedButton.maxHeight)
        
        return size
    }
}

/**
 We need this class as a wrapper for BorderedButton
 In some places we will trying to set title to button - here we should pass it to button
 */
private class BorderedBarButtonItem: UIBarButtonItem {
    fileprivate let borderedButton: BorderedButton 
    init(withButton button: BorderedButton) {
        borderedButton = button 
        super.init()
        // For some reason when we assign button to 'customView' it got disable state, so lets save state
        let buttonEnabled = borderedButton.isEnabled 
        customView = borderedButton
        borderedButton.isEnabled = buttonEnabled
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var title: String? {
        get {
            return borderedButton.title(for: UIControlState()) 
        }
        set(value) {
            borderedButton.setTitle(value, for: UIControlState())
        }
    }
    
    override var isEnabled: Bool {
        get {
            return borderedButton.isEnabled
        }
        
        set(value) {
            borderedButton.isEnabled = value
        }
    }
}
