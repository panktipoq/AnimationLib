//
//  BannerCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 21/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqUtilities
import UIKit

public class BannerCell: UICollectionViewCell {
    
    public var imageView: PoqAsyncImageView?
    public var topConstraint: NSLayoutConstraint?
    public var bottomConstraint: NSLayoutConstraint?
    public var rightConstraint: NSLayoutConstraint?
    public var leftConstraint: NSLayoutConstraint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = PoqAsyncImageView(frame: frame)
        topConstraint = NSLayoutConstraint()
        leftConstraint = NSLayoutConstraint()
        rightConstraint = NSLayoutConstraint()
        bottomConstraint = NSLayoutConstraint()
        
        guard let imageView = imageView else {
            Log.error("Couldn't get the image view")
            return
        }
        addSubview(imageView)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = imageView.topAnchor.constraint(equalTo: topAnchor)
        leftConstraint = imageView.leadingAnchor.constraint(equalTo: leadingAnchor)
        rightConstraint = imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        bottomConstraint = imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        guard let topConstraint = topConstraint, let leftConstraint = leftConstraint,
            let rightConstraint = rightConstraint, let bottomConstraint = bottomConstraint else {
            Log.error("Couldn't get constraints")
            return
        }
        NSLayoutConstraint.activate([topConstraint, leftConstraint, rightConstraint, bottomConstraint])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func updateImage(_ url: URL, forPadding padding: UIEdgeInsets = UIEdgeInsets.zero) {

        // Set the new image
        imageView?.fetchOriginalImage(from: url, isAnimated: true, showLoading: true)

        guard let topConstraint = topConstraint, let leftConstraint = leftConstraint,
            let rightConstraint = rightConstraint, let bottomConstraint = bottomConstraint else {
                Log.error("Couldn't get constraints")
                return
        }
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
        imageView?.prepareForReuse()
    }
}

// MARK: HomeBannerCell
extension BannerCell: HomeBannerCell {
    
    public func updateUI(_ bannerItem: HomeBannerItem, delegate: HomeViewController) {
        guard let urlString = bannerItem.poqHomeBanner?.url, let url = URL(string: urlString) else {
            Log.error("We can't convert urlString to URL, urlString = \(String(describing: bannerItem.poqHomeBanner?.url))")
            imageView?.prepareForReuse()
            return
        }
        
        let padding = UIEdgeInsets(top: CGFloat(bannerItem.poqHomeBanner?.paddingTop ?? 0),
                                   left: CGFloat(bannerItem.poqHomeBanner?.paddingLeft ?? 0),
                                   bottom: CGFloat(bannerItem.poqHomeBanner?.paddingBottom ?? 0),
                                   right: CGFloat(bannerItem.poqHomeBanner?.paddingRight ?? 0))
        updateImage(url, forPadding: padding)
    }
}
