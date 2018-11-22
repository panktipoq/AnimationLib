//
//  PageListTableViewCell.swift
//  Poq.iOS
//
//  Created by Huishan Loh on 05/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

open class PageListTableViewCell: UITableViewCell {

    @IBOutlet open weak var pageListImageView: PoqAsyncImageView!
    @IBOutlet open weak var pageListLabel: UILabel!
    @IBOutlet open weak var imageViewWidthConstant: NSLayoutConstraint!
    
    open var poqPage: PoqPage?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        pageListLabel?.textColor = AppTheme.sharedInstance.mainTextColor
        pageListLabel?.font = AppTheme.sharedInstance.pagelistCellLabelFont
        pageListLabel?.adjustsFontSizeToFitWidth = AppSettings.sharedInstance.displayFAQTextWithShrinkToSize
        pageListLabel?.numberOfLines = 1
        pageListLabel?.minimumScaleFactor = 1
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    open func setTableCellData(_ pageListItem:PoqPage) {
        
        self.poqPage = pageListItem
        
        if let iconURL = pageListItem.iconThumbnailUrl {
            
            // Hide image view for "image not available" images
            // Change width for resusability issues
            
            
            if  pageListItem.iconThumbnailUrl == AppSettings.sharedInstance.ignoreImageURL || iconURL.isEmpty {
                
                self.imageViewWidthConstant.constant = 0
            }
            else {
                
                self.pageListImageView.getImageFromURL(URL(string:iconURL)!, isAnimated: true)
                self.imageViewWidthConstant.constant = 50
            }

        }
        else {
            
            self.imageViewWidthConstant.constant = 0
        }
        
        
        
        self.pageListLabel?.text = self.poqPage?.title
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        self.pageListImageView.prepareForReuse()
    }

}
