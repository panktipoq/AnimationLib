//
//  MyProfileCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/25/16.
//
//

import Foundation

/// This is owr accumulative delegate
/// If any specific VC don't support cell and its delegate, left implementation empty
public protocol MyProfileCellsDelegate: DatePickerCellDelegate, GenderCellDelegate, SignButtonDelegate, SwitchCellDelegate, UITextFieldDelegate, UIWebViewDelegate {

}

/// Our way configure cell according to data specifically for this screen
public protocol MyProfileCell: PoqReusableView {

    /// Update UI according to MyProfileInputItem. Delegate will be used to set delegate of elements, if needed in cell
    func updateUI(_ item: MyProfileContentItem, delegate: MyProfileCellsDelegate?)
}

extension FloatLabelTextFieldStyling {
    
   /// Convenience method for creating default my profile float label textfield styling
   ///
   /// - Returns: Default FloatLabelTextFieldStyling styling
   public static func createDefaultMyProfileStyling() -> FloatLabelTextFieldStyling {
        var styling = FloatLabelTextFieldStyling()
        styling.placehoderColor = AppTheme.sharedInstance.signInRegisterInputPlaceHolderColor
        
        styling.idleTextColor = UIColor.black
        styling.editingTextColor = UIColor.black
        
        styling.idleTitleColor = AppTheme.sharedInstance.signInRegisterInputPlaceHolderColor
        styling.editingTitleColor = AppTheme.sharedInstance.mainColor
        
        styling.idleErrorMessageColor = UIColor.red
        styling.editingErrorMessageColor = UIColor.red
        
        return styling 
    }
}
