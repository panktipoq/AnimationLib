//
//  FloatLabelTextFieldWithState.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/21/16.
//
//

import Foundation

/// Object containing the visual configuration for the title label in the text field
public struct FloatLabelTextFieldConfig {
    
    /// The placeholder that will be shown in the textfield
    let placeholder: String?
    
    /// The message showed when the field is editing
    let editingMessage: String? // If nil - placeholder will be used
    
    /// The error message showed when the field performs an invalid action
    let errorMessage: String? // Will be used when state set to error
    
    /// Initializes the configuration object with the placeholder message, editing message and error message
    ///
    /// - Parameters:
    ///   - placeholder: The placeholder message
    ///   - editingMessage: The editing message
    ///   - errorMessage: The error message
    public init(placeholder: String?, editingMessage: String?, errorMessage: String?) {
        self.placeholder = placeholder
        self.editingMessage = editingMessage
        self.errorMessage = errorMessage
    }
    
    /// Initializes the configuration object without any messages
    public init() {
        self.placeholder = nil
        self.editingMessage = nil
        self.errorMessage = nil
    }
}

/// Idle - text field is not first response. editing - text field is first responder
public struct FloatLabelTextFieldStyling {
    
    /// The color of the placeholder
    public var placehoderColor = UIColor.gray

    /// The idle color of the text
    public var idleTextColor = UIColor.black
    
    /// The color of the text while editing
    public var editingTextColor = UIColor.black

    /// The color of the title
    public var idleTitleColor = AppTheme.sharedInstance.mainColor
    
    /// The color of the title while editing
    public var editingTitleColor = UIColor.black
    
    /// The color of the idle error message
    public var idleErrorMessageColor = UIColor.red
    
    /// The color of the editing error message
    public var editingErrorMessageColor =  UIColor.red
    
    public init() {
    }
}

/**
 We need to extend the functionality of 'FloatLabelTextField' to support new otions
 1. While typing text field have 2 options: just message and error message. Each have its own color
 2. Keep FloatLabelTextFieldConfig and FloatLabelTextFieldStyling to simplyfy configurin. Just set 
 */
open class FloatLabelTextFieldWithState: FloatLabelTextField {
    
    /// Affect on error message shown or just message
    open var isValid: Bool = true {
        didSet { updateMessageTextAndStyling(forText: text) } 
    }

    /// The text field configuration
    open var config: FloatLabelTextFieldConfig? {
        didSet { updateMessageTextAndStyling(forText: text) } 
    }
    
    /// The text field styling
    open var styling: FloatLabelTextFieldStyling? {
        didSet { updateMessageTextAndStyling(forText: text) } 
    }
    
    /// Triggered when the textfield becomes the first responder. Updates the styling
    ///
    /// - Returns: Wether the view became the first responder status or not
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        updateMessageTextAndStyling(forText: text)
        return result
    }
    
    /// Triggered when the textfield resigns the first responder. Updates the styling.
    ///
    /// - Returns: Wether the view resigned the first responder status or not
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        updateMessageTextAndStyling(forText: text)
        return result
    }

    /// Inserts a given text
    ///
    /// - Parameter text: The text that is to be inserted. Updates the styling.
    override open func insertText(_ text: String) {
        super.insertText(text)
        
        updateMessageTextAndStyling(forText: text)
    }
    
    /// Deletes a character and updates the styling
    override open func deleteBackward() {
        super.deleteBackward()
        
        updateMessageTextAndStyling(forText: text)
    }
    
    /// Replaces the text in the the textfield TODO: There is no special functionality in this maybe it can be removed
    ///
    /// - Parameters:
    ///   - range: The range of the string that will be replaced
    ///   - text: The new text that will appear in the string
    override open func replace(_ range: UITextRange, withText text: String) {
        super.replace(range, withText: text)
    }
}

// MARK: - Convenience API
extension FloatLabelTextFieldWithState {
    /**
     Check variable like 'isValid', 'config' and 'styling' to update floating label style and text
     - parameter forText: text which will be in text field after current keyboard insert callback. 
                          We can't really work with 'text' var, since delegate method will be trigerred before 'text' updated 
     */
    @nonobjc
    public final func updateMessageTextAndStyling(forText text: String?) {
        guard let existedConfig = config, let existedStyling = styling else {
            // If they need - we should not do anything, probably this is outdated usage, legacy approach
            return
        }

        guard let existedText: String = text, !existedText.isEmpty else {
            if let existedPlaceholder = existedConfig.placeholder, !existedPlaceholder.isEmpty {
                attributedPlaceholder = NSAttributedString(string: existedPlaceholder, attributes: [NSAttributedStringKey.foregroundColor: existedStyling.placehoderColor ])
            } else {
                attributedPlaceholder = nil
            }
            return
        }
        
        let validTitleText: String? = isFirstResponder ? (existedConfig.editingMessage ?? existedConfig.placeholder) : existedConfig.placeholder
        
        if isValid {
            titleActiveTextColour = existedStyling.editingTitleColor
            titleTextColour = existedStyling.idleTitleColor
            
            title.text = validTitleText
            title.sizeToFit()
            return
        }
        
        /// Invalid state
        
        titleActiveTextColour = existedStyling.editingErrorMessageColor
        titleTextColour = existedStyling.idleErrorMessageColor
        
        let errorText: String? = existedConfig.errorMessage ?? validTitleText
        title.text = errorText
        title.sizeToFit()
    }
}
