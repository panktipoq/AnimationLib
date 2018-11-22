//
//  Label+SwitchTableViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 24/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

/// Switch cell delegate
public protocol SwitchCellDelegate: AnyObject {
    
    func switchOn(_ cellTag: Int, isOn: Bool)
    
    /// Specific callback of Switch Cell used for T&C and Policy
    func switchCell(_ cell: SwitchTableViewCell, didInteractWith URL: URL)
    
    /// Provide Styling for T&C and Policy when needed
    func switchCell(_ cell: SwitchTableViewCell, requiresStylingForTermsAndPolicy: String?) -> NSAttributedString?
}

/// Switch cell tabl view cell
open class SwitchTableViewCell: UITableViewCell, MyProfileCell, UITextViewDelegate {

    /// The title label of the cell
    @available(*, deprecated, message: "Use titleTextView instead.")
    @IBOutlet open weak var titleLabel: UILabel? {
        didSet {
            titleLabel?.font = AppTheme.sharedInstance.signUpPromotionFont
        }
    }
    
    @IBOutlet open weak var titleTextView: UITextView? {
        didSet {
            // Remove Paddings
            titleTextView?.textContainerInset = .zero
            titleTextView?.contentInset = .zero
            
            titleTextView?.font = AppTheme.sharedInstance.signUpPromotionFont
        }
    }
    
    /// Object is no longer in use
    @available(*, deprecated, message: "No longer in use.")
    @IBOutlet open weak var subTitleLinkButton: UIButton?
    
    /// The bottom solid line 
    @IBOutlet open weak var solidLine: SolidLine?
    
    /// The UI Switch of the cell
    @IBOutlet weak var optionSwitch: UISwitch?
    
    /// The delegate used for the switch cell
    open weak var delegate: SwitchCellDelegate?
    
    /// The cell's tag
    var cellTag: Int = 0
    
    /// Sets up the cell accordingly
    ///
    /// - Parameters:
    ///   - labelText: The text of the label
    ///   - switchOn: Set the switch to on
    ///   - tag: The tag of the cell
    ///   - noSeparator: Wether or not to show a separator
    ///   - subTitleLinkButtonTitle: The subtitle link TODO: This is not used anymore and needs to be removed
    @available(*, deprecated, message: "Use updateUI(_:delegate:) instead.")
    open func setUpCell(_ labelText: String, switchOn: Bool, tag: Int, noSeparator: Bool = false, subTitleLinkButtonTitle: String? = nil) {
        
        titleLabel?.text = labelText
        titleTextView?.text = labelText
        
        if let subtitle = subTitleLinkButtonTitle {
            subTitleLinkButton?.titleLabel?.text = subtitle
        } else {
            subTitleLinkButton?.removeFromSuperview()
            subTitleLinkButton = nil
        }
        
        if DeviceType.IS_IPAD {
            titleLabel?.textAlignment = NSTextAlignment.center
        }
        
        cellTag = tag
        optionSwitch?.setOn(switchOn, animated: true)
        
        solidLine?.isHidden = noSeparator
    }

    /// Triggered when the UISwitch has changed states
    ///
    /// - Parameter switchState: UISwitch that changed TODO: This is not the state of the switch
    @IBAction func stateChanged(_ switchState: UISwitch) {
        delegate?.switchOn(cellTag, isOn: switchState.isOn)
    }
    
    /// Updates the cell UI accordingly
    ///
    /// - Parameters:
    ///   - item: The content item used to populate the cell
    ///   - delegate: The delegate that that gets called as a result of the cell actions
    open func updateUI(_ item: MyProfileContentItem, delegate: MyProfileCellsDelegate?) {
        
        // I will leave titleLabel setup for now until all clients are updated
        titleLabel?.text = item.firstInputItem.title
        titleTextView?.text = item.firstInputItem.title
        
        if DeviceType.IS_IPAD {
            titleLabel?.textAlignment = .center
            titleTextView?.textAlignment = .center
        }
        
        if item.type == .termsAndConditions, let termsStyling = delegate?.switchCell(self, requiresStylingForTermsAndPolicy: item.firstInputItem.title) {
            
            titleTextView?.text = nil
            titleTextView?.attributedText = termsStyling
        }
        
        cellTag = item.firstInputItem.controlTag.rawValue
        optionSwitch?.tag = cellTag
        
        let switchOn: Bool = item.firstInputItem.value?.toBool() ?? false 
        optionSwitch?.setOn(switchOn, animated: true)
        
        self.delegate = delegate
    }
    
    // MARK: - UITextViewDelegate protocol
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if let delegate = delegate {
            delegate.switchCell(self, didInteractWith: URL)
            return false
        }
        
        return true
    }
}
