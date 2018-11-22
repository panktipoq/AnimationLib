//
//  CheckoutBagItemsCell
//  Poq.iOS
//
//  Created by Mahmut Canga on 29/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import UIKit

open class CheckoutBagItemsCell: UITableViewCell, TableCheckoutFlowStepOverViewCell {
    
    public static let reuseIdentifier: String = "CheckoutBagItemsCell"
    public static let nibName: String = "CheckoutBagItemsCell"

    @IBOutlet public weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = AppTheme.sharedInstance.checkoutOrderSummeryBagItemTitleLabelFont
        }
    }
    @IBOutlet public weak var priceLabel: UILabel! {
        didSet {
            priceLabel.font = AppTheme.sharedInstance.checkoutOrderSummeryBagItemPriceLabelFont
        }
    }
    @IBOutlet public weak var qtyLabel: UILabel! {
        didSet {
            qtyLabel.font =  AppTheme.sharedInstance.checkoutDeliveryOptionsSubPriceFont
        }
    }
    
    @IBOutlet public weak var topLine: SolidLine! {
        didSet {
            topLine.isHidden = true
        }
    }
    
    @IBOutlet public weak var bottomLine: SolidLine! {
        didSet {
            bottomLine.isHidden = true
        }
    }
    
    @IBOutlet public weak var productImage: PoqAsyncImageView!
    
    public func setUp(_ imageURL: String?, rowIndex: Int, totalCount: Int) {
        
        if let thumbnail = imageURL, let thumbnailURL = URL(string: thumbnail) {
            productImage.getImageFromURL(thumbnailURL, isAnimated: true)
        }
        if rowIndex == 0 {
            // Show the top line
            topLine.isHidden = false
        }
        if rowIndex == totalCount - 1 {
            bottomLine.isHidden = false
        }
    }
    
    public func hideSeparators() {
        topLine.isHidden = true
        bottomLine.isHidden = true
    }
}
