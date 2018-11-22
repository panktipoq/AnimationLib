//
//  FloatLabelTextField.swift
//  FloatLabelFields
//
//  Created by Fahim Farook on 28/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//
//  Original Concept by Matt D. Smith
//  http://dribbble.com/shots/1254439--GIF-Mobile-Form-Interaction?list=users
//
//  Objective-C version by Jared Verdi
//  https://github.com/jverdi/JVFloatLabeledTextField
//

import UIKit

/// Input box used throught Poq apps
open class FloatLabelTextField: UITextField {
    
    /// The animation time required to show or hide the titles 
    let animationDuration = 0.3
    
    /// Wether or not to allow paste functionality
    public var allowsPaste = true
    
    /// The title label
	open var title = UILabel()
	    
    /// Customizable clear button image
    open var customClearButtonImage = UIImage() {
        didSet {
            let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
            clearButton.setImage(customClearButtonImage, for: UIControlState())
            
            rightView = clearButton
            clearButton.addTarget(self, action: #selector(FloatLabelTextField.clearClicked(_:)), for: UIControlEvents.touchUpInside)
            
            rightViewMode = self.clearButtonMode
            clearButtonMode = UITextFieldViewMode.never
        }
    }
    
    /// Triggered when clear is pressed
    ///
    /// - Parameter sender: The object sending the acction
    @objc open func clearClicked(_ sender: UIButton) {
        self.text = ""
        _ = delegate?.textFieldShouldClear?(self)
    }

    /// The accesibility value used by the component
    open override var accessibilityValue: String? {
        get {
            return isSecureTextEntry ? nil : text
        }
        set {}
    }
    
	// MARK: - Properties
    
    /// The accesibility value used by the label
	override open var accessibilityLabel: String? {
		get {
			return title.text
		}
		set {
			self.accessibilityIdentifier = newValue
		}
	}
	
    /// The placeholer of the input field
	override open var placeholder: String? {
		didSet {
			title.text = placeholder
			title.sizeToFit()
		}
	}
    
    public var showCursor: Bool = true
	
    /// The attributed placeholder of the input field. We use this to customize visuals of the placeholer
	override open var attributedPlaceholder: NSAttributedString? {
		didSet {
			title.text = attributedPlaceholder?.string
			title.sizeToFit()
		}
	}
	
    /// The font of the title
	open var titleFont = UIFont.systemFont(ofSize: 12.0) {
		didSet {
			title.font = titleFont
			title.sizeToFit()
		}
	}
	
    /// The padding on y axis that the hint text has
	open var hintYPadding: CGFloat = 0.0

    /// The padding on y axis that the title text has
	open var titleYPadding: CGFloat = 0.0 {
		didSet {
			var rect = title.frame
			rect.origin.y = titleYPadding
			title.frame = rect
		}
	}
	
    /// The color of the title text
	open var titleTextColour = UIColor.gray {
		didSet {
			if !isFirstResponder {
				title.textColor = titleTextColour
			}
		}
	}
	
    /// The active color of the title text
	open var titleActiveTextColour: UIColor! {
		didSet {
			if isFirstResponder {
				title.textColor = titleActiveTextColour
			}
		}
	}
	
	// MARK: - Init
    
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	// MARK: - Overrides
    
    /// Triggered when the view needs to reposition it's subviews. Based on the settings the view is updated accordingly
	override open func layoutSubviews() {
		super.layoutSubviews()
		setTitlePositionForTextAlignment()
		let isResp = isFirstResponder
		if isResp && !obligatoryText().isEmpty {
			title.textColor = titleActiveTextColour
		} else {
			title.textColor = titleTextColour
		}
		// Should we show or hide the title label?
		if obligatoryText().isEmpty {
			// Hide
			hideTitle(isResp)
		} else {
			// Show
			showTitle(isResp)
		}
	}
    
    /// Hides the cursor inside the textfield use property showCursor before this is called
    ///
    /// - Parameter position: The position of the cursor
    /// - Returns: Size of the caret inside the textfield
    open override func caretRect(for position: UITextPosition) -> CGRect {
        return showCursor ? super.caretRect(for: position) : .zero
    }
	
    /// Used to add the padding to the top of the text field
    ///
    /// - Parameter bounds: The bounds of the text rectangle
    /// - Returns: The text field's rectangle
	override open func textRect(forBounds bounds: CGRect) -> CGRect {
		var rect = super.textRect(forBounds: bounds)
		if !obligatoryText().isEmpty {
			var top = ceil(title.font.lineHeight + hintYPadding)
			top = min(top, maxTopInset())
			rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
		}
		return rect.integral
	}
	
    /// Used to calculate the textfield size while editing
    ///
    /// - Parameter bounds: The bounds of the textfield
    /// - Returns: The text field's rectangle
	override open func editingRect(forBounds bounds: CGRect) -> CGRect {
		var rect = super.editingRect(forBounds: bounds)
		if !obligatoryText().isEmpty {
			var top = ceil(title.font.lineHeight + hintYPadding)
			top = min(top, maxTopInset())
			rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0))
		}
		return rect.integral
	}
	
    /// Used to calculate the rectangle of the clear button
    ///
    /// - Parameter bounds: The bounds of the clear button
    /// - Returns: The rectangle of the clear button in the text field
	override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
		var rect = super.clearButtonRect(forBounds: bounds)
		if !obligatoryText().isEmpty {
			var top = ceil(title.font.lineHeight + hintYPadding)
			top = min(top, maxTopInset())
			rect = CGRect(x: rect.origin.x, y: rect.origin.y + (top * 0.5), width: rect.size.width, height: rect.size.height)
		}
		return rect.integral
	}
    
    /// Limits the usage of the paste action based on the setting
    ///
    /// - Parameters:
    ///   - action: The selector that is to be checked
    ///   - sender: The object that dispatches the action
    /// - Returns: Wether or not the action in discussion can be performed
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if !allowsPaste && action == #selector(UIResponderStandardEditActions.paste) {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
	
	// MARK: - Public Methods
	
	// MARK: - Private Methods
    
    /// Sets up the visual style of the textfield
	fileprivate func setup() {
		borderStyle = UITextBorderStyle.none
		titleActiveTextColour = tintColor
		// Set up title label
		title.alpha = 0.0
		title.font = titleFont
		title.textColor = titleTextColour
		if let str = placeholder {
			if !str.isEmpty {
				title.text = str
				title.sizeToFit()
			}
		}
		self.addSubview(title)
	}

    /// Calculates the maximum top inset the textfield can have
    ///
    /// - Returns: The maximum top inset of the textfield
	fileprivate func maxTopInset() -> CGFloat {
        
        let existedFont = font ?? UIFont.systemFont(ofSize: 12); // Create default font according to description
		return max(0, floor(bounds.size.height - existedFont.lineHeight - 4.0))
	}
	
    /// Sets the title position based on the text alignment
	fileprivate func setTitlePositionForTextAlignment() {
		let rect = textRect(forBounds: bounds)
		var positionX = rect.origin.x
		if textAlignment == NSTextAlignment.center {
			positionX = rect.origin.x + (rect.size.width * 0.5) - title.frame.size.width
		} else if textAlignment == NSTextAlignment.right {
			positionX = rect.origin.x + rect.size.width - title.frame.size.width
		}
		title.frame = CGRect(x: positionX, y: title.frame.origin.y, width: title.frame.size.width, height: title.frame.size.height)
	}
	
    /// Shows the textfield title
    ///
    /// - Parameter animated: Wether or not to animate the appearance
	fileprivate func showTitle(_ animated: Bool) {
		let dur = animated ? animationDuration : 0
		UIView.animate(withDuration: dur, delay: 0, options: [UIViewAnimationOptions.beginFromCurrentState, UIViewAnimationOptions.curveEaseOut], animations: {
				// Animation
				self.title.alpha = 1.0
				var rect = self.title.frame
				rect.origin.y = self.titleYPadding
				self.title.frame = rect
			}, completion: nil)
	}
	
    /// Hides the textfield title
    ///
    /// - Parameter animated: Wether or not to animate the appearance
	fileprivate func hideTitle(_ animated: Bool) {
		let dur = animated ? animationDuration : 0
		UIView.animate(withDuration: dur, delay: 0, options: [UIViewAnimationOptions.beginFromCurrentState, UIViewAnimationOptions.curveEaseIn], animations: {
			// Animation
			self.title.alpha = 0.0
			var rect = self.title.frame
			rect.origin.y = self.title.font.lineHeight + self.hintYPadding
			self.title.frame = rect
			}, completion: nil)
	}
}
