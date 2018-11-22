//
//  PoqTrackingOrderExtension.swift
//  PoqiOSTracking
//  more: https://developers.google.com/analytics/devguides/collection/ios/v3/ecommerce
//  Created by Mahmut Canga on 09/02/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import PoqModuling
import PoqNetworking

extension PoqTrackingOrder {

    public convenience init<OrderItemType>(order: PoqOrder<OrderItemType>) {
        self.init()

        self.transactionId = order.orderKey
        
        if let revenue = order.totalPrice {
            self.revenue = revenue
        }
        
        if let discountCode = order.voucherCode {
            self.voucherCode = discountCode
        }
        
        if let voucherTitle = order.voucherTitle {
            self.voucherTitle = voucherTitle
        }
        
        if let discount = order.voucherAmount {
            self.discount = discount
        }
        
        if let subTotal = order.subtotalPrice {
            self.subTotal = subTotal
        }
        
        if let deliveryCost = order.deliveryCost {
            self.shipping = deliveryCost
        }
        
        if let storeName = order.nearestStoreName {
            self.nearestStoreName = storeName
        }
        
        isClickAndCollect = order.checkoutType == .ClickAndCollect
        
        // Currently we are skipping to set tax and shipping due to cart transfer
        
        if let currencyCode = order.currency {
            self.currencyCode = currencyCode
        }
        
        // Handle nil transaction ID when we first initiated.
        let  orderTransactionId = transactionId ?? ""
        
        if let orderItems = order.orderItems {
            for orderItem in orderItems {
                let trackingOrderItem = PoqTrackingOrderItem(orderTransactionId: orderTransactionId, orderItem: orderItem)
                self.orderItems.append(trackingOrderItem)
            }
        }
        
        if order.isOrderInfoParsingFailed {
            affiliation += "Failed Order Number Parsing"
        }
    }
    
    public convenience init<CheckoutItemType: CheckoutItem>(checkoutItem: CheckoutItemType) {
        self.init()
        
        self.transactionId = checkoutItem.orderKey
        
        if let totalPrice = checkoutItem.totalPrice {
            self.revenue = totalPrice
        }
        
        self.affiliation += " - Stripe"
        
        if let vouchers = checkoutItem.vouchers, vouchers.count > 0 {
            if let voucherCode = vouchers[0].voucherCode {
                self.voucherCode = voucherCode
            }
            
            if let discount = vouchers[0].value {
                self.discount = discount
            }
            
            if let voucherTitle = vouchers[0].id {
                self.voucherTitle = voucherTitle
            }
        }
        
        if let subTotal = checkoutItem.subTotalPrice {
            self.subTotal = subTotal
        }
        
        if let deliveryCost = checkoutItem.shippingTotalPrice {
            self.shipping = deliveryCost
        }
        
        // Currently we are skipping to set tax and shipping due to cart transfer
        // Also, we are skipping currencyCode because of not supporting multicurrency in the platform
        
        //handle nil transaction ID when we first initiated.
        let orderTransactionId = transactionId ?? ""
        
        for bagItem in checkoutItem.bagItems {
            self.orderItems.append(PoqTrackingOrderItem(orderTransactionId: orderTransactionId, bagItem: bagItem))
        }

    }
    
}
