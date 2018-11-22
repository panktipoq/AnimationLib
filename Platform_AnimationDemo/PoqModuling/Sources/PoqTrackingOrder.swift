//
//  PoqTrackingOrder.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 6/5/17.
//
//

import Foundation

public class PoqTrackingOrder {
    
    // A unique ID representing the transaction. This ID should not collide with other transaction IDs.
    public final var transactionId: String?
    
    // An entity with which the transaction should be affiliated (e.g. Android APP is used for our Android apps)
    public final var affiliation: String = "iOS APP"
    
    // The total revenue of a transaction, including tax and shipping
    public final var revenue: Double = 0
    
    // The total tax for a transaction
    public final var tax: Double = 0
    
    // The total cost of shipping for a transaction
    public final var shipping: Double = 0
    
    // The local currency of a transaction. Defaults to the currency of the view (profile) in which the transactions are being viewed.
    public final var currencyCode: String?
    
    // List of products to be tracked
    public final var orderItems: [PoqTrackingOrderItem] = []
    
    public final var voucherCode: String?
    public final var voucherTitle: String?
    
    public final var discount: Double = 0
    public final var subTotal: Double = 0
    public final var nearestStoreName: String?
    public final var isClickAndCollect: Bool = false
    public final var extraParams: [String: String]?
    
    public init() {   
    }
 
}
