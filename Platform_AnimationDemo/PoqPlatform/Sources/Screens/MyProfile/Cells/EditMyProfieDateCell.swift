//
//  EditMyProfieDateCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/27/16.
//
//

import UIKit

/// The my profile cell that renders the date 
class EditMyProfieDateCell: UITableViewCell {
    
    /// The label rednering the date
    @IBOutlet var dateLabel: UILabel?
    
    /// The bottom underline
    @IBOutlet weak var solidLine: SolidLine?

    /// Triggered when the cell is created from the xib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateLabel?.font = AppTheme.sharedInstance.signUpTextFieldFont
    }
    
}

// MARK: - MyProfileCell implementations
extension EditMyProfieDateCell: MyProfileCell {
    
    /// Updates the UI accordingly
    ///
    /// - Parameters:
    ///   - item: The content item that is used to populate the cell
    ///   - delegate: The delegate that will receive the calls as a result of the cell's actions
    func updateUI(_ item: MyProfileContentItem, delegate: MyProfileCellsDelegate?) {
        if let value = item.firstInputItem.value {
            dateLabel?.text = value
            dateLabel?.textColor = AppTheme.sharedInstance.mainColor
        } else {
            dateLabel?.text = item.firstInputItem.title
            dateLabel?.textColor = AppTheme.sharedInstance.editMyProfileBirthdayPlaceholderColor
        }
    }
}
