//
//  FullwidthTextFieldCellTableViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 18/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import UIKit


/// Protocol specific for tableview cell with FullWidthAutoresizedCollectionCell inside that has a UIDatePicker for inputView
public protocol DatePickerCell {
    /**
     Update UI with provided item. May need use external data validators
     - parameter item: mdoel element, which provide while needed information
     - parameter delegate: delegate for all possible user events.
     */
    func updateUI(_ item: MyProfileContentItem, delegate: UITextFieldDelegate)
    
    /// While we switching between cells we need be able to make next one first responder
    func makeTextFieldFirstResponder(_ textFieldType: AddressTextFieldsType)
    
    /// Good chance to hide keyboard
    func resignTextFieldsFirstResponder()
}

/// Table view cell witha a full width text field
open class DateTableViewCell: UITableViewCell {
    
    weak var delegate: UITextFieldDelegate?
    
    /// The input text field inside the table view cell
    @IBOutlet open weak var inputTextField: FloatLabelTextFieldWithState? {
        didSet {
            inputTextField?.showCursor = false
            inputTextField?.titleFont = AppTheme.sharedInstance.textFieldActiveTitleFont
            inputTextField?.font = AppTheme.sharedInstance.signUpTextFieldFont
            inputTextField?.titleActiveTextColour = AppTheme.sharedInstance.mainColor
            
            if let clearButtonImage = ImageInjectionResolver.loadImage(named: "serchTextFieldClearButton") {
                inputTextField?.customClearButtonImage = clearButtonImage
            }
        }
    }
    
    /// The underline beneath the textfield
    @IBOutlet open weak var underline: HorizontalLine?
    @IBOutlet open weak var solidLine: SolidLine?
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.addTarget(self, action: #selector(DateTableViewCell.datePickerValueChanged(_:)), for: .valueChanged)
        picker.datePickerMode = .date
        return picker
    }()
    
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
extension DateTableViewCell: DatePickerCell {
    
    /// Updates the ui with the specific content item
    ///
    /// - Parameters:
    ///   - item: The checkout address element used to populate the cell
    ///   - delegate: The delegate object used by the cell
    public func updateUI(_ item: MyProfileContentItem, delegate: UITextFieldDelegate) {
        
        self.delegate = delegate
        
        let keyboardToolbar = UIToolbar()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DateTableViewCell.dismissKeyboard))
        
        keyboardToolbar.sizeToFit()
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        
        inputTextField?.config = item.firstInputItem.config ?? FloatLabelTextFieldConfig()
        inputTextField?.styling = FloatLabelTextFieldStyling.createDefaultMyProfileStyling()
        inputTextField?.tag = item.firstInputItem.controlTag.rawValue
        inputTextField?.inputView = datePicker
        inputTextField?.inputAccessoryView = keyboardToolbar
        inputTextField?.delegate = delegate
        
        // We are using solid line on login/register
        underline?.isHidden = true
        solidLine?.isHidden = false
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
    
    @objc public func datePickerValueChanged(_ picker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.current
        
        inputTextField?.text = dateFormatter.string(from: picker.date)
        // Force delegate method trigger when text is changed
        guard let validDelegate = delegate, let validInputTextField = inputTextField, let textFieldMethod = validDelegate.textField else {
            return
        }
        
        let _ = textFieldMethod(validInputTextField, NSRange(location: 0, length: 0), "")
    }
    
    @objc public func dismissKeyboard() {
        inputTextField?.endEditing(true)
    }
    
}
