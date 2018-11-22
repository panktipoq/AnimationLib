//
//  BrandLandingImageCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 01/06/2016.
//
//

import PoqNetworking
import UIKit

final class StoryDetailImageCell: UICollectionViewCell {

    @IBOutlet weak final var imageView: PoqAsyncImageView?

    @IBOutlet weak final var textLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        textLabel?.font = AppTheme.sharedInstance.brandImageCategoryFont
    }
}

extension StoryDetailImageCell: StoryDetailBlockCell {
    static func sizeForItem(_ item: PoqBlock) -> CGSize {
        let width: CGFloat = floor(0.5 * UIScreen.main.bounds.size.width)
        
        // TODO: make calculation on text height
        let height: CGFloat = width / AppSettings.sharedInstance.brandingLandingImageRatio + 55
        return CGSize(width: width, height: height)
    }
    
    func updateUI(_ item: PoqBlock) {
        
        textLabel?.text = item.title
        
        if let urlString: String = item.pictureURL, let url: URL = URL(string: urlString) {
            imageView?.getImageFromURL(url, isAnimated: false, showLoadingIndicator: true)
        } else {
            imageView?.image = nil
        }
    }
}

