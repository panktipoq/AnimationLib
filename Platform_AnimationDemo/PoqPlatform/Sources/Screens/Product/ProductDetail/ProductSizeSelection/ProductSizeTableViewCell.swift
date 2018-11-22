//
//  SizeTableViewCell.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 2/11/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

open class ProductSizeTableViewCell: UITableViewCell {
    
    static let XibName: String = "ProductSizeTableViewCell"
    
    @IBOutlet var lowStockLabel: UILabel? {
        didSet {
            lowStockLabel?.font = AppTheme.sharedInstance.lowStockFont
            lowStockLabel?.textColor = AppTheme.sharedInstance.lowStockIndicatorTextColor
            lowStockLabel?.accessibilityIdentifier = AccessibilityLabels.lowStock
        }
    }
    
    @IBOutlet public final var sizeLabel: UILabel? {
        didSet {
            // TODO: Use another MB setting here. This is the same one we are using in other places of the app. So updating this one will change the other labels.
            sizeLabel?.font = AppTheme.sharedInstance.priceFont
        }
    }

    override open func prepareForReuse() {

        super.prepareForReuse()

        lowStockLabel?.isHidden = true
    }

    open func setup(using productSize: PoqProductSize) {
        
        switch AppSettings.sharedInstance.pdpSizeSelectorType {
            
        case ProductSizeSelectorType.sheet.rawValue:
            if let size = productSize.size, !size.isNullOrEmpty() {
                sizeLabel?.text = String(size)
            }
            
            if AppSettings.sharedInstance.isLowStockEnabledOnSizeSelector, let quantity = productSize.quantity, quantity <= Int(AppSettings.sharedInstance.lowStockProductLevel) {
                lowStockLabel?.text = AppLocalization.sharedInstance.pdpSelectSizeLowStockText
                lowStockLabel?.isHidden = false
            }
            
        case ProductSizeSelectorType.classic.rawValue:
            if let size = productSize.size, !size.isNullOrEmpty() {
                
                var string = ""
                
                string += String(size)
                
                if AppSettings.sharedInstance.isPriceEnabledOnSizeSelector, let price = productSize.price {
                    string += " - " + CurrencyProvider.shared.currency.symbol + String(format: AppSettings.sharedInstance.priceDecimalFormat, price)
                }
                
                sizeLabel?.text = string
            }
            
        default:
            break
        }
    }
}
