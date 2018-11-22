//
//  FavoriteStoreButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 27/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

open class FavoriteStoreButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initFavouriteStoreButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initFavouriteStoreButton()
    }
    
    func initFavouriteStoreButton() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.likeButtonStyle)
    }
}
