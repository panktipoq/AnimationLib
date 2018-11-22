//
//  WishListWishListCloseButton.swift
//  Poq.iOS
//
//  Created by Jun Seki on 21/08/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

open class WishListCloseButton: UIButton {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initWishListCloseButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWishListCloseButton()
    }
    
    func initWishListCloseButton() {
        configurePoqButton(style: ResourceProvider.sharedInstance.clientStyle?.wishListCloseButtonStyle)
    }
    
}
