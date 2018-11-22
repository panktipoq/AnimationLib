//
//  OnboardingSeparatorBlockCell.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/11/17.
//
//

import Foundation
import PoqNetworking
import UIKit

open class OnboardingSeparatorBlockCell: FullWidthAutoresizedCollectionCell, OnboardingBlockCell {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        let height = CGFloat(AppSettings.sharedInstance.onboardingSeparatorHeight) 
        let heightConstraint = contentView.heightAnchor.constraint(equalToConstant: height)

        // we need a little bit less than UILayoutPriorityRequired
        // to avoid problem with autoresizing masks
        heightConstraint.priority = UILayoutPriority(rawValue: 999.0)
        heightConstraint.isActive = true
    }
    
    func setup(using block: PoqBlock) {

    }
}
