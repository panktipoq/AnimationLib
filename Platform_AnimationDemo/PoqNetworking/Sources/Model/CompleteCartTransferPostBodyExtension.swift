//
//  CompleteCartTransferPostBodyExtension.swift
//  Poq.iOS.Platform.SimplyBe
//
//  Created by Nikolay Dzhulay on 2/21/17.
//
//

import Foundation

extension CompleteCartTransferPostBody {
    public convenience init<OrderItemType>(order: PoqOrder<OrderItemType>) {
        self.init()

        orderId  = order.id
        externalOrderId = order.externalOrderId
        voucherAmount = order.voucherAmount
        deliveryCost = order.deliveryCost
        totalPrice = order.totalPrice
    }
}
