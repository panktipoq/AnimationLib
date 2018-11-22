//
//  PoqBlockOnboardingExtension.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 12/21/16.
//
//

import Foundation
import PoqNetworking
import PoqUtilities

extension PoqBlockType {
    
    static let onboardingSupportedBlockTypes: [PoqBlockType] = [.banner, .link, .seperator, .title, .description] 

    var onboardingCellClass: UICollectionViewCell.Type {
        switch self {
        case .banner: 
            return OnboardingBannerBlockCell.self
        case .link: 
            return OnboardingLinkBlockCell.self
        case .seperator: 
            return OnboardingSeparatorBlockCell.self
        case .title: 
            return OnboardingTitleBlockCell.self
        case .description: 
            return OnboardingDescriptionBlockCell.self
        default:
            Log.error("We are trying to use unsupported cell on onboarding, self = \(self.rawValue)")
            return NotFoundContentCollectionViewCell.self
        }
        
    }
}


