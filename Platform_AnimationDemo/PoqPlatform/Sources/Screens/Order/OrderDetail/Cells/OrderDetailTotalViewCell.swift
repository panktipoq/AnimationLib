//
//  OrderDetailTotalViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 10/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

/// Instantiate a cell to show the amounts sum up of an Order.
class OrderDetailTotalViewCell: UITableViewCell {

    // MARK: - Variables

    @IBOutlet var vatAmountLabel: UILabel? {
        didSet {
            vatAmountLabel?.font = AppTheme.sharedInstance.orderVATAmountLabelFont
            vatAmountLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
       
        }
    }
    @IBOutlet var vatTitleLabel: UILabel? {
       didSet {
        vatTitleLabel?.font = AppTheme.sharedInstance.orderVATTitleLabelFont
        vatTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
        vatTitleLabel?.text = AppLocalization.sharedInstance.orderVATText
        
        }
        
    }
    @IBOutlet weak var subTotalTitleLabel: UILabel? {
        didSet {
            //left side grey text
            subTotalTitleLabel?.font = AppTheme.sharedInstance.orderSubTotalTitleLabelFont
            subTotalTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
            subTotalTitleLabel?.text = AppLocalization.sharedInstance.subtotalText
        }
    }
    
    @IBOutlet weak var postageTitleLabel: UILabel? {
        didSet {
            postageTitleLabel?.font = AppTheme.sharedInstance.orderSubTotalTitleLabelFont
            postageTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
            postageTitleLabel?.text = AppLocalization.sharedInstance.postageText
        }
    }
    
    @IBOutlet weak var voucherTitleLabel: UILabel? {
        didSet {
            voucherTitleLabel?.font = AppTheme.sharedInstance.orderSubTotalTitleLabelFont
            voucherTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
            voucherTitleLabel?.text = AppLocalization.sharedInstance.voucherTitleText
        }
    }
    
    @IBOutlet weak var totalTitleLabel: UILabel? {
        didSet {
            totalTitleLabel?.font = AppTheme.sharedInstance.orderTotalTitleLabelFont
            totalTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
            totalTitleLabel?.text = AppLocalization.sharedInstance.totalText
        }
    }
    
    @IBOutlet weak var subTotalLabel: UILabel? {
        didSet {
            //data values
            //black text on the right side
            subTotalLabel?.font = AppTheme.sharedInstance.orderSubTotalLabelFont
            subTotalLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
            subTotalLabel?.accessibilityIdentifier = AccessibilityLabels.summarySubTotalLabel
        }
    }
    
    @IBOutlet weak var postageLabel: UILabel? {
        didSet {
            
            postageLabel?.font = AppTheme.sharedInstance.orderSubTotalLabelFont
            postageLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
            postageLabel?.accessibilityIdentifier = AccessibilityLabels.summaryPostageLabel
        }
    }
    
    @IBOutlet weak var voucherAmountLabel: UILabel? {
        didSet {
            voucherAmountLabel?.font = AppTheme.sharedInstance.orderSubTotalLabelFont
            voucherAmountLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
        }
    }
    
    @IBOutlet weak var totalLabel: UILabel? {
        didSet {
            
            totalLabel?.font = AppTheme.sharedInstance.orderTotalLabelFont
            totalLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
            totalLabel?.accessibilityIdentifier = AccessibilityLabels.summaryTotalLabel
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset data
        subTotalLabel?.text = nil
        postageLabel?.text = nil
        voucherAmountLabel?.text = nil
        totalLabel?.text = nil
    }
    
    // MARK: - Setup

    func setUpData<OrderItem>(_ optionalOrder: PoqOrder<OrderItem>?) {
        
        if let order = optionalOrder {
            if let vat = order.totalVAT {
                vatAmountLabel?.text = String(format: "%@%.2f", CurrencyProvider.shared.currency.symbol, vat)
            }
            else {
                vatTitleLabel?.removeFromSuperview()
                vatAmountLabel?.removeFromSuperview()
            }

            if let subtotal = order.subtotalPrice {
                subTotalLabel?.text = String(format: "%@%.2f", CurrencyProvider.shared.currency.symbol, subtotal)
            }
            if let deliveryCost = order.deliveryCost {
                postageLabel?.text = String(format: "%@%.2f", CurrencyProvider.shared.currency.symbol, deliveryCost)
            }
            if let total = order.totalPrice {
                totalLabel?.text = String(format: "%@%.2f", CurrencyProvider.shared.currency.symbol, total)
            }
            if let voucher = order.voucherAmount {
                voucherAmountLabel?.text = String(format: "-%@%.2f", CurrencyProvider.shared.currency.symbol, voucher)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
