//
//  CheckoutOrderSummaryTotalBagItemsCell.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 12/4/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import UIKit

open class CheckoutOrderSummaryTotalBagItemsCell: AccordionTableViewCell, TableCheckoutFlowStepOverViewCell {

    public static let reuseIdentifier: String = "CheckoutOrderSummaryTotalBagItemsCell"
    public static let nibName: String = "CheckoutOrderSummaryTotalBagItemsCell"
 
    @IBOutlet open weak var totalLabel: UILabel? {
        didSet {
            totalLabel?.font = AppTheme.sharedInstance.orderSummaryTotalLabelBagItemsFont
        }
    }
    @IBOutlet open weak var totalPriceLabel: UILabel? {
        didSet {
            totalPriceLabel?.font = AppTheme.sharedInstance.orderSummaryTotalPriceLabelBagItemsFont
        }
    }
    
    open func setUp() {
        isEnabled = true
        totalLabel?.accessibilityIdentifier = AccessibilityLabels.orderTotalLabel
        totalPriceLabel?.accessibilityIdentifier = AccessibilityLabels.orderTotalPriceLabel
    }
}
