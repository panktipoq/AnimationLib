//
//  LinkView.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 17/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import UIKit

public protocol PoqLinkBlock {
    
    func openLink(_ deepLinkURL: String?)
    
    func setTitle(_ title: String?, titleLabel: UILabel?)
    
    func setImage(_ imageURL: String?, imageView: PoqAsyncImageView?)
}

extension PoqLinkBlock {
    
    public func setTitle(_ title: String?, titleLabel: UILabel?) {
        
        titleLabel?.font = AppTheme.sharedInstance.profileLinkFont
        titleLabel?.text = title
    }
    
    public func setImage(_ imageURL: String?, imageView: PoqAsyncImageView?) {
        
        guard let image = imageURL else {
            
            return
        }
        
        guard let url = URL(string: image) else {
            
            return
        }
        imageView?.prepareForReuse()
        imageView?.fetchImage(from: url, isAnimated: false)
    }
    
    public func openLink(_ deepLinkURL: String?) {
        
        guard let link: String = deepLinkURL, link.count > 0 else {
            
            return
        }

        NavigationHelper.sharedInstance.openURL(link)
        
    }
}
