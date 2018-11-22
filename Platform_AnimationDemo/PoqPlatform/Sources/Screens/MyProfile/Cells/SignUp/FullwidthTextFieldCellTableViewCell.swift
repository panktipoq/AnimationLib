//
//  FullwidthTextFieldCellTableViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 18/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import UIKit

/// Table view cell witha a full width text field
open class FullwidthTextFieldCellTableViewCell: UITableViewCell {

    /// The input text field inside the table view cell
    @IBOutlet open weak var inputTextField: FloatLabelTextFieldWithState? {
        didSet {
            inputTextField?.titleFont = AppTheme.sharedInstance.textFieldActiveTitleFont
            inputTextField?.font = AppTheme.sharedInstance.signUpTextFieldFont
            inputTextField?.titleActiveTextColour = AppTheme.sharedInstance.mainColor
            if let clearButtonImage = UIImage(named: "serchTextFieldClearButton") {
                inputTextField?.customClearButtonImage = clearButtonImage
            }
        }
    }

    /// Button toggling between visible and secured password field
    @IBOutlet open weak var showHideButton: ShowHideButton?
    
    /// The underline beneath the textfield
    @IBOutlet open weak var underline: HorizontalLine?
    
    /// The underline beneath the textfield TODO: we are using 2 underlines.
    @IBOutlet open weak var solidLine: SolidLine?
    
    /// Trailing margin of the textfield
    @IBOutlet open weak var trailingMargin: NSLayoutConstraint?
    
    /// Trailing margin when the showhide button is visible
    let trailingMarginWithShowHideButton: CGFloat = -47
    
    /// Trailing margin when the showhide button is not visible TODO: We should leverage the constarints in the xib more and remove the magic numbers
    let trailingMarginWithoutShowHideButton: CGFloat = -5
    
    // TODO: switch from int to PoqTextFieldsType
    
   /// Sets up the cell visuals and content
   ///
   /// - Parameters:
   ///   - placeholderText: The placeholder text
   ///   - tag: The tag of the textfield
   ///   - delegate: The delegate of input text field
   ///   - hideButton: The hide button used to toggle between secured and visible input text
   ///   - labelText: Text inside the label of the textfield
   ///   - separatorType: Separator type used
   ///   - inputTextColor: The input textfield text color
    open func setUpCell(_ placeholderText: String?, tag: Int, delegate: UITextFieldDelegate, hideButton: Bool, labelText: String? = "", separatorType: CellSeparatorType = CellSeparatorType.solid, inputTextColor: UIColor = UIColor.black) {
        
        inputTextField?.attributedPlaceholder = NSAttributedString(string: placeholderText ?? "", attributes: [NSAttributedStringKey.foregroundColor: inputTextColor])
        inputTextField?.tag = tag
        inputTextField?.delegate = delegate
        
        inputTextField?.isSecureTextEntry = !hideButton
        
        // Enable/disable show hide button
        showHideButton?.isHidden = hideButton
        
        // Move the textfield to right most
        if let constraint = trailingMargin {
            constraint.constant = hideButton ? trailingMarginWithoutShowHideButton : trailingMarginWithShowHideButton
        }
        
        // For dequed cells which had the button hidden, the text in the button gets stretched unless they're redrawn.
        if !hideButton {
            showHideButton?.setNeedsDisplay()
        }
        
        inputTextField?.text = labelText
        
        underline?.isHidden = true
        solidLine?.isHidden = true
        
        switch separatorType {
        case CellSeparatorType.paintcodeHorizontal:
            underline?.isHidden = false
        case CellSeparatorType.solid:
            solidLine?.isHidden = false
        default: ()
        }
        
        self.tag = tag
    }
    
    /// Triggered when the the show hide button is clicked
    ///
    /// - Parameter sender: The sender that generates the action
    @IBAction public func showHideButtonClicked(_ sender: Any?) {
        inputTextField?.resignFirstResponder()
        inputTextField?.isSecureTextEntry = !(inputTextField?.isSecureTextEntry ?? false)
        showHideButton?.isSelected = !(showHideButton?.isSelected ?? false)
    }
    
