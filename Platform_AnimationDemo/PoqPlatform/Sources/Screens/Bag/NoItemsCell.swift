//
//  NoItemsCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 22/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

public enum EmptyCellType {
    
    case bagItems
    case wishList
    case orderHistory
    case searchHistory
    case noSearchResults
}

public protocol NoItemsCellDelegate: AnyObject {
    
    /// `NoItemsCellDelegate` function to respond to the continue shopping tapped event.
    func noItemsContinueShoppinClicked()
}

open class NoItemsCell: UITableViewCell {
    
    @IBOutlet open weak var noItemsLabel: UILabel? {
        didSet {

            noItemsLabel?.font = AppTheme.sharedInstance.noItemsLabelFont
            noItemsLabel?.textColor = AppTheme.sharedInstance.noItemsLabelColor
        }
    }

    @IBOutlet open weak var noItemsInstructionsLabel: UILabel? {

        didSet {
            noItemsInstructionsLabel?.font = AppTheme.sharedInstance.noItemsInstructionsLabelFont
            noItemsInstructionsLabel?.textColor = AppTheme.sharedInstance.noItemsInstructionsLabelColor
            noItemsInstructionsLabel?.sizeToFit()
        }
    }
    
    @IBOutlet open weak var goShoppingButton: SignButton?
    @IBOutlet open weak var bagHeart: UIImageView?
    @IBOutlet open weak var bagEmptyView: UIView?
    @IBOutlet open weak var goShoppingButtonLeadingSpace: NSLayoutConstraint?
    @IBOutlet open weak var goShoppingButtonTrailingSpace: NSLayoutConstraint?
    
    @IBOutlet open weak var textToGotShoppingButtonDistance: NSLayoutConstraint?
    @IBOutlet open weak var textCenterYConstraint: NSLayoutConstraint?
    
    open var delegate: NoItemsCellDelegate?
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        contentView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height - 108).isActive = true
        goShoppingButton?.addTarget(self, action: #selector(NoItemsCell.signButtonClicked(_:)), for: .touchUpInside)
    }
    
    open func setUp(_ cellType: EmptyCellType) {
        self.backgroundColor = AppTheme.sharedInstance.bagEmptyViewBackgroundColor
        self.backgroundView = nil
        
        switch cellType {
        case .bagItems:
            let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
            let noItemsInstructionText = String(format: AppLocalization.sharedInstance.bagNoItemsInstructionsText, bundleName)
            setUpNoBagItemsLabels(AppLocalization.sharedInstance.bagNoItemsText,
                                  noItemsInstructionsText: noItemsInstructionText,
                                  accessibilityIdentifierValue: AccessibilityLabels.emptyBag)
            setUpIcon(AppSettings.sharedInstance.bagNoItemIconName)
            
        case .wishList:
            setUpNoBagItemsLabels(AppLocalization.sharedInstance.wishListNoItemsText,
                                  noItemsInstructionsText: AppLocalization.sharedInstance.wishListNoItemsInstructionsText,
                                  accessibilityIdentifierValue: AccessibilityLabels.wishEmpty)
            setUpIcon(AppSettings.sharedInstance.wishListIconName)
            
        case .orderHistory:
            let noItemsInstructionText = String(format: AppLocalization.sharedInstance.orderListSubNoItemsText, PListHelper.sharedInstance.getValue("Bundle name"))
            setUpNoBagItemsLabels(AppLocalization.sharedInstance.orderListNoItemsText,
                                  noItemsInstructionsText: noItemsInstructionText,
                                  accessibilityIdentifierValue: AccessibilityLabels.emptyHistory)
            
        case .searchHistory:
            setUpNoBagItemsLabels(AppLocalization.sharedInstance.noSearchHistoryText,
                                  noItemsInstructionsText: "",
                                  accessibilityIdentifierValue: AccessibilityLabels.emptySearchHistory)
            setUpIcon(AppSettings.sharedInstance.searchNoItemsIconName)
            goShoppingButton?.removeFromSuperview()
            textCenterYConstraint?.constant = CGFloat(AppTheme.sharedInstance.noItemscontentCenterYConstraint) // Adjust a little to compensate the open keyboard
       
        case .noSearchResults:
            setUpNoBagItemsLabels(AppLocalization.sharedInstance.noSearchResultsText,
                                  noItemsInstructionsText: AppLocalization.sharedInstance.searchNoItemsInstructionsText,
                                  accessibilityIdentifierValue: AccessibilityLabels.emptySearchHistory)
            goShoppingButton?.removeFromSuperview()
            bagHeart?.image = nil

            textCenterYConstraint?.constant = CGFloat(AppTheme.sharedInstance.noItemscontentCenterYConstraint) // Adjust a little to compensate the open keyboard
        }
    }
    
    open func setUpNoBagItemsLabels(_ bagItemsText: String, noItemsInstructionsText: String, accessibilityIdentifierValue: String) {
        
        noItemsLabel?.text = bagItemsText
        noItemsLabel?.accessibilityIdentifier = AccessibilityLabels.noItemsLabel
        selectionStyle = UITableViewCellSelectionStyle.none
        accessibilityIdentifier = accessibilityIdentifierValue
        
        if AppSettings.sharedInstance.showGoShoppingButton {
            setUpPadConfigurationsIfApplicable()
            setUpGoShoppingButton()
            noItemsInstructionsLabel?.text = noItemsInstructionsText
            
        } else {
            noItemsInstructionsLabel?.isHidden = true
            bagHeart?.isHidden = true
            goShoppingButton?.removeFromSuperview()
        }
    }
    
    // MARK: - Private helpers

    private func setUpIcon(_ imageName: String) {
        if AppSettings.sharedInstance.showIconOnNoItemView {
            bagHeart?.image = ImageInjectionResolver.loadImage(named: imageName)
        }
    }

    open func setUpPadConfigurationsIfApplicable() {
        
        if DeviceType.IS_IPAD {
            goShoppingButtonLeadingSpace?.constant = CGFloat(AppSettings.sharedInstance.iPadGoShoppingButtonLeadingSpace)
            goShoppingButtonTrailingSpace?.constant = CGFloat(AppSettings.sharedInstance.iPadGoShoppingButtonTrailingSpace)
        }
        
        textToGotShoppingButtonDistance?.constant = CGFloat(AppSettings.sharedInstance.bagTextGoToShoppingButtonDistance)
    }

    open func setUpGoShoppingButton() {
        goShoppingButton?.setTitle(AppLocalization.sharedInstance.myProfileGoToShoppingText, for: .normal)
    }
}

// MARK: - SignButtonDelegate
extension NoItemsCell: SignButtonDelegate {
    
    @IBAction open func signButtonClicked(_ sender: Any?) {
        
        delegate?.noItemsContinueShoppinClicked()
    }
}
