//
//  MyProfileRewardCardInfoViewCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 09/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

/// Cell used to render the reward card information
open class MyProfileRewardCardInfoViewCell : UICollectionViewCell {
    
    /// The image representation of the card
    @IBOutlet open  weak var image: PoqAsyncImageView!
    
    /// The description of the reward card option
    @IBOutlet open weak var descriptionLabel: UILabel!
    
    /// n/a Not used
    @IBOutlet open weak var moreButton: UIView!
    
    /// The title of the reward card option
    @IBOutlet open weak var titleLabel: UILabel!
    
    /// n/a ducplicate of descriptionLabel
    @IBOutlet open weak var collectPoints: UILabel!
    
    /// Called when the cell is on Screen
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Updates the view with the appopriate data
    open func updateView(){
        
        image?.getImageFromURL(URL(string: AppSettings.sharedInstance.myProfileRewardCardInfoImage)!, isAnimated: true)
        titleLabel?.text = AppLocalization.sharedInstance.myProfileRewardCardInfoTitle
        descriptionLabel?.text = AppLocalization.sharedInstance.myProfileRewardCardInfoDescription
        self.collectPoints?.text = AppLocalization.sharedInstance.myProfileCollectPointsText
    }
    
    /// Called if the view is disabled. Stub
    open func disableView() {
        
    }
}
