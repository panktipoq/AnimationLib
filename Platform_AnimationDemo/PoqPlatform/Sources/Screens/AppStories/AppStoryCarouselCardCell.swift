//
//  AppStoryCarouselCardCell.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 8/1/17.
//
//

import Foundation
import PoqNetworking
import UIKit

let AppStoryCarouselCardAccessibilityIdBase = "AppStoryCarouselCard_"
let AppStoryCarouselCardUnviewedLabelAccessibilityIdBase = "AppStoryCarouselCardUnviewedLabel_"

class AppStoryCarouselCardCell: UICollectionViewCell, AppStoryCell {
    
    @IBOutlet weak var imageView: PoqAsyncImageView?
    
    @IBOutlet var unviewedStoryLabelContainer: UIView? {
        didSet {
            unviewedStoryLabelContainer?.isHidden = true
            unviewedStoryLabelContainer?.backgroundColor = AppTheme.sharedInstance.appStoryNewStoryLabelColor
        }
    }
    
    @IBOutlet var unviewedStoryLabel: UILabel? {
        didSet {
            unviewedStoryLabel?.text = AppLocalization.sharedInstance.appStoryNewStoryLabelText
            unviewedStoryLabel?.font = AppTheme.sharedInstance.appStoryNewStoryLabelFont
            unviewedStoryLabel?.textColor = AppTheme.sharedInstance.appStoryNewStoryLabelTextColor
        }
    }
    
    func setup(using storyItem: AppStoryCarouselContentItem) {
        isUserInteractionEnabled = true
        imageView?.contentMode = .scaleAspectFill
        imageView?.fetchImage(from: storyItem.story.imageUrl)
        
        unviewedStoryLabelContainer?.accessibilityIdentifier = AppStoryCarouselCardUnviewedLabelAccessibilityIdBase + storyItem.story.identifier
        storyHasBeenRead(storyItem.isViewed)
        
        accessibilityIdentifier = AppStoryCarouselCardAccessibilityIdBase + storyItem.story.identifier
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.prepareForReuse()
    }
    
    func storyHasBeenRead(_ hasBeenViewed: Bool) {
        unviewedStoryLabelContainer?.isHidden = hasBeenViewed
    }
    
}
