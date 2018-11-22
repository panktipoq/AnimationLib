//
//  ButtonTableViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 24/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

/// A cell containing a single button. TODO: Group block cells based on functionality
open class ButtonTableViewCell: UITableViewCell {
    
    /// The action button
    @IBOutlet open weak var submitButton: SignButton?
    
    /// Button leading constraint
    @IBOutlet open weak var signButtonLeadingSpace: NSLayoutConstraint?
    
    /// Button trailing constraint
    @IBOutlet open weak var signButtonTrailingSpace: NSLayoutConstraint?
    
    /// Height of the signin button
    @IBOutlet open weak var signButtonHeight: NSLayoutConstraint?

    /// Triggered when the cell is created from xib
    override open func awakeFromNib() {
        super.awakeFromNib()
        setUpiPadSpecificConfigurations()
    }
    
    /// Sets up the iPad specific configurations. TODO: This property is duplicated as iPad specific. Appsetings should not be implemented like this
    open func setUpiPadSpecificConfigurations() {
        if DeviceType.IS_IPAD {
            signButtonLeadingSpace?.constant = CGFloat(AppSettings.sharedInstance.iPadSignInButtonLeadingSpace)
            signButtonTrailingSpace?.constant = CGFloat(AppSettings.sharedInstance.iPadSigninButtonTrailingSpace)
            submitButton?.fontSize = CGFloat(AppTheme.sharedInstance.iPadSignButtonFontSize)
        }
    }
    
    /// Sets up the cell's contents. Sets the state of the cell 
    ///
    /// - Parameters:
    ///   - buttonText: The text of the button
    ///   - isEnabled: Wether the button is enabled or not
    open func setUpCell(_ buttonText: String, isEnabled: Bool) {
        submitButton?.setTitle(buttonText, for: .normal)
        submitButton?.isEnabled = isEnabled
    }
    
    /// Sets up the button to match the it's container
    open func setUpButtonWithouthConstraints() {
        signButtonLeadingSpace?.constant = 0
        signButtonTrailingSpace?.constant = 0
    }

}

// MARK: - The my profile cell protocol implementation
extension ButtonTableViewCell: MyProfileCell {
    
    /// Updates the UI based on the content item
    ///
    /// - Parameters:
    ///   - item: The content item used to populate the cell
    ///   - delegate: The delegate used to call cell actions on
    public func updateUI(_ item: MyProfileContentItem, delegate: MyProfileCellsDelegate?) {

        submitButton?.addTarget(delegate, action:#selector(delegate?.signButtonClicked(_:)), for: .touchUpInside)
        
        submitButton?.setTitle(item.firstInputItem.title ?? "", for: .normal)
        
        submitButton?.isEnabled = item.firstInputItem.value?.toBool() ?? false
    }
}
