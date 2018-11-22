//
//  OnboardingBannerBlockCell.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 1/11/17.
//
//

import Foundation
import PoqNetworking
import UIKit

class OnboardingBannerBlockCell: FullWidthAutoresizedCollectionCell, OnboardingBlockCell {
    
    @IBOutlet weak var bannerImage: PoqAsyncImageView?
    
    var rationConstraint: NSLayoutConstraint?
    
    func setup(using block: PoqBlock) {
        guard let pictureURLString = block.pictureURL, let pictureURL = URL(string: pictureURLString) else {
            return
        }
        bannerImage?.getImageFromURL(pictureURL, isAnimated: false)
        bannerImage?.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        rationConstraint?.isActive = false
        
        bannerImage?.translatesAutoresizingMaskIntoConstraints = false
        
        if let existedImageView = bannerImage, block.pictureHeight > 0 {
            let multiplier = CGFloat(block.pictureWidth)/CGFloat(block.pictureHeight)
            
            rationConstraint = existedImageView.widthAnchor.constraint(equalTo: existedImageView.heightAnchor, multiplier: multiplier)

            // we just need it less than required to make sure, no alert because of tenporary sizings on cell, between collectionview layouts
            rationConstraint?.priority = UILayoutPriority(rawValue: 999)
            rationConstraint?.isActive = true
        }
    }
}
