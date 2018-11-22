//
//  BrandLandingBannerCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 01/06/2016.
//
//

import PoqNetworking
import UIKit

class StoryDetailBannerCell: UICollectionViewCell {

    @IBOutlet weak var imageView: PoqAsyncImageView?
    
    weak var textLabel: UILabel? {
        get {return nil}
        set {}
    }
    
}

extension StoryDetailBannerCell: StoryDetailBlockCell {
    
    static func sizeForItem(_ item: PoqBlock) -> CGSize {

        let width: CGFloat = UIScreen.main.bounds.size.width
        
        var ratio: CGFloat = 1
        if item.pictureWidth > 0 && item.pictureHeight > 0 {
            ratio = CGFloat(item.pictureWidth) / CGFloat(item.pictureHeight)
        }
        
        // TODO: make calculation depended on real image size
        let height: CGFloat = width / ratio
        return CGSize(width: width, height: height)
    }
    
    func updateUI(_ item: PoqBlock) {

        if let urlString: String = item.pictureURL, let url: URL = URL(string: urlString) {
            imageView?.getImageFromURL(url, isAnimated: false, showLoadingIndicator: true)
        } else {
            imageView?.image = nil
        }
    }
}
