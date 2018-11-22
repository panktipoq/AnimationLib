//
//  PoqPlaceOrderResponse.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 07/09/2016.
//
//

import Foundation
import ObjectMapper

/// This object should be treated as PoqMessage for backward copabilty.
/// So if we didn't find specific keys for PoqPlaceOrderResponse - we will treat it as PoqMessage
open class PoqPlaceOrderResponse<OrderItemType: OrderItem>: PoqMessage {
    
    public typealias OrderType = PoqOrder<OrderItemType>
    
    open var order: OrderType?

    // Mappable
    open override func mapping(map: Map) {
        super.mapping(map: map)

        order <- map["order"]}

}