    /// Sets up the keyboard specifics
    ///
    /// - Parameters:
    ///   - keyboardType: The type of keybord to be used
    ///   - returnKeyType: The return key type used
    ///   - autocapitalizationType: The autocapitalization type used by the keyboard
    open func setUpKeyboard(_ keyboardType: UIKeyboardType, returnKeyType: UIReturnKeyType, autocapitalizationType: UITextAutocapitalizationType) {
        inputTextField?.keyboardType = keyboardType
        inputTextField?.returnKeyType = returnKeyType
        inputTextField?.autocapitalizationType = autocapitalizationType
    }
}

// MARK: - CheckoutAddressCell

extension FullwidthTextFieldCellTableViewCell: CheckoutAddressCell {
    
    /// Updates the ui with the specific content item
    ///
    /// - Parameters:
    ///   - item: The checkout address element used to populate the cell
    ///   - delegate: The delegate object used by the cell
    public func updateUI(_ item: CheckoutAddressElement, delegate: CheckoutAddressCell.CheckoutAddressCellDelegate) {

        setUpCell(item.firstField?.type.placehoderText,
                  tag: item.firstField?.type.rawValue ?? 0,
                  delegate: delegate,
                  hideButton: true,
                  labelText: item.firstField?.value)
        
        // Uppercase for postcode
        let autocapitalizationType = item.firstField?.type == .postCode ? UITextAutocapitalizationType.allCharacters : UITextAutocapitalizationType.words
        let keybardType = UIKeyboardType.keyboardType(forTextFieldType: item.firstField?.type)
        setUpKeyboard(keybardType, returnKeyType: UIReturnKeyType.next, autocapitalizationType: autocapitalizationType)
        
        // Loading indicator for country cell
        if item.firstField?.type == .country {
            createAccessoryView()
        } else {
            accessoryView = nil
        }
    }
    
    /// Makes this textfield the first responder
    ///
    /// - Parameter textFieldType: The type of textfield
    public func makeTextFieldFirstResponder(_ textFieldType: AddressTextFieldsType) {
        inputTextField?.becomeFirstResponder()
    }
    
    /// Makes this textfield resign the first responder state
    public func resignTextFieldsFirstResponder() {
        inputTextField?.resignFirstResponder()
    }
}

// MARK: - MyProfileCell implementatio
extension FullwidthTextFieldCellTableViewCell: MyProfileCell {
    
    /// Updates the UI with the apropriate content item
    ///
    /// - Parameters:
    ///   - item: The my profile content item used to populate this screen
    ///   - delegate: The delegate that will be used for the input textfield 
    public func updateUI(_ item: MyProfileContentItem, delegate: MyProfileCellsDelegate?) {
        
        let hideButton: Bool = item.type != .password
        
        inputTextField?.config = item.firstInputItem.config ?? FloatLabelTextFieldConfig()
        inputTextField?.styling = FloatLabelTextFieldStyling.createDefaultMyProfileStyling()
        
        inputTextField?.tag = item.firstInputItem.controlTag.rawValue
        inputTextField?.delegate = delegate
        
        inputTextField?.isSecureTextEntry = !hideButton
        // Enable/disable show hide button
        showHideButton?.isHidden = hideButton
        
        // Move the textfield to right most
        if let constraint = trailingMargin {
            constraint.constant = hideButton ? -5 : constraint.constant
        }
        
        inputTextField?.text = item.firstInputItem.value
        
        // We are using solid line on login/register
        underline?.isHidden = true
        solidLine?.isHidden = false
        
        switch item.type {
        case .email:
            inputTextField?.keyboardType = .emailAddress
        case .phone:
            inputTextField?.keyboardType = .phonePad
        default:
            inputTextField?.keyboardType = .default
        }
    }
}
