//
//  MyProfileSizeViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 09/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit

/// A cell containing a single UILabel that renders a section title
open class MyProfileTitleViewCell: FullWidthAutoresizedCollectionCell, PoqMyProfileListReusableView {

    /// The presenter on which the cell is rendered
    weak public var presenter: PoqMyProfileListPresenter?
    
    /// The label that renders the title text
    @IBOutlet open weak var titleLabel: UILabel? {
        didSet {
            titleLabel?.font = AppTheme.sharedInstance.profileTitleFont
            titleLabel?.textColor = AppTheme.sharedInstance.profileTitleLabelTextColor
            titleLabel?.sizeToFit()
            titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    /// Container that is removed if the cell is disabled. TODO: This seems to be some legacy code that we can remove
    open var disabledView: UIView?
    
    /// Triggered when the cell is created from xib
    open override func awakeFromNib() {
        super.awakeFromNib()
        let heightConstraint = contentView.heightAnchor.constraint(equalToConstant: AppSettings.sharedInstance.myProfileTitleViewCellHeight)
        heightConstraint.priority = UILayoutPriority(rawValue: 999.0)
        heightConstraint.isActive = true
    }
    
    /// Called when the cell is on Screen
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Updates the view accordingly to the state
    open func updateView() {
        
        if let disabled = self.disabledView {
            
            disabled.removeFromSuperview()
        }
    }
    
    /// Called when the view is cell is disabled
    open func disableView() {
        
        if let disabled = self.disabledView {
            
            disabled.removeFromSuperview()
        }
        
        self.disabledView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        self.disabledView?.backgroundColor = UIColor.white
        self.disabledView?.alpha = 0.8
        if let disabledView = disabledView {
            self.addSubview(disabledView)
        }
    }
    
    /// Sets up the cell with the appropriate content
    ///
    /// - Parameters:
    ///   - content: The content item used to populate the cell
    ///   - presenter: The presenter that renders the cell
    open func setup(using content: PoqMyProfileListContentItem, cellPresenter presenter: PoqMyProfileListPresenter) {
        guard let block = content.block else {
            return
        }
        titleLabel?.text = block.title
    }
}

// MARK: - The block cell implementation for the cell. The cell is used in the onboarding flow as well
extension MyProfileTitleViewCell: OnboardingBlockCell {
    
    /// Sets up the cell with the appropriate block object
    ///
    /// - Parameter block: The block that is used to populate the cell
    func setup(using block: PoqBlock) {
        titleLabel?.text = block.title
        titleLabel?.textAlignment = NSTextAlignment.center
        backgroundColor = UIColor.clear
    }
}
