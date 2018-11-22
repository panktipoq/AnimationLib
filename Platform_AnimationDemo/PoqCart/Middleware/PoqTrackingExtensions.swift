//
//  PoqTrackingExtensions.swift
//  PoqCart
//
//  Created by Balaji Reddy on 13/08/2018.
//

import Foundation
import PoqAnalytics

extension PoqTrackable where Self: PoqAdvancedTrackable {
    
    func bagUpdate(totalQuantity: Int, totalValue: String) {
        let productInfo: [String: Any] = [TrackingInfo.quantity: totalQuantity, TrackingInfo.total: totalValue]
        logEvent(TrackingEvents.Bag.bagUpdate, params: productInfo)
    }
    
    func removeFromBag(productId: String, productTitle: String) {
        
        let productInfo: [String: Any] = [TrackingInfo.productId: productId, TrackingInfo.productTitle: productTitle]
        logEvent(TrackingEvents.Bag.removeFromBag, params: productInfo)
    }
}

extension PoqTrackerV2 {
    
    func bagUpdate(totalQuantity: Int, totalValue: String) {
    
        providers.forEach {
            ($0 as? PoqAdvancedTrackable)?.bagUpdate(totalQuantity: totalQuantity, totalValue: totalValue)
        }
    }
    
    public func removeFromBag(productId: String, productTitle: String) {
        let filteredProductTitle = filter(string: productTitle)
        providers.forEach {
            ($0 as? PoqAdvancedTrackable)?.removeFromBag(productId: productId, productTitle: filteredProductTitle)
        }
    }
}
