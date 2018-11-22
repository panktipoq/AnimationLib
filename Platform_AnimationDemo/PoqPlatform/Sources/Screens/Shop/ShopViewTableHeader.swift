//
//  ShopViewTableHeader.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 28/05/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

open class ShopViewTableHeaderCell: UITableViewCell {
    
    
    @IBOutlet weak var customImageView: PoqAsyncImageView?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        customImageView?.prepareForReuse()
        
    }
    
    open func setUp(_ pictureName: String) {
        guard let pictureURL = URL(string:pictureName) else {
            return
        }
        customImageView?.getImageFromURL(pictureURL, isAnimated: true)
        selectionStyle = UITableViewCellSelectionStyle.none

    }
}
