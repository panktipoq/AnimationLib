//
//  PoqOrderWebCheckoutExtension.swift
//  Poq.iOS.Platform.SimplyBe
//
//  Created by Nikolay Dzhulay on 2/21/17.
//
//

import Foundation
import PoqNetworking

/// Here we will cust it to porduct to keep this info in CartTransfer V1 
/// Amount of data is minial for analytics tracking

public extension PoqOrder where OrderItemType == PoqOrderItem {
    public func update(with order: StartCartTransferResponseOrder?) {

        id = order?.orderId
        subtotalPrice = order?.subtotal 
        totalPrice = order?.subtotal
        
        var orderItems = [PoqOrderItem]()
        if let items = order?.items {
            for item in items {
                orderItems.append(PoqOrderItem(orderItem: item))
            }
        }
        
        self.orderItems = orderItems
        totalQuantity = CheckoutHelper.getNumberOfOrderItems(orderItems)
    }
}

extension PoqOrderItem {

    init(orderItem: StartCartTransferResponseOrderItem) {
        self.init()

        id = orderItem.productId
        productID = orderItem.productId
        quantity = orderItem.quantity
        if let orderItemPrice = orderItem.price {
            price = orderItem.specialPrice.flatMap({ $0 < orderItemPrice ? $0 : orderItemPrice })
        }
        sku = orderItem.sku
        productTitle = orderItem.productTitle
    }
}
