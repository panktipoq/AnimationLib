//
//  PoqFacebookTrackingProvider.swift
//  Poq.iOS
//
//  Created by Jun Seki on 15/07/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import FacebookCore
import FBSDKCoreKit
import PoqModuling
import PoqNetworking
import PoqUtilities

class PoqFacebookTrackingProvider: PoqTrackingProtocol {
    
    // We are not going to track any other content type
    // Other content views are not really valuable for FB Retargeting
    // So we are focusing on tracking around Product
    let contentType = "product"
    
    /* initial checkout order */
    func trackInitOrder(_ trackingOrder: PoqTrackingOrder) {
        
        trackInitiatedCheckout(with: trackingOrder)
    }
    
    /* Track successfully completed checkout order */
    func trackCompleteOrder(_ trackingOrder: PoqTrackingOrder) {
        
        trackPurchase(with: trackingOrder)
    }
    
    func trackProductDetails(for product: PoqTrackingProduct) {
        // To adhere to PoqTrackingProtocol
        // TODO: Implement as per tracking provider requirement
    }
        
    func trackGroupedProducts(forParent parentProduct: PoqTrackingProduct, products: [PoqTrackingProduct]) {
        // To adhere to PoqTrackingProtocol
        // TODO: Implement as per tracking provider requirement
    }
    
    func trackAddToBag(for product: PoqTrackingProduct, productSize: PoqTrackingProductSize) {
        
        trackAddedToCart(for: product, productSize: productSize)
    }
            
    /* Track event based analytics data */
    func logAnalyticsEvent(_ event: String, action: String, label: String, value: Double = 0, extraParams: [String: String]?) {

        switch event {
            
        case PoqTrackerEventType.AppForeground:
            trackAppActivation()
            
        case PoqTrackerEventType.ProductDetailLoad:
            trackContentView(contentType: contentType, contentId: label, extraContentDetails: extraParams)
            
        case PoqTrackerEventType.Onboarding:
            
            switch action {
                
            case PoqTrackerActionType.OnboardingSkip:
                trackCompletedTutorial()
                
            case PoqTrackerActionType.OnboardingSwipe:
                break
                
            default:
                Log.warning("\(action) is not recognised as an Onboarding Event in FB Tracking Provider")
            }
            
        case PoqTrackerEventType.AddToWishList:
            trackAddedToWishlist(contentType: contentType, contentId: label, value: value, extraContentDetails: extraParams)
            
        case PoqTrackerActionType.Search:
            
            switch action {
            
            case PoqTrackerActionType.Successful:
                trackSearch(keyword: label, success: true)
                
            case PoqTrackerActionType.Unsuccessful, PoqTrackerActionType.NoResults:
                trackSearch(keyword: label, success: false)
            
            case PoqTrackerActionType.PredictiveSearch:
                trackSearch(keyword: label, success: nil)
                
            default:
                Log.warning("\(action) is not recognised as Search Event in FB Tracking Provider")
            }
            
        default:
            Log.warning("\(event) is not implemented in FB Tracking Provider")
        }
    }
    
    /* Google Analytics specific */
    func trackScreenName(_ screenName: String) {
        
    }
    
    func trackCheckoutAction(_ step: Int, option: String) {
        
    }
}

// TODO: Move this protocol and extension to Analytics v2
protocol PoqFacebookRetargeting {
    
    func trackAppActivation()
    func trackPurchase(with trackingOrder: PoqTrackingOrder)
    func trackAddedToCart(for product: PoqTrackingProduct, productSize: PoqTrackingProductSize)
    func trackAddedToWishlist(contentType: String, contentId: String, value: Double, extraContentDetails: [String: String]?)
    func trackContentView(contentType: String, contentId: String, extraContentDetails: [String: String]?)
    func trackInitiatedCheckout(with trackingOrder: PoqTrackingOrder)
    func trackSearch(keyword: String, success: Bool?)
    func trackCompletedTutorial()
}

// TODO: Move this protocol and extension to Analytics v2
extension PoqFacebookTrackingProvider: PoqFacebookRetargeting {
    
    func trackContentView(contentType: String, contentId: String, extraContentDetails: [String: String]? = nil) {
        
        var extraParamaters: [(AppEventParameterName, AppEventParameterValueType)] = []
        
        if let contentDetails = extraContentDetails {
            
            for (key, value) in contentDetails {
                
                // Product price has to be sent as valueToSum
                // To avoid changing so many things in tracking layer, I pass ProductPrice as an extra parameter
                if key != "ProductPrice" {
                    
                    extraParamaters.append((AppEventParameterName.custom(key), value))
                }
            }
        }
        
        var valueToSum: Double? = nil
        
        if let productPrice = extraContentDetails?["ProductPrice"] {
            valueToSum = Double(productPrice)
        }
        
        AppEventsLogger.log(.viewedContent(contentType: contentType, contentId: contentId, currency: CurrencyProvider.shared.currency.code, valueToSum: valueToSum, extraParameters: AppEvent.ParametersDictionary(pairs: extraParamaters)))
    }

