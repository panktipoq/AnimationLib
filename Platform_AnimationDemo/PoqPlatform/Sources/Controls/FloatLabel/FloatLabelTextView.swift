//
//  FloatLabelTextView.swift
//  FloatLabelFields
//
//  Created by Fahim Farook on 28/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//

import UIKit

 /// Poq specific text view component
 class FloatLabelTextView: UITextView {
    
    /// The duration of the animations for this component
	let animationDuration = 0.3
    
    /// The color of the placeholder
	let placeholderTextColor = UIColor.lightGray.withAlphaComponent(0.65)
    
    /// Set if this component is created from a XIB. TODO: Check why do we need this
	fileprivate var isIB = false
    
    /// The title label of the component
	fileprivate var title = UILabel()
    
    /// The hint label of the component
	fileprivate var hintLabel = UILabel()
    
    /// The initial top inset of the component
	fileprivate var initialTopInset:CGFloat = 0
	
	// MARK:- Properties
	override var accessibilityLabel:String? {
		get {
			if text.isEmpty {
				return title.text!
			} else {
				return text
			}
		}
		set {
		}
	}
	
    /// The font of the title for the textvview
	var titleFont:UIFont = UIFont.systemFont(ofSize: 12.0) {
		didSet {
			title.font = titleFont
		}
	}
	
    /// The hint string of the component
	var hint:String = "" {
		didSet {
			title.text = hint
			title.sizeToFit()
			var r = title.frame
			r.size.width = frame.size.width
			title.frame = r
			hintLabel.text = hint
			hintLabel.sizeToFit()
		}
	}
	
    /// The hint's top padding
	var hintYPadding:CGFloat = 0.0 {
		didSet {
			adjustTopTextInset()
		}
	}
	
    /// The title's top padding
	var titleYPadding:CGFloat = 0.0 {
		didSet {
			var r = title.frame
			r.origin.y = titleYPadding
			title.frame = r
		}
	}
	
    /// The color of the title 
	var titleTextColour:UIColor = UIColor.gray {
		didSet {
			if !isFirstResponder {
				title.textColor = titleTextColour
			}
		}
	}
	
    /// The active color of the title
	var titleActiveTextColour:UIColor = UIColor.cyan {
		didSet {
			if isFirstResponder {
				title.textColor = titleActiveTextColour
			}
		}
	}
	
	// MARK:- Init
	required init?(coder aDecoder:NSCoder) {
		super.init(coder:aDecoder)
		setup()
	}
	
    /// Initializer with a text container. Sets up the textview
    ///
    /// - Parameters:
    ///   - frame: The frame of the component
    ///   - textContainer: The text container that manages the text layout
	override init(frame:CGRect, textContainer:NSTextContainer?) {
		super.init(frame:frame, textContainer:textContainer)
		setup()
	}
	
	deinit {
		if !isIB {
			let nc = NotificationCenter.default
			nc.removeObserver(self, name:NSNotification.Name.UITextViewTextDidChange, object:self)
			nc.removeObserver(self, name:NSNotification.Name.UITextViewTextDidBeginEditing, object:self)
			nc.removeObserver(self, name:NSNotification.Name.UITextViewTextDidEndEditing, object:self)
		}
	}
	
	// MARK:- Overrides
    
    /// Prepares the textview as a IB_DESIGNABLE from a XIB file. Sets up the textview
	override open func prepareForInterfaceBuilder() {
		isIB = true
		setup()
	}
	
    /// Called when the subviews layout needs to be reevaluated
	override open func layoutSubviews() {
		super.layoutSubviews()
		adjustTopTextInset()
		hintLabel.alpha = text.isEmpty ? 1.0 : 0.0
		let r = textRect()
		hintLabel.frame = CGRect(x:r.origin.x, y:r.origin.y, width:hintLabel.frame.size.width, height:hintLabel.frame.size.height)
		setTitlePositionForTextAlignment()
		let isResp = isFirstResponder
		if isResp && !text.isEmpty {
			title.textColor = titleActiveTextColour
		} else {
			title.textColor = titleTextColour
		}
		// Should we show or hide the title label?
		if text.isEmpty {
			// Hide
			hideTitle(isResp)
		} else {
			// Show
			showTitle(isResp)
		}
	}
	
	// MARK:- Private Methods
    
    /// Sets up the visuals of the component
	fileprivate func setup() {
		initialTopInset = textContainerInset.top
		textContainer.lineFragmentPadding = 0.0
		titleActiveTextColour = tintColor
		// Placeholder label
		hintLabel.font = font
		hintLabel.text = hint
		hintLabel.numberOfLines = 0
		hintLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
		hintLabel.backgroundColor = UIColor.clear
		hintLabel.textColor = placeholderTextColor
		insertSubview(hintLabel, at:0)
		// Set up title label
		title.alpha = 0.0
		title.font = titleFont
		title.textColor = titleTextColour
		title.backgroundColor = backgroundColor
		if !hint.isEmpty {
			title.text = hint
			title.sizeToFit()
		}
		self.addSubview(title)
		// Observers
		if !isIB {
			let nc = NotificationCenter.default
			nc.addObserver(self, selector:#selector(UIView.layoutSubviews), name:NSNotification.Name.UITextViewTextDidChange, object:self)
			nc.addObserver(self, selector:#selector(UIView.layoutSubviews), name:NSNotification.Name.UITextViewTextDidBeginEditing, object:self)
			nc.addObserver(self, selector:#selector(UIView.layoutSubviews), name:NSNotification.Name.UITextViewTextDidEndEditing, object:self)
		}
	}

    /// Adjusts the text inset considering the hint padding and the line height
	fileprivate func adjustTopTextInset() {
		var inset = textContainerInset
		inset.top = initialTopInset + title.font.lineHeight + hintYPadding
		textContainerInset = inset
	}
	
    /// Returns the rectangle in which the text is rendered
    ///
    /// - Returns: The rectangle in which the text is rendered
	fileprivate func textRect()->CGRect {
		var r = UIEdgeInsetsInsetRect(bounds, contentInset)
		r.origin.x += textContainer.lineFragmentPadding
		r.origin.y += textContainerInset.top
		return r.integral
	}
	
    /// Positions the title of the text view accordingly to the text view text alignment
	fileprivate func setTitlePositionForTextAlignment() {
		var titleLabelX = textRect().origin.x
		var placeholderX = titleLabelX
		if textAlignment == NSTextAlignment.center {
			titleLabelX = (frame.size.width - title.frame.size.width) * 0.5
			placeholderX = (frame.size.width - hintLabel.frame.size.width) * 0.5
		} else if textAlignment == NSTextAlignment.right {
			titleLabelX = frame.size.width - title.frame.size.width
			placeholderX = frame.size.width - hintLabel.frame.size.width
		}
		var r = title.frame
		r.origin.x = titleLabelX
		title.frame = r
		r = hintLabel.frame
		r.origin.x = placeholderX
		hintLabel.frame = r
	}
	
    /// Shows the title of the textview
    ///
    /// - Parameter animated: Wether the appearance of the title is animated or not
	fileprivate func showTitle(_ animated:Bool) {
		let dur = animated ? animationDuration : 0
		UIView.animate(withDuration: dur, delay:0, options: [UIViewAnimationOptions.beginFromCurrentState, UIViewAnimationOptions.curveEaseOut], animations:{
			// Animation
			self.title.alpha = 1.0
			var r = self.title.frame
			r.origin.y = self.titleYPadding + self.contentOffset.y
			self.title.frame = r
			}, completion:nil)
	}
	
    /// Hides the title of the textview
    ///
    /// - Parameter animated: Wether the hiding of the title is animated or not
	fileprivate func hideTitle(_ animated:Bool) {
		let dur = animated ? animationDuration : 0
		UIView.animate(withDuration: dur, delay:0, options: [UIViewAnimationOptions.beginFromCurrentState, UIViewAnimationOptions.curveEaseIn], animations:{
			// Animation
			self.title.alpha = 0.0
			var r = self.title.frame
			r.origin.y = self.title.font.lineHeight + self.hintYPadding
			self.title.frame = r
			}, completion:nil)
	}
}
