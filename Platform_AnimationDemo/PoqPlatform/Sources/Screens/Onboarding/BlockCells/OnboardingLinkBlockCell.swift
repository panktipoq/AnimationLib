//
//  OnboardingLinkBlockCell.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/11/17.
//
//

import Foundation
import PoqNetworking
import UIKit

open class OnboardingLinkBlockCell:  FullWidthAutoresizedCollectionCell, OnboardingBlockCell {
    @IBOutlet weak var titleLabel: UILabel?
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel?.font = AppTheme.sharedInstance.onboardingLinkBlockFont
        titleLabel?.textColor = AppTheme.sharedInstance.onboardingLinkBlockColor
    }
    
    open func setup(using block: PoqBlock) {
        
        titleLabel?.text = block.title
    }
}

