//
//  TwoTextfieldsTableViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 24/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

/// Table view cell containing two textfields
open class TwoTextfieldsTableViewCell: UITableViewCell {
    
    /// First textfield
    @IBOutlet open weak var firstNameTextField: FloatLabelTextFieldWithState? {
        didSet {
            firstNameTextField?.titleFont = AppTheme.sharedInstance.textFieldActiveTitleFont
            firstNameTextField?.font = AppTheme.sharedInstance.signUpTextFieldFont
            firstNameTextField?.titleActiveTextColour = AppTheme.sharedInstance.signInRegisterInputPlaceHolderColor
            firstNameTextField?.autocapitalizationType = UITextAutocapitalizationType.words
            if let clearButtonImage = UIImage(named: "serchTextFieldClearButton") {
                firstNameTextField?.customClearButtonImage = clearButtonImage
            }
        }
    }
    
    /// Second textfield
    @IBOutlet open weak var lastNameTextField: FloatLabelTextFieldWithState? {
        didSet {
            lastNameTextField?.titleFont = AppTheme.sharedInstance.textFieldActiveTitleFont
            lastNameTextField?.font = AppTheme.sharedInstance.signUpTextFieldFont
            lastNameTextField?.titleActiveTextColour=AppTheme.sharedInstance.signInRegisterInputPlaceHolderColor
            lastNameTextField?.autocapitalizationType = UITextAutocapitalizationType.words
            if let clearButtonImage = UIImage(named: "serchTextFieldClearButton") {
                lastNameTextField?.customClearButtonImage = clearButtonImage
            }
        }
    }
    
    /// Vertical separator between textfields
    @IBOutlet open var verticalLine: VerticalLine?
    
    /// The underline beneath the textfield
    @IBOutlet open weak var underline: HorizontalLine?
    
    /// The container holding the underlines
    @IBOutlet open weak var solidLinesContainer: UIView?
    
    /// The underline beneath the textfield TODO: We needn't use two underlines
    @IBOutlet open weak var solidLineSeparator: SolidLine? {
        didSet {
            solidLineSeparator?.isHidden = AppSettings.sharedInstance.solidLineHasSeparator
        }
    }
    
    /// Triggered when the cell is created from xib. TODO: Not used - can be removed
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    /// Sets up the cell accordingly
    ///
    /// - Parameter parameters: The parameters used to style the cell
    open func setUpCell(_ parameters: TwoTextfieldsTableViewCellParameters) {
        firstNameTextField?.placeholder = parameters.firstName
        firstNameTextField?.attributedPlaceholder = NSAttributedString(string: parameters.firstName, attributes: [NSAttributedStringKey.foregroundColor: parameters.inputTextColor])

        firstNameTextField?.tag = parameters.firstNameTag
        firstNameTextField?.delegate = parameters.delegate
        
        lastNameTextField?.attributedPlaceholder = NSAttributedString(string: parameters.lastName, attributes: [NSAttributedStringKey.foregroundColor: parameters.inputTextColor])

        lastNameTextField?.tag = parameters.lastNameTag
        lastNameTextField?.delegate = parameters.delegate
        
        verticalLine?.isHidden = parameters.hideVerticalSeparator
        
        firstNameTextField?.text = parameters.firstNameValue
        lastNameTextField?.text = parameters.lastNameValue
        
        underline?.isHidden = true
        solidLineSeparator?.isHidden = true

        switch parameters.separatorType {
        case CellSeparatorType.paintcodeHorizontal:
            underline?.isHidden = false
            
        case CellSeparatorType.solid:
            solidLineSeparator?.isHidden = false
        default: ()
        }
    }

    /// Sets the cell as selected
    ///
    /// - Parameters:
    ///   - selected: Wether the cell is selected or not
    ///   - animated: Wether the selection is animated or not
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

/// Structure used to style the two textfields cell
public struct TwoTextfieldsTableViewCellParameters {
    var firstName: String
    var firstNameTag: Int
    var lastName: String
    var lastNameTag: Int
    var delegate: UITextFieldDelegate
    var hideVerticalSeparator: Bool
    var devidedSeparator: Bool // If Yes, we devide separator for each text field
    var firstNameValue: String?
    var lastNameValue: String?
    var separatorType: CellSeparatorType
    var inputTextColor = UIColor.black

