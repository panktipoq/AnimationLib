//
//  GifBannerCell.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 11/30/16.
//
//

import Foundation
import PoqUtilities
import UIKit

public class GifBannerCell: UICollectionViewCell {
    
    public var imageView: PoqGifImageView
    public var topConstraint: NSLayoutConstraint
    public var bottomConstraint: NSLayoutConstraint
    public var rightConstraint: NSLayoutConstraint
    public var leftConstraint: NSLayoutConstraint
    
    public override init(frame: CGRect) {
        imageView = PoqGifImageView()
        topConstraint = NSLayoutConstraint()
        leftConstraint = NSLayoutConstraint()
        rightConstraint = NSLayoutConstraint()
        bottomConstraint = NSLayoutConstraint()
        
        super.init(frame: frame)
        addSubview(imageView)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = imageView.topAnchor.constraint(equalTo: topAnchor)
        leftConstraint = imageView.leadingAnchor.constraint(equalTo: leadingAnchor)
        rightConstraint = imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        bottomConstraint = imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([topConstraint, leftConstraint, rightConstraint, bottomConstraint])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func updateGif(forUrl url: URL, padding: UIEdgeInsets = UIEdgeInsets.zero) {
        // Set the new gif
        imageView.animateGif(url)
        
        // Deactive constraints so we can change the padding that is sent from the CMS
        NSLayoutConstraint.deactivate([topConstraint, leftConstraint, rightConstraint, bottomConstraint])
        topConstraint.constant = padding.top
        leftConstraint.constant = padding.left
        rightConstraint.constant = -padding.right
        bottomConstraint.constant = -padding.bottom
        // Active them back
        NSLayoutConstraint.activate([topConstraint, leftConstraint, rightConstraint, bottomConstraint])
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.stopFetchingAndAnimation()
    }
}

extension GifBannerCell: HomeBannerCell {

    public func updateUI(_ bannerItem: HomeBannerItem, delegate: HomeViewController) {
        guard let urlString = bannerItem.poqHomeBanner?.url, let url = URL(string: urlString) else {
            Log.error("We can't convert urlString to URL, urlString = \(bannerItem.poqHomeBanner?.url ?? "")")
            imageView.stopFetchingAndAnimation()
            return
        }
        let padding = UIEdgeInsets(top: CGFloat(bannerItem.poqHomeBanner?.paddingTop ?? 0),
                                   left: CGFloat(bannerItem.poqHomeBanner?.paddingLeft ?? 0),
                                   bottom: CGFloat(bannerItem.poqHomeBanner?.paddingBottom ?? 0),
                                   right: CGFloat(bannerItem.poqHomeBanner?.paddingRight ?? 0))
        updateGif(forUrl: url, padding: padding)
    }
}
