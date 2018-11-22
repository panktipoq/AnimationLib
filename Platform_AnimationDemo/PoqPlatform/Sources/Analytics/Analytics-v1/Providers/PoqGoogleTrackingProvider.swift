//
//  PoqGoogleTrackingProvider.swift
//  PoqiOSTracking
//
//  Created by Mahmut Canga on 09/02/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import GoogleAnalytics
import PoqModuling
import PoqNetworking
import PoqUtilities

public class PoqGoogleTrackingProvider: PoqTrackingProtocol {
    
    let tracker: GAITracker?
    
    init(trackingID: String) {
        
        // Optional: automatically send uncaught exceptions to Google Analytics.
        GAI.sharedInstance().trackUncaughtExceptions = true
        
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        GAI.sharedInstance().dispatchInterval = 20.0
        
        // Optional: set Logger to VERBOSE for debug information.
        GAI.sharedInstance().logger.logLevel = GAILogLevel.error
        
        // Initialize tracker. Replace with your tracking ID.
        tracker = GAI.sharedInstance().tracker(withTrackingId: trackingID)
        
        // Enable IDFA collection.
        //Enable Remarketing and Advertising Reporting Features for an app
        //https://support.google.com/analytics/answer/2444872/?hl=en&utm_id=ad&authuser=1#app
        tracker?.allowIDFACollection = true
    }
    /* initial checkout order */
    public func trackInitOrder(_ trackingOrder: PoqTrackingOrder) {
    }
    
    public func trackProductDetails(for product: PoqTrackingProduct) {
        // To adhere to PoqTrackingProtocolPoqTrackingProduct        // TODO: Implement as per tracking provider requirement
    }
    
    public func trackGroupedProducts(forParent parentProduct: PoqTrackingProduct, products: [PoqTrackingProduct]) {
        
    }
    
    public func trackAddToBag(for product: PoqTrackingProduct, productSize: PoqTrackingProductSize) {
        // To adhere to PoqTrackingProtocol
        // TODO: Implement as per tracking provider requirement
    }
    
    /* Track successfully completed checkout order */
    public func trackCompleteOrder(_ trackingOrder: PoqTrackingOrder) {
        
        guard let existedTracker = tracker else {
            Log.warning("!!!GA tracking ID is not set!!!")
            return
        }
        
        guard let transactionId = trackingOrder.transactionId else {
            Log.warning("Transaction id is null!!! Transcation is not going to be tracked via Google Analytics")
            return
        }
        
        guard trackingOrder.orderItems.count > 0 else {
            Log.warning("Transaction is not containing any order item!!! Transcation is not going to be tracked via Google Analytics")
            return
        }
        
        if AppSettings.sharedInstance.enableNearestStoreTracking {
            enableNearestStoreTracking(trackingOrder, transactionId: transactionId)
        }
        
        // Create order complete event
        logAnalyticsEvent("Order", action: "Amount", label: "\(trackingOrder.revenue)", extraParams: nil)
        
        //set up user id
        existedTracker.set(kGAIUserId, value: User.getUserId())
        
        // Create transaction for the order
        
        let orderTransaction = GAIDictionaryBuilder.createTransaction(withId: transactionId,
                                                                      affiliation: trackingOrder.affiliation,
                                                                      revenue: NSNumber(value: trackingOrder.revenue),
                                                                      tax: NSNumber(value: trackingOrder.tax),
                                                                      shipping: NSNumber(value: trackingOrder.shipping),
                                                                      currencyCode: trackingOrder.currencyCode)
        
        existedTracker.send(orderTransaction?.build().swiftDictionary())
        
        // Create transaction for each order item
        
        for trackingOrderItem in trackingOrder.orderItems {
            
            let orderItemTransaction = GAIDictionaryBuilder.createItem(withTransactionId: trackingOrderItem.transactionId,
                                                                       name: trackingOrderItem.name,
                                                                       sku: trackingOrderItem.sku,
                                                                       category: trackingOrderItem.category,
                                                                       price: NSNumber(value: trackingOrderItem.price),
                                                                       quantity: NSNumber(value: trackingOrderItem.quantity),
                                                                       currencyCode: trackingOrderItem.currencyCode)
            
            existedTracker.send(orderItemTransaction?.build().swiftDictionary())
        }
        
        // track order completion
        let productAction = GAIEcommerceProductAction()
        productAction.setAction(kGAIPACheckoutOption)
        productAction.setCheckoutOption("Order Completed")
        
        let builder = GAIDictionaryBuilder()
        builder.set("event", forKey: kGAIHitType)
        builder.setProductAction(productAction)
        existedTracker.send(builder.build().swiftDictionary())
        
        GAI.sharedInstance().dispatch()
    }
    
