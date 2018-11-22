//
//  CheckoutOrderSummaryCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 03/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import UIKit

public class CheckoutOrderSummaryCell: UITableViewCell, TableCheckoutFlowStepOverViewCell {

    public static let reuseIdentifier: String = "CheckoutOrderSummaryCell"
    public static let nibName: String = "CheckoutOrderSummaryCell"

    let priceLabelWidthValue: CGFloat = 80

    @IBOutlet weak var subtitleLabel: UILabel? {
        
        didSet {
            subtitleLabel?.textColor = AppTheme.sharedInstance.checkoutOrderSummaryCellSubTitleTextColor
            subtitleLabel?.font = AppTheme.sharedInstance.checkoutOrderSummaryCellSubTitleFont
        }
        
    }
    
    @IBOutlet weak var contentLabel: UILabel? {
        
        didSet {
            contentLabel?.textColor = AppTheme.sharedInstance.checkoutOrderSummaryCellContentTextColor
            contentLabel?.font = AppTheme.sharedInstance.checkoutOrderSummaryCellContentFont
        }

    }
    
    @IBOutlet weak var priceLabel: UILabel? {
        didSet {
            priceLabel?.font = AppTheme.sharedInstance.checkoutOrderSummaryCellPriceFont
        }
    }
    
    @IBOutlet weak var priceLabelWidth: NSLayoutConstraint?
    
//    func hidePriceLabel() {
//        priceLabelWidth?.constant = 0
//    }
//    
//    func showPriceLabel(price: Double) {
//        priceLabelWidth?.constant = priceLabelWidthValue
//        priceLabel?.text = LabelStyleHelper.showFreeForPriceZero(price)
//    }
//    func setupLabels(subtitle: UILabel, content: UILabel, subtitleContent: String?, contentDetail: String?) {
//     
//        subtitle.text = subtitleContent
//        content.text = contentDetail
//        hidePriceLabel()
//        
//    }

    public func setupUI(_ subtitle: String?, contentDetail: String?, price: Double? = nil) {
        
        subtitleLabel?.text = subtitle
        contentLabel?.text = contentDetail
        if let existedPrice: Double = price {
            priceLabelWidth?.constant = priceLabelWidthValue
            priceLabel?.text = LabelStyleHelper.showFreeForPriceZero(existedPrice)
        } else {
            priceLabelWidth?.constant = 0
            priceLabel?.text = nil
        }
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        isUserInteractionEnabled = true
    }
    
}