    func trackAddedToWishlist(contentType: String, contentId: String, value: Double, extraContentDetails: [String: String]?) {
        var extraParamaters: [(AppEventParameterName, AppEventParameterValueType)] = []
        
        if let contentDetails = extraContentDetails {
            
            for (key, value) in contentDetails {
                extraParamaters.append((AppEventParameterName.custom(key), value))
            }
        }
        
        AppEventsLogger.log(.addedToWishlist(
            contentType: contentType,
            contentId: contentId,
            currency: CurrencyProvider.shared.currency.code,
            valueToSum: value,
            extraParameters: AppEvent.ParametersDictionary(pairs: extraParamaters)))
    }
    
    func trackAppActivation() {
        
        // This is the first interaction point with SDK
        // Whenever app becomes active, this method is triggered
        // So it could be a good idea to set logging behaviour before everything else
        if Log.level == .info {
            
            SDKSettings.enableLoggingBehavior(.appEvents)
        }
        
        // If user has already selected a country then we need to override the appId read from plist
        if let country = CountrySelectionViewModel.selectedCountrySettings(), let facebookAppId = country.facebookAppId {
            SDKSettings.appId = facebookAppId
        }
        
        // Call the 'activate' method to log an app event for use
        // In analytics and advertising reporting.
        AppEventsLogger.activate(UIApplication.shared)
    }
    
    func trackPurchase(with trackingOrder: PoqTrackingOrder) {
        
        var extraParamaters: [(AppEventParameterName, AppEventParameterValueType)] = []
        
        if let transactionId = trackingOrder.transactionId {
            
            extraParamaters.append((AppEventParameterName.custom("transactionId"), transactionId))
        }
        
        if let voucherCode = trackingOrder.voucherCode {
            
            extraParamaters.append((AppEventParameterName.custom("voucherCode"), voucherCode))
        }
        
        if let voucherTitle = trackingOrder.voucherTitle {
            
            extraParamaters.append((AppEventParameterName.custom("voucherTitle"), voucherTitle))
        }
        
        extraParamaters.append((AppEventParameterName.custom("discount"), trackingOrder.discount))
        extraParamaters.append((AppEventParameterName.custom("clickAndcollect"), trackingOrder.isClickAndCollect.toString()))
        extraParamaters.append((AppEventParameterName.custom("shipping"), trackingOrder.shipping))
        extraParamaters.append((AppEventParameterName.custom("subTotal"), trackingOrder.subTotal))
        extraParamaters.append((AppEventParameterName.custom("tax"), trackingOrder.tax))
        
        AppEventsLogger.log(.purchased(
            amount: trackingOrder.revenue,
            currency: CurrencyProvider.shared.currency.code,
            extraParameters: AppEvent.ParametersDictionary(pairs: extraParamaters)))
    }
    
    func trackAddedToCart(for product: PoqTrackingProduct, productSize: PoqTrackingProductSize) {
        
        var extraParamaters: [(AppEventParameterName, AppEventParameterValueType)] = []
        
        var itemPrice = productSize.price
        
        if let price = productSize.price, let specialPrice = productSize.specialPrice, price > specialPrice, specialPrice > 0 {
            
            itemPrice = specialPrice
        }
        
        if let title = product.title {
            
            extraParamaters.append((AppEventParameterName.custom("title"), title))
        }
        
        AppEventsLogger.log(.addedToCart(
            contentType: contentType,
            contentId: product.externalID,
            currency: CurrencyProvider.shared.currency.code,
            valueToSum: itemPrice,
            extraParameters: AppEvent.ParametersDictionary(pairs: extraParamaters)))
    }
    
    func trackInitiatedCheckout(with trackingOrder: PoqTrackingOrder) {
        
        var orderTotal = 0.0
        
        for item in trackingOrder.orderItems {
            
            orderTotal += item.price
        }
        
        AppEventsLogger.log(.initiatedCheckout(
            contentType: contentType,
            contentId: User.getUserId(),
            itemCount: UInt(trackingOrder.orderItems.count),
            paymentInfoAvailable: false,
            currency: CurrencyProvider.shared.currency.code,
            valueToSum: orderTotal,
            extraParameters: AppEvent.ParametersDictionary(pairs: [])))
    }
    
    func trackSearch(keyword: String, success: Bool?) {
        
        AppEventsLogger.log(.searched(
            contentId: User.getUserId(),
            searchedString: keyword,
            successful: success,
            valueToSum: nil,
            extraParameters: AppEvent.ParametersDictionary(pairs: [])))
    }
    
    func trackCompletedTutorial() {
        
        AppEventsLogger.log(.completedTutorial())
    }
}
