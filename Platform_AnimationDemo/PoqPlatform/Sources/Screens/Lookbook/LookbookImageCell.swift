//
//  LookbookImageCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 07/10/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation

open class LookbookImageCell: UICollectionViewCell {
    
    @IBOutlet weak var container: UIView!
    var lookbookView:UIView?
    
    public func setupView(_ view:UIView) {
        
        lookbookView?.removeFromSuperview()
        container.addSubview(view)
        lookbookView = view
        lookbookView?.frame = container.bounds
        lookbookView?.layoutIfNeeded()
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        lookbookView?.removeFromSuperview()
    }
}
