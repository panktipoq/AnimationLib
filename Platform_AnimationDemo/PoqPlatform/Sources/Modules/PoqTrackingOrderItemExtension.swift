//
//  PoqTrackingOrderItemExtension.swift
//  PoqiOSTracking
//
//  Created by Mahmut Canga on 09/02/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import PoqModuling
import PoqNetworking

extension PoqTrackingOrderItem {

    
    convenience init<OrderItemType: OrderItem>(orderTransactionId: String, orderItem: OrderItemType) {
    
        self.init()
        self.transactionId = orderTransactionId
        
        if let productId = orderItem.productID {
            self.id = String(productId)
        }
        if let productTitle = orderItem.productTitle {
            self.name = productTitle
        }
        if let sku = orderItem.sku {
            self.sku = sku
        }
        if let price = orderItem.price {
            self.price = price
        }
        if let quantity = orderItem.quantity {
            self.quantity = quantity
        }
    }
    
    convenience init<BagItemType: BagItem>(orderTransactionId: String, bagItem: BagItemType) {
        
        self.init()
        
        self.transactionId = orderTransactionId
        
        if let productId = bagItem.productId {
            self.id = String(productId)
        }
        if let productTitle = bagItem.product?.title {
            self.name = productTitle
        }
        if let productSizeId = bagItem.productSizeId {
            self.sku = String(productSizeId)
        }
        if let price = bagItem.product?.specialPrice {
            self.price = price
        }
        if let quantity = bagItem.quantity {
            self.quantity = quantity
        }
    }
}
