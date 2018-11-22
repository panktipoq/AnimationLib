//
//  OrderListViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 10/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqNetworking
import UIKit

/// Instantiate a cell to show the sum up of an Order.
class OrderListViewCell: UITableViewCell {
    
    // MARK: - Variables

    static let NibName:String = "OrderListViewCell"
    static let Identifier:String = "orderListCell"
    
    @IBOutlet weak var statusView: UIView?

    @IBOutlet weak var orderNumberTitleLabel: UILabel? {
        didSet {
            orderNumberTitleLabel?.font = AppTheme.sharedInstance.orderNumberTitleLabelFont
            orderNumberTitleLabel?.textColor = AppTheme.sharedInstance.orderNumberTitleLabelColor
            orderNumberTitleLabel?.text = AppLocalization.sharedInstance.orderNumberText
        }
    }
    @IBOutlet weak var orderNumberLabel: UILabel? {
        didSet {
            orderNumberLabel?.accessibilityIdentifier = AccessibilityLabels.orderNumber
            orderNumberLabel?.font = AppTheme.sharedInstance.orderNumberLabelFont
            orderNumberLabel?.textColor = AppTheme.sharedInstance.orderNumberLabelColor

        }
    }
    @IBOutlet weak var orderStatusLabel: UILabel? {
        didSet {
            orderStatusLabel?.accessibilityIdentifier = AccessibilityLabels.orderStatus
            orderStatusLabel?.font = AppTheme.sharedInstance.orderStatusLabelFont
        }
    }

    @IBOutlet weak var orderDateTitleLabel: UILabel? {
        didSet {
            orderDateTitleLabel?.font = AppTheme.sharedInstance.orderInfoTitleLabelFont
            orderDateTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
            orderDateTitleLabel?.text = AppLocalization.sharedInstance.orderDateText
        }
    }
    @IBOutlet weak var orderDateLabel: UILabel? {
        didSet {
            orderDateLabel?.accessibilityIdentifier = AccessibilityLabels.orderDate
            orderDateLabel?.font = AppTheme.sharedInstance.orderInfoLabelFont
            orderDateLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
        }
    }
    
    @IBOutlet weak var orderTotalTitleLabel: UILabel? {
        didSet {
            orderTotalTitleLabel?.font = AppTheme.sharedInstance.orderInfoTitleLabelFont
            orderTotalTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
            orderTotalTitleLabel?.text = AppLocalization.sharedInstance.orderTotalText
        }
    }
    @IBOutlet weak var orderTotalLabel: UILabel? {
        didSet {
            orderTotalLabel?.accessibilityIdentifier = AccessibilityLabels.orderPrice
            orderTotalLabel?.font = AppTheme.sharedInstance.orderInfoLabelFont
            orderTotalLabel?.textColor = AppTheme.sharedInstance.orderInfoLabelColor
        }
    }

    @IBOutlet weak var orderNameLabel: UILabel? {
        didSet {
            orderNameLabel?.font = AppTheme.sharedInstance.orderNameLabelFont
            orderNameLabel?.textColor = AppTheme.sharedInstance.orderNameLabelTextColor
        }
    }

    @IBOutlet weak var orderDeliveryFullNameLabel: UILabel? {
        didSet {
            orderDeliveryFullNameLabel?.font = AppTheme.sharedInstance.orderDeliveryFullNameLabelFont
            orderDeliveryFullNameLabel?.textColor = AppTheme.sharedInstance.orderDeliveryFullNameLabelTextColor
        }
    }
    
    @IBOutlet weak var purchaseTitleLabel: UILabel? {
        didSet {
            purchaseTitleLabel?.font = AppTheme.sharedInstance.orderInfoTitleLabelFont
            purchaseTitleLabel?.textColor = AppTheme.sharedInstance.orderInfoTitleLabelColor
        }
    }
    
    @IBOutlet weak var productImage1: PoqAsyncImageView?
    @IBOutlet weak var productImage2: PoqAsyncImageView?
    @IBOutlet weak var productImage3: PoqAsyncImageView?
    
    // http://stackoverflow.com/questions/39023675/xcode-8-some-views-vcs-not-showing-up-on-simulator
    // http://stackoverflow.com/questions/39578530/since-xcode-8-and-ios10-views-are-not-sized-properly-on-viewdidlayoutsubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        statusView?.layoutIfNeeded()
        
