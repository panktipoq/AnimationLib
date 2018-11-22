//
//  FirebaseTracking.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 09/11/2017.
//

import Foundation
import Firebase

public class PoqFirebaseTracking: PoqBagTrackable, PoqCatalogueTrackable, PoqContentTrackable, PoqCheckoutTrackable, PoqMyAccountTrackable, PoqLoyaltyTrackable, PoqAdvancedTrackable {
    
    let firebaseMaxCharacterLength = 100

    public func initProvider() {
        guard FirebaseApp.app() == nil else {
            return
        }
        
        FirebaseApp.configure()
    }

    public init() {}
    
    public func logEvent(_ name: String, params: [String: Any]?) {
        let mappedName = eventMapper(eventWithName: name)
        
        guard let paramsUnwrapped = params else {
            // Params dict empty so we just want to log event as is
            Analytics.logEvent(mappedName, parameters: params)
            return
        }
        
        var mappedParams = [String: Any]()
        for param in paramsUnwrapped {
            mappedParams[paramMapper(paramWithKey: param.key)] = paramValueLengthChecker(forValue: param.value)
        }
        
        Analytics.logEvent(mappedName, parameters: mappedParams)
    }
    
    func logOnboardingEvent(eventType: String?) {
        
        eventType == OnboardingAction.begin.rawValue ? logEvent(FirebaseTrackingEvents.tutorialBegin, params: nil) : logEvent(FirebaseTrackingEvents.tutorialComplete, params: nil)
    }
    
    func eventMapper(eventWithName event: String) -> String {
        switch event {
        case TrackingEvents.Catalogue.viewProduct:
            return FirebaseTrackingEvents.viewItem
            
        case TrackingEvents.Catalogue.viewProductList:
            return FirebaseTrackingEvents.viewItemList
            
        case TrackingEvents.Catalogue.viewSearchResults:
            return FirebaseTrackingEvents.viewSearchResults
            
        case TrackingEvents.Catalogue.addToBag:
            return FirebaseTrackingEvents.addToCart
            
        case TrackingEvents.Catalogue.addToWishlist:
            return FirebaseTrackingEvents.addToWishlist
            
        case TrackingEvents.Checkout.beginCheckout:
            return FirebaseTrackingEvents.beginCheckout
            
        case TrackingEvents.Checkout.orderSuccessful:
            return FirebaseTrackingEvents.ecommercePurchase
            
        case TrackingEvents.MyAccount.signUp:
            return FirebaseTrackingEvents.signUp
            
        default:
            return event
        }
    }
    
    func paramMapper(paramWithKey key: String) -> String {
        switch key {
        case TrackingInfo.productId:
            return FirebaseTrackingInfo.itemId
            
        case TrackingInfo.productTitle:
            return FirebaseTrackingInfo.itemName
            
        case TrackingInfo.categoryId:
            return FirebaseTrackingInfo.itemCategory
            
        case TrackingInfo.keyword:
            return FirebaseTrackingInfo.searchTerm
            
        case TrackingInfo.voucher:
            return FirebaseTrackingInfo.coupon
            
        case TrackingInfo.total:
            return FirebaseTrackingInfo.value
            
        case TrackingInfo.delivery:
            return FirebaseTrackingInfo.shipping
            
        default:
            return key
        }
    }
    
    func paramValueLengthChecker(forValue value: Any) -> Any {
        guard let valueAsString = value as? String else {
            return value
        }
        if valueAsString.count > firebaseMaxCharacterLength {
            let index = valueAsString.index(valueAsString.startIndex, offsetBy: firebaseMaxCharacterLength)
            return valueAsString[..<index]
        }
        return value
    }
}

struct FirebaseTrackingEvents {
    static let viewItem = "view_item"
    static let viewItemList = "view_item_list"
    static let viewSearchResults = "view_search_results"
    static let addToCart = "add_to_cart"
    static let addToWishlist = "add_to_wishlist"
    static let beginCheckout = "begin_checkout"
    static let ecommercePurchase = "ecommerce_purchase"
    static let signUp = "sign_up"
    static let tutorialBegin = "tutorial_begin"
    static let tutorialComplete = "tutorial_complete"
}

struct FirebaseTrackingInfo {
    static let itemId = "item_id"
    static let itemName = "item_name"
    static let itemCategory = "item_category"
    static let searchTerm = "search_term"
    static let coupon = "coupon"
    static let value = "value"
    static let shipping = "shipping"
}