    public init(firstName: String, 
                firstNameTag: Int,
                lastName: String,
                lastNameTag: Int,
                delegate: UITextFieldDelegate,
                hideVerticalSeparator: Bool,
                devidedSeparator: Bool,
                firstNameValue: String?,
                lastNameValue: String?,
                separatorType: CellSeparatorType,
                inputTextColor: UIColor) {
        self.firstName = firstName 
        self.firstNameTag = firstNameTag
        self.lastName = lastName
        self.lastNameTag = lastNameTag
        self.delegate = delegate
        self.hideVerticalSeparator = hideVerticalSeparator
        self.devidedSeparator = devidedSeparator
        self.firstNameValue = firstNameValue
        self.lastNameValue = lastNameValue
        self.separatorType = separatorType
        self.inputTextColor = inputTextColor 
    }
}

// MARK: - CheckoutAddressCell implementation
extension TwoTextfieldsTableViewCell: CheckoutAddressCell {

    /// Updates the UI accordingly
    ///
    /// - Parameters:
    ///   - item: The Checkout address element used to populate the cell
    ///   - delegate: The delegate used to receive the calls as a result of the cell's actions
    public func updateUI(_ item: CheckoutAddressElement, delegate: CheckoutAddressCell.CheckoutAddressCellDelegate) {

        let parameters: TwoTextfieldsTableViewCellParameters =
            TwoTextfieldsTableViewCellParameters(firstName: item.firstField?.type.placehoderText ?? "",
                                                 firstNameTag: item.firstField?.type.rawValue ?? 0,
                                                 lastName: item.secondField?.type.placehoderText ?? "",
                                                 lastNameTag: item.secondField?.type.rawValue ?? 0,
                                                 delegate: delegate,
                                                 hideVerticalSeparator: AppSettings.sharedInstance.signUpHideVerticalSeparator,
                                                 devidedSeparator: false,
                                                 firstNameValue: item.firstField?.value,
                                                 lastNameValue: item.secondField?.value,
                                                 separatorType: CellSeparatorType.solid,
                                                 inputTextColor: UIColor.black)
        setUpCell(parameters)
    }
    
    /// Makes one of the textfields the first responder
    ///
    /// - Parameter textFieldType: The text field type that selects which field is used as first responder
    public func makeTextFieldFirstResponder(_ textFieldType: AddressTextFieldsType) {

        if firstNameTextField?.addressTextFieldsType == textFieldType {
            firstNameTextField?.becomeFirstResponder()
        } else {
            lastNameTextField?.becomeFirstResponder()
        }
    }
    
    /// Resigns the first responder of either textfield
    public func resignTextFieldsFirstResponder() {

        firstNameTextField?.resignFirstResponder()
        lastNameTextField?.resignFirstResponder()
    }
}

// MARK: - MyProfileCell implementation
extension TwoTextfieldsTableViewCell: MyProfileCell {
    
    /// Updates the UI accordingly
    ///
    /// - Parameters:
    ///   - item: The profile item used to populate the cell
    ///   - delegate: The delegate used to receive the calls as a result of the cell's actions
    public func updateUI(_ item: MyProfileContentItem, delegate: MyProfileCellsDelegate?) {
        
        firstNameTextField?.config = item.firstInputItem.config
        firstNameTextField?.styling = FloatLabelTextFieldStyling.createDefaultMyProfileStyling()
        firstNameTextField?.tag = item.firstInputItem.controlTag.rawValue 
        firstNameTextField?.text = item.firstInputItem.value
        firstNameTextField?.delegate = delegate
        
        lastNameTextField?.config = item.secondInputItem?.config
        lastNameTextField?.styling = FloatLabelTextFieldStyling.createDefaultMyProfileStyling()
        lastNameTextField?.tag = item.secondInputItem?.controlTag.rawValue ?? 0
        lastNameTextField?.text = item.secondInputItem?.value
        lastNameTextField?.delegate = delegate
        
        verticalLine?.isHidden = AppSettings.sharedInstance.signUpHideVerticalSeparator
        
        underline?.isHidden = true
        solidLineSeparator?.isHidden = false
    }
}