    /* Track event based analytics data */
    public func logAnalyticsEvent(_ event: String, action: String, label: String, value: Double = 0, extraParams: [String: String]?) {
        
        guard let existedTracker = tracker else {
            Log.warning("!!!GA tracking ID is not set!!!")
            return
        }
        
        existedTracker.set(kGAIUserId, value: User.getUserId())
        
        let valueASNSNumber = NSNumber(value: Int(round(value)))
        
        let event = GAIDictionaryBuilder.createEvent(withCategory: event, action: action, label: label, value: valueASNSNumber)
        
        if let params = extraParams {
            _ = event?.setAll(params)
        }
        
        existedTracker.send(event?.build().swiftDictionary())
        
        GAI.sharedInstance().dispatch()
        
    }
    
    /* Google Analytics specific */
    public func trackScreenName(_ screenName: String) {
        
        guard let existedTracker: GAITracker = tracker else {
            Log.warning("!!!GA tracking ID is not set!!!")
            return
        }
        
        existedTracker.set(kGAIUserId, value: User.getUserId())
        existedTracker.set(kGAIScreenName, value: screenName)
        existedTracker.send(GAIDictionaryBuilder.createScreenView().build().swiftDictionary())
        
        GAI.sharedInstance().dispatch()
        
    }
    
    public func trackCheckoutAction(_ step: Int, option: String) {
        
        guard let existedTracker = tracker else {
            Log.warning("!!!GA tracking ID is not set!!!")
            return
        }
        
        let builder = GAIDictionaryBuilder.createEvent(withCategory: "Checkout", action: "Option", label: option, value: NSNumber(value: step))
        
        let action = GAIEcommerceProductAction()
        action.setAction(kGAIPACheckout)
        action.setCheckoutStep(NSNumber(value: step))
        action.setCheckoutOption(option)
        
        
        let _ = builder?.setProductAction(action)
        existedTracker.send(builder?.build().swiftDictionary())
        
        GAI.sharedInstance().dispatch()
        
    }
    
    func enableNearestStoreTracking(_ trackingOrder: PoqTrackingOrder, transactionId: String) {
        
        let nearestStore = trackingOrder.nearestStoreName ?? "App"
        
        // Create order complete event
        
        logAnalyticsEvent("Order", action: "\(nearestStore)", label: "\(transactionId)", value: trackingOrder.revenue, extraParams: nil)
        
        trackingOrder.affiliation = nearestStore
    }
    
    // iOS Install Tracking only works for ads served through mobile ad networks, such as AdMob that serves in-app ads
    public func trackCampaignAttribution(from url: URL) {
        
        guard let existedTracker = tracker else {
            Log.warning("!!!GA tracking ID is not set!!!")
            return
        }
        
        // Very important -> It help to collect demographic data (interest, geo, age, gender). It has to be put on every tracker
        existedTracker.allowIDFACollection = true
        
        // Create param infos from the endpoint (example : https://poqcommerce.com/promo?utm_source=newsletter&utm_medium=email&utm_campaign=promotion)
        let hitParams = GAIDictionaryBuilder()
        hitParams.setCampaignParametersFromUrl(url.absoluteString)
        
        // Campaign source is the only required campaign field. If previous call did not set a campaign source, we use the hostname as a referrer instead.
        if !(hitParams.get(kGAICampaignSource) != nil), let host = url.host {
            
            hitParams.set("referer", forKey: kGAICampaignMedium)
            hitParams.set(host, forKey: kGAICampaignSource)
        }
        
        /*
         We need an screen name event as GAIDictionaryBuilder.createAppView() is deprecated.
         
         // Previous V3 SDK versions.
         // [tracker send:[[[GAIDictionaryBuilder createAppView] setAll:hitParamsDict] build]];
         
         // SDK Version 3.08 and up. we are currently using 3.1X
         [tracker send:[[[GAIDictionaryBuilder createScreenView] setAll:hitParamsDict] build]];
        */
        existedTracker.set(kGAIScreenName, value: PoqTracker.attributionScreenEventId)
        
        if let valuesKeys = hitParams.build() as? [AnyHashable : Any],
            let hashTable = GAIDictionaryBuilder.createScreenView().setAll(valuesKeys).build() as? [AnyHashable: Any] {
            
            // Send event to GA
            existedTracker.send(hashTable)
            
            // Remove the end point saved on the user default after using it. (avoid double campaign attribution)
            UserDefaults.standard.set(nil, forKey: PoqTracker.attributionUrlUserDefaultKey)
            UserDefaults.standard.synchronize()
        }
    }
}
