//
//  SearchBar.swift
//  Poq.iOS
//
//  Created by Jun Seki on 01/05/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

@objc protocol SearchBarBackgroundDelegate: AnyObject {
    func searchBarBackgroundClicked()
}

open class SearchBarBackground: UIView {
    
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = AccessibilityLabels.searchBackgroundView
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.accessibilityIdentifier = AccessibilityLabels.searchBackgroundView        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        addSearchBarBackground()
    }
    
    func addSearchBarBackground() {
        
        imageView?.removeFromSuperview()
        imageView = UIImageView(frame: bounds)
        
        var searchBarBackgroundImage: UIImage? = ImageInjectionResolver.loadImage(named: "SearchBarBackground")
        
        if searchBarBackgroundImage == nil {
            UIGraphicsBeginImageContextWithOptions(bounds.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawSearchBarBackground(frame: bounds)
            searchBarBackgroundImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        imageView?.image = searchBarBackgroundImage
        
        if let imageViewUnwrapped = imageView {
            insertSubview(imageViewUnwrapped, at: 0)
        }
    }
}
