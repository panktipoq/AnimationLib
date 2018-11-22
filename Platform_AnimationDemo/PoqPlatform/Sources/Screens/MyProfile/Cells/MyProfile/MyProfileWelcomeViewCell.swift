//
//  MyProfileWelcomeViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 18/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit

/// Cell that renders the welcome message in the my profile screen. TODO: We seem to not reuse block cells we need to evaluate the block cells based on requirements and not on placement in the app to optimize code reusability
class MyProfileWelcomeViewCell: FullWidthAutoresizedCollectionCell, PoqMyProfileListReusableView {
    
    /// The presenter that renders the cell
    weak public var presenter: PoqMyProfileListPresenter?

    /// The height of the cell
    static let Height: CGFloat = CGFloat(MyProfileSettings.myProfileLoggedInBannerHeight)
    
    /// The label containing the welcome message
    @IBOutlet weak var welcomeLabel: UILabel!
    
    /// Called when the cell is created from the xib
    override func awakeFromNib() {
        super.awakeFromNib()
    
        welcomeLabel.font = AppTheme.sharedInstance.loginBigTitleLabelFont
        let heightConstraint = contentView.heightAnchor.constraint(equalToConstant: MyProfileWelcomeViewCell.Height)
        heightConstraint.priority = UILayoutPriority(rawValue: 999.0)
        heightConstraint.isActive = true
        
    }

    /// Sets up the cell with the appropriate content item
    ///
    /// - Parameters:
    ///   - content: The content item used to populate the cell
    ///   - cellPresenter: The presenter that renders the cell
    func setup(using content: PoqMyProfileListContentItem, cellPresenter: PoqMyProfileListPresenter) {
        
        if let firstName = LoginHelper.getAccounDetails()?.firstName {
            
            welcomeLabel.text = "\(AppLocalization.sharedInstance.myProfileWelcomeMessage) \(firstName)"
        } else {
            
            welcomeLabel.text = AppLocalization.sharedInstance.myProfileWelcomeMessage
        }
    }
}
