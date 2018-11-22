//
//  CompleteCartTransferPostBody.swift
//  Poq.iOS.Platform.SimplyBe
//
//  Created by Nikolay Dzhulay on 2/21/17.
//
//

import Foundation
import ObjectMapper

public class CompleteCartTransferPostBody: Mappable {
    
    public final var orderId: Int?
    public final var externalOrderId: String?
    public final var voucherAmount: Double?
    public final var deliveryCost: Double?
    public final var totalPrice: Double?

    public required init?(map: Map) {
    }
    
    public init() {
    }
    
    public final  func mapping(map: Map) {
        
        orderId <- map["orderId"]
        externalOrderId <- map["externalOrderId"]
        voucherAmount <- map["voucherAmount"]
        deliveryCost <- map["deliveryCost"]
        totalPrice <- map["totalPrice"]
    }
}
