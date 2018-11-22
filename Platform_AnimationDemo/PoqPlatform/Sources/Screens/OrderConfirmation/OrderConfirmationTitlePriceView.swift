//
//  OrderConfirmationTitlePriceView.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 9/27/16.
//
//

import UIKit

public let TitlePriceViewHeight: CGFloat = 30.0

/**
 This view suit case when you have text on left side, aka 'Parice' and price valu on right side
 Must be loaded from xib
 */
class OrderConfirmationTitlePriceView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel? // left
    @IBOutlet weak var priceValueLabel: UILabel? // right
    
    @IBOutlet weak var leadindConstraint: NSLayoutConstraint?
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.font = AppTheme.sharedInstance.checkoutOrderConfirmationSubTotalTitleLabelFont
        titleLabel?.textColor = AppTheme.sharedInstance.confirmationGrayColor
        
        priceValueLabel?.font = AppTheme.sharedInstance.checkoutOrderConfirmationPriceFont
        priceValueLabel?.textColor = AppTheme.sharedInstance.confirmationBlackColor
        
        heightAnchor.constraint(equalToConstant: TitlePriceViewHeight).isActive = true
    }
}
