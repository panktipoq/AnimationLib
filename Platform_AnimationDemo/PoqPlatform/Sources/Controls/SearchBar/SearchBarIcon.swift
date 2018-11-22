//
//  SearchBar.swift
//  Poq.iOS
//
//  Created by Jun Seki on 01/05/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

class SearchBarIcon: UIImageView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initSearchBarIcon()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSearchBarIcon()
    }
    
    func initSearchBarIcon() {
        var searchBarIcon: UIImage? = ImageInjectionResolver.loadImage(named: "SearchBarIcon")
        
        if searchBarIcon == nil {
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 2.0)
            ResourceProvider.sharedInstance.homePageStyle?.drawSearchBarIcon(frame: bounds)
            searchBarIcon = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        image = searchBarIcon
    }
    
}
