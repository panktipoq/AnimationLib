//
//  OrderDetailProductViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 17/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

/// Instantiate a cell to show a single product of an Order.
open class OrderDetailProductViewCell: UITableViewCell {

    // MARK: - Variables

    @IBOutlet weak var productImage: PoqAsyncImageView?
    @IBOutlet weak var brandNameLabel: UILabel?
    @IBOutlet weak var productNameLabel: UILabel?
    @IBOutlet weak var productCodeTitleLabel: UILabel?
    @IBOutlet weak var productCodeLabel: UILabel?
    @IBOutlet weak var priceQtyLabel: UILabel?
    @IBOutlet weak var subTotalLabel: UILabel?

    // MARK: - AwakeFromNib

    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        //TODO-GABI move to didSet on each object

        brandNameLabel?.textColor = AppTheme.sharedInstance.plpBrandLabelColor
        brandNameLabel?.font = AppTheme.sharedInstance.plpBrandLabelFont
        brandNameLabel?.accessibilityIdentifier = AccessibilityLabels.summaryBrandNameLabel

        productNameLabel?.textColor = AppTheme.sharedInstance.plpTitleLabelColor
        productNameLabel?.font = AppTheme.sharedInstance.plpTitleLabelFont
        productNameLabel?.accessibilityIdentifier = AccessibilityLabels.summaryProductNameLabel

        productCodeTitleLabel?.text = AppLocalization.sharedInstance.orderProductCodeTitle
        productCodeTitleLabel?.textColor = AppTheme.sharedInstance.orderProductCodeLabelColor
        productCodeTitleLabel?.font = AppTheme.sharedInstance.orderProductCodeLabelFont
        productCodeTitleLabel?.accessibilityIdentifier = AccessibilityLabels.summaryProductCodeTitleLabel

        productCodeLabel?.textColor = AppTheme.sharedInstance.orderProductCodeLabelColor
        productCodeLabel?.font = AppTheme.sharedInstance.orderProductCodeLabelFont
        productCodeLabel?.accessibilityIdentifier = AccessibilityLabels.summaryProductCodeLabel

        priceQtyLabel?.textColor = AppTheme.sharedInstance.bagQtyColor
        priceQtyLabel?.font = AppTheme.sharedInstance.bagQtyFont
        priceQtyLabel?.accessibilityIdentifier = AccessibilityLabels.summaryPriceQtyLabel

        subTotalLabel?.textColor = AppTheme.sharedInstance.bagTotalLabelColor
        subTotalLabel?.font = AppTheme.sharedInstance.subTotalFont
        subTotalLabel?.accessibilityIdentifier = AccessibilityLabels.summarySubTotalLabel
    }

    // MARK: - Setup

    open func setUpData(_ optionalOrderItems: [PoqOrderItem]?, index: Int) {

        if let orderItems = optionalOrderItems {

            let orderItem = orderItems[index]

            brandNameLabel?.text = orderItem.brand
            productNameLabel?.text = orderItem.productTitle
            productCodeLabel?.text = orderItem.externalID

            var subTotal = 0.00
            if let price = orderItem.price, let qty = orderItem.quantity {
                subTotal = price * Double(qty)

                priceQtyLabel?.text = String(format:"%@ x %@%.2f", String(qty), CurrencyProvider.shared.currency.symbol, price)
            }
            subTotalLabel?.text = String(format:"%@%.2f", CurrencyProvider.shared.currency.symbol, subTotal)

            guard let imageUrlString = orderItem.productImageUrl, let imageUrl = URL(string: imageUrlString) else {
                Log.error("Invalid or nil productImageUrl for item: \(String(describing: orderItem.productTitle))")
                return
            }
              productImage?.getImageFromURL(imageUrl, isAnimated: true)
        }
    }

    override open func prepareForReuse() {
        super.prepareForReuse()

        productImage?.prepareForReuse()
    }
}
