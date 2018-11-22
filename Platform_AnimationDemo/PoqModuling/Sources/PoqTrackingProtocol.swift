//
//  PoqTrackingProtocol.swift
//  PoqiOSTracking
//
//  Created by Mahmut Canga on 09/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

public protocol PoqTrackingProtocol {
    
    /* Track checkout initiated order */
    func trackInitOrder(_ trackingOrder: PoqTrackingOrder)
    
    /* Track successfully completed checkout order */
    func trackCompleteOrder(_ trackingOrder: PoqTrackingOrder)
    
    /* Track event based analytics data */
    func logAnalyticsEvent(_ event: String, action: String, label: String, value: Double, extraParams: [String: String]?)
    
    /* Google Analytics specific */
    func trackScreenName(_ screenName: String)
    
    /* Google Analytics enhanced tracking */

    func trackCheckoutAction(_ step: Int, option: String) 
    
    // MARK: Product tracking 
    func trackProductDetails(for product: PoqTrackingProduct)
    
    func trackGroupedProducts(forParent parentProduct: PoqTrackingProduct,  products: [PoqTrackingProduct])
    
    func trackAddToBag(for product: PoqTrackingProduct, productSize: PoqTrackingProductSize)
    
    // MARK: - Marketing Attribution Tracking
    
    func trackCampaignAttribution(from url: URL)
}

extension PoqTrackingProtocol {
    // We put an empty function here so other providers don't have to implement it per default if they don't use it.
    public func trackCampaignAttribution(from url: URL) {}
}
