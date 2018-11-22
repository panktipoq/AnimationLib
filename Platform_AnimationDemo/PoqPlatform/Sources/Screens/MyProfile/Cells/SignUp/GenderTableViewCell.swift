//
//  GenderTableViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 25/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

/// Protocol used to make a delegate call to the 
public protocol GenderCellDelegate: AnyObject {
    func genderSelected(_ isFemale: Bool)
}

/// Cell used to select the user's gender. TODO: This could be a switch table view cell for reusability purpuoses
open class GenderTableViewCell: UITableViewCell {

    /// The title label of the cell
    @IBOutlet weak var leftLabel: UILabel?
    
    /// The female label
    @IBOutlet weak var femaleLabel: UILabel?
    
    /// The male label
    @IBOutlet weak var maleLabel: UILabel?
    
    /// The delegate used to make the action calls
    public weak var delegate: GenderCellDelegate?
    
    /// Gender of the user as expressed in boolean
    var female: Bool?
    
    /// Triggered when the cell is created from xib
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
        leftLabel?.font = AppTheme.sharedInstance.signUpPromotionFont
        leftLabel?.text = AppLocalization.sharedInstance.signUpGenderText
        
        femaleLabel?.font = AppTheme.sharedInstance.signUpPromotionFont
        femaleLabel?.text = "FEMALE".localizedPoqString
        let femaleTap = UITapGestureRecognizer(target: self, action: #selector(GenderTableViewCell.femaleSelected))
        femaleLabel?.isUserInteractionEnabled = true
        femaleLabel?.addGestureRecognizer(femaleTap)
        
        maleLabel?.font = AppTheme.sharedInstance.signUpPromotionFont
        maleLabel?.text = "MALE".localizedPoqString
        let maleTap = UITapGestureRecognizer(target: self, action: #selector(GenderTableViewCell.maleSelected))
        maleLabel?.isUserInteractionEnabled = true
        maleLabel?.addGestureRecognizer(maleTap)
    }
    
    /// Toggles between the user's gender TODO: Rename this to setGender or make it toggle between existing state
    ///
    /// - Parameter isFemale: Wether the user has set gender to male or female
    public func toggleSelection(_ isFemale: Bool) {
        
        femaleLabel?.font = isFemale ? AppTheme.sharedInstance.signUpPromotionBoldFont : AppTheme.sharedInstance.signUpPromotionFont
        maleLabel?.font = !isFemale ? AppTheme.sharedInstance.signUpPromotionBoldFont : AppTheme.sharedInstance.signUpPromotionFont
        
        femaleLabel?.textColor = isFemale ? AppTheme.sharedInstance.mainColor : UIColor.gray
        maleLabel?.textColor = !isFemale ? AppTheme.sharedInstance.mainColor : UIColor.gray
        
        self.female = isFemale
        delegate?.genderSelected(isFemale)
    }
    
    /// Sets the gender to female
    @objc func femaleSelected() {
        toggleSelection(true)
    }
    
    /// Sets the gender to male
    @objc func maleSelected() {
        toggleSelection(false)
    }
}

// MARK: - MyProfileCell implementation
extension GenderTableViewCell: MyProfileCell {
    
    /// Updates the UI accordingly
    ///
    /// - Parameters:
    ///   - item: The content item that populates the cell
    ///   - delegate: The delegate that receives the calls as a result of the cell actions
    public func updateUI(_ item: MyProfileContentItem, delegate: MyProfileCellsDelegate?) {
        
        self.delegate = delegate
        
        guard let value = item.firstInputItem.value else {
            // user did't make selection yes, we should not predefinde gender
            return
        }
        let isFemale: Bool = value.toBool()
        toggleSelection(isFemale)
    }
}
