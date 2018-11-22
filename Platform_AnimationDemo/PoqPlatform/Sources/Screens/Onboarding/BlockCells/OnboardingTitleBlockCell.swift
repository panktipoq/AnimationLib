//
//  OnboardingTitleBlockCell.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/11/17.
//
//

import Foundation
import PoqNetworking

open class OnboardingTitleBlockCell: FullWidthAutoresizedCollectionCell, OnboardingBlockCell {
    
    @IBOutlet weak var titleLabel: UILabel?
    
    override open func awakeFromNib() {
        super.awakeFromNib()

            titleLabel?.font = AppTheme.sharedInstance.onboardingTiteBlockFont
            titleLabel?.textColor = AppTheme.sharedInstance.onboardingTiteBlockColor
    }
    
    func setup(using block: PoqBlock) {

        titleLabel?.text = block.title
    }
}
