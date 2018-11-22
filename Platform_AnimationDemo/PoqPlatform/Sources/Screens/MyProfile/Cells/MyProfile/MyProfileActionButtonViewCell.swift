//
//  MyProfileActionButtonViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 17/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation

/// A full width block cell containing one button that can trigger a specific action
class MyProfileActionButtonViewCell: FullWidthAutoresizedCollectionCell, PoqMyProfileListReusableView {
    
    /// The my profile presenter on which my profile specific actions will be called
    weak public var presenter: PoqMyProfileListPresenter?
    
    /// The action presenter on which custom button action will be called
    weak var actionButtonViewDelegate: PoqActionButtonBlock?
    
    /// The height of the cell
    static let Height: CGFloat = CGFloat(MyProfileSettings.myProfileActionButtonHeight)
    
    /// The type of action performed
    var actionType: PoqActionButtonType?
    
    /// The action button in the cell
    @IBOutlet weak var actionButton: UIButton!
    
    /// Triggered when the view is created from the xib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let hConstraint = contentView.heightAnchor.constraint(equalToConstant: MyProfileActionButtonViewCell.Height)
        hConstraint.priority = UILayoutPriority(rawValue: 999.0)
        hConstraint.isActive = true
        
        let buttonTitle = AppLocalization.sharedInstance.myProfileLogoutActionButtonTitle
        let buttonStyle = ResourceProvider.sharedInstance.clientStyle?.primaryButtonStyle
        actionButton.configurePoqButton(withTitle: buttonTitle, using: buttonStyle)
        actionButton.accessibilityIdentifier = AccessibilityLabels.logoutButton
    }
    
    /// Sets up the cell's presenter and action type
    ///
    /// - Parameters:
    ///   - content: The content item that populates the cell
    ///   - presenter: The presenter that will be called when actions are performed
    func setup(using content: PoqMyProfileListContentItem, cellPresenter presenter: PoqMyProfileListPresenter) {
        
        guard let validPresenter = presenter as? PoqActionButtonBlock else {
            return
        }
        
        actionButtonViewDelegate = validPresenter
        actionType = PoqActionButtonType.logout
    }
    
    /// Called when the action button has been tapped
    ///
    /// - Parameter sender: The object that triggered the action
    @IBAction private func actionButtonTapped(_ sender: UIButton!) {
        actionButtonViewDelegate?.triggerAction(actionType)
    }
}