        if AppSettings.sharedInstance.shouldMakeOrderStatusViewCircle {
            statusView?.makeItCircle()
        }
    }

    // MARK: - Setup

    func setUpData<OrderItem>(_ order: PoqOrder<OrderItem>) {
        
        if let orderStatus = order.orderStatus {
            if let currentStatusView = statusView, let statusLabel = orderStatusLabel {
                OrderStatusHelper.setUpControls(orderStatus, colorView: currentStatusView, label: statusLabel)
            }
            
            orderStatusLabel?.text = orderStatus.removeInderline()
        }
        
        orderNumberLabel?.text = order.externalOrderId
        orderDateLabel?.text = order.orderDate
        
        if let price = order.totalPrice{
            orderTotalLabel?.text = price.toPriceString()
        }
        
        if let firstName = order.firstName {
            orderNameLabel?.text = firstName
        }
        
        if let deliveryFirstName = order.deliveryFirstName, let deliveryLastName = order.deliveryLastName {
            orderDeliveryFullNameLabel?.text = "\(deliveryFirstName) \(deliveryLastName)"
        }
        
        guard let orderItems = order.orderItems else {
            return
        }
        
        let itemString = orderItems.count > 1 ? "items" : "item"
        orderTotalLabel?.text = String(format: "%@%.2f (%d %@)",CurrencyProvider.shared.currency.symbol, order.totalPrice!, orderItems.count,itemString)

        guard let image1 = productImage1, let image2 = productImage2, let image3 = productImage3 else {
            return
        }
        
        let imageViews: [PoqAsyncImageView] = [image1, image2, image3]
        for (index, orderItem): (Int, OrderItem) in orderItems.enumerated() {
            guard let urlString: String = orderItem.productImageUrl,
                  let url: URL = URL(string: urlString) else {
                    continue
            }
            
            if imageViews.count > index {
                imageViews[index].getImageFromURL(url, isAnimated: false)

            }
         }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImage1?.prepareForReuse()
        productImage2?.prepareForReuse()
        productImage3?.prepareForReuse()
    }
}

struct OrderStatus {
    static let payment_review = "payment_review"
    static let processing = "processing"
    static let picking = "picking"
    static let pending_payment = "pending_payment"
    static let fraud = "fraud"
    static let pending = "pending"
    static let holded = "holded"
    static let refund_pending = "refund_pending"
    static let complete = "complete"
    static let closed = "closed"
    static let canceled = "canceled"
    static let canceled_pendings = "canceled_pendings"
    static let pending_paypal = "pending_paypal"
}

extension PoqOrder {
    func prettyOrderStatus() -> String {
        guard let validOrderStatus = orderStatus else {
            return ""
        }
        
        if validOrderStatus == OrderStatus.payment_review {
            
            return  AppLocalization.sharedInstance.orderStatusPaymentReviewText
            
        } else if validOrderStatus == OrderStatus.processing {
            
            return  AppLocalization.sharedInstance.orderStatusProcessingText
            
        } else if validOrderStatus == OrderStatus.picking {
            
            return  AppLocalization.sharedInstance.orderStatusPickingText
            
        } else if validOrderStatus == OrderStatus.pending_payment {
            
            return  AppLocalization.sharedInstance.orderStatusPendingPaymentText
            
        } else if validOrderStatus == OrderStatus.fraud {
            
            return  AppLocalization.sharedInstance.orderStatusFraudText
            
        } else if validOrderStatus == OrderStatus.pending {
            
            return  AppLocalization.sharedInstance.orderStatusPendingText
            
        } else if validOrderStatus == OrderStatus.holded {
            
            return  AppLocalization.sharedInstance.orderStatusHoldedText
            
        } else if validOrderStatus == OrderStatus.refund_pending {
            
            return  AppLocalization.sharedInstance.orderStatusRefundPendingText
            
        } else if validOrderStatus == OrderStatus.complete {
            
            return  AppLocalization.sharedInstance.orderStatusCompleteText
            
        } else if validOrderStatus == OrderStatus.closed {
            
            return  AppLocalization.sharedInstance.orderStatusClosedText
            
        } else if validOrderStatus == OrderStatus.canceled {
            
            return  AppLocalization.sharedInstance.orderStatusCanceledText
            
        } else if validOrderStatus == OrderStatus.canceled_pendings {
            
            return  AppLocalization.sharedInstance.orderStatusCanceledPendingsText
            
        } else if validOrderStatus == OrderStatus.pending_paypal {
            
            return  AppLocalization.sharedInstance.orderStatusPendingPayPalText
            
        } else {
            return ""
        }
    }
}

