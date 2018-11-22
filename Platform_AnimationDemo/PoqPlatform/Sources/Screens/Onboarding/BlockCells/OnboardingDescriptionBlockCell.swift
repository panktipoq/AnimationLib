//
//  OnboardingDescriptionBlockCell.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/13/17.
//
//

import Foundation
import PoqNetworking

open class OnboardingDescriptionBlockCell: FullWidthAutoresizedCollectionCell, OnboardingBlockCell {
    
    @IBOutlet weak var descriptionLabel: UILabel? {
        didSet {
            descriptionLabel?.font = AppTheme.sharedInstance.onboardingDescriptionBlockFont
            descriptionLabel?.textColor = AppTheme.sharedInstance.onboardingDescriptionBlockColor
        }
    }
    
    func setup(using block: PoqBlock) {
        
        descriptionLabel?.text = block.description
    }

}
