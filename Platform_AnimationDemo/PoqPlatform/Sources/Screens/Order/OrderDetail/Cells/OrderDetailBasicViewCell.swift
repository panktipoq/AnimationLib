//
//  OrderDetailBasicViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 10/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

/// Instantiate a cell to show the sum up of an Order.
open class OrderDetailBasicViewCell: UITableViewCell {
    
    // MARK: - Variables
    
    //first section
    @IBOutlet open weak var orderStatusView: UIView?
    @IBOutlet open weak var orderNumberTitleLabel: UILabel?
    @IBOutlet open weak var orderNumberLabel: UILabel?
    @IBOutlet open weak var orderStatusLabel: UILabel?
    @IBOutlet open weak var modifyOrderButton: BlackButton?
    
    //second section.
    @IBOutlet open weak var orderDateTitleLabel: UILabel?
    @IBOutlet open weak var orderDateLabel: UILabel?
    @IBOutlet open weak var orderTotalTitleLabel: UILabel?
    @IBOutlet open weak var orderTotalLabel: UILabel?
    @IBOutlet open weak var deliveryOptionTitleLabel: UILabel?
    @IBOutlet open weak var deliveryOptionLabel: UILabel?
    @IBOutlet open weak var paymentMethodTitleLabel: UILabel?
    @IBOutlet open weak var paymentMethodLabel: UILabel?
    
    //third section
    @IBOutlet open weak var deliveredToTitleLabel: UILabel?
    @IBOutlet open weak var deliveredToLabel: UILabel?
    @IBOutlet open weak var billingTitleLabel: UILabel?
    @IBOutlet open weak var billingLabel: UILabel?
    @IBOutlet open weak var summaryTitleLabel: UILabel?
    
    // MARK: - AwakeFromNib
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //TODO-GABI move to didSet on each object
        modifyOrderButton?.setTitle(AppLocalization.sharedInstance.modifyOrderButtonText, for: .normal)
        
        orderNumberTitleLabel?.font = AppTheme.sharedInstance.orderNumberTitleLabelFont
        orderNumberTitleLabel?.textColor = AppTheme.sharedInstance.orderNumberTitleLabelColor
        orderNumberTitleLabel?.text = AppLocalization.sharedInstance.orderNumberText
        
        orderNumberLabel?.font = AppTheme.sharedInstance.orderNumberLabelFont
        orderNumberLabel?.textColor = AppTheme.sharedInstance.orderNumberLabelColor
        orderNumberLabel?.accessibilityIdentifier = AccessibilityLabels.summaryOrderNumberLabel

        orderStatusLabel?.font = AppTheme.sharedInstance.orderStatusLabelFont
        orderStatusLabel?.accessibilityIdentifier = AccessibilityLabels.summaryOrderStatusLabel

        orderDateLabel?.font = AppTheme.sharedInstance.orderInfoLabelFont
        orderDateLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
        orderDateLabel?.accessibilityIdentifier = AccessibilityLabels.summaryOrderDateLabel
        
        orderDateTitleLabel?.font = AppTheme.sharedInstance.orderInfoTitleLabelFont
        orderDateTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
        orderDateTitleLabel?.text = AppLocalization.sharedInstance.orderDateText

        orderTotalLabel?.font = AppTheme.sharedInstance.orderInfoLabelFont
        orderTotalLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
        orderTotalLabel?.accessibilityIdentifier = AccessibilityLabels.summaryOrderTotalLabel
        
        orderTotalTitleLabel?.font = AppTheme.sharedInstance.orderInfoTitleLabelFont
        orderTotalTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
        orderTotalTitleLabel?.text = AppLocalization.sharedInstance.orderTotalText
        
        deliveryOptionLabel?.font = AppTheme.sharedInstance.orderInfoLabelFont
        deliveryOptionLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
        
        deliveryOptionTitleLabel?.font = AppTheme.sharedInstance.orderInfoTitleLabelFont
        deliveryOptionTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
        deliveryOptionTitleLabel?.text = AppLocalization.sharedInstance.deliveryOptionText
        
        paymentMethodLabel?.font = AppTheme.sharedInstance.orderInfoLabelFont
        paymentMethodLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
        
        paymentMethodTitleLabel?.font = AppTheme.sharedInstance.orderInfoTitleLabelFont
        paymentMethodTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
        paymentMethodTitleLabel?.text = AppLocalization.sharedInstance.paymentMethodText
        
        deliveredToLabel?.font = AppTheme.sharedInstance.orderInfoLabelFont
        deliveredToLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
        deliveredToLabel?.accessibilityIdentifier = AccessibilityLabels.summaryDeliveredToLabel
        
        deliveredToTitleLabel?.font = AppTheme.sharedInstance.orderInfoTitleLabelFont
        deliveredToTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
        deliveredToTitleLabel?.text = AppLocalization.sharedInstance.deliveredToText
        
        billingLabel?.font = AppTheme.sharedInstance.orderInfoLabelFont
        billingLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
        billingLabel?.accessibilityIdentifier = AccessibilityLabels.summaryBillingLabel
        
        billingTitleLabel?.font = AppTheme.sharedInstance.orderInfoTitleLabelFont
        billingTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
        billingTitleLabel?.text = AppLocalization.sharedInstance.billingText
        
        summaryTitleLabel?.font = AppTheme.sharedInstance.orderInfoTitleLabelFont
        summaryTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
        summaryTitleLabel?.text = AppLocalization.sharedInstance.orderDetailsSummaryTitle
        summaryTitleLabel?.accessibilityIdentifier = AccessibilityLabels.summaryTitleLabel
    }
    
    // MARK: - Setup
    
    open func setUpData<OrderItem>(_ optionalOrder: PoqOrder<OrderItem>?) {
        
        if let order = optionalOrder {
            
            //update order status color code
            OrderStatusHelper.setUpControls(order.orderStatus, colorView: orderStatusView, label: orderStatusLabel)
            
            orderStatusLabel?.text = order.orderStatus
            
            orderNumberLabel?.text = order.orderKey
            orderDateLabel?.text = order.orderDate
            
            let itemString = order.orderItems?.count == 1 ? "item" : "items"
            
            if let totalPrice = order.totalPrice,
                let totalQuantity = order.totalQuantity {
                
                orderTotalLabel?.text = String(format: "£ %.2f (%@ %@)", totalPrice, String(totalQuantity), itemString)
            }
            
            deliveryOptionLabel?.text = order.deliveryOption
            paymentMethodLabel?.text = order.paymentMethod
            deliveredToLabel?.text = order.fullShippingAddress
            billingLabel?.text = order.fullBillingAddress
        }
    }
}

