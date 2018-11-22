//
//  CartRouter.swift
//  PoqCart
//
//  Created by Balaji Reddy on 03/05/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//
import ReSwift
import UIKit
import PoqPlatform
import PoqNetworking
import PoqUtilities

/**
 
    This protocol represents a type that can route/navigate to a screen based on the route object provided
 
 */
public protocol Routable {
    
    func route(to: Route)
}

/**
 
    This enum represents the route identifiers of the screens that the Cart screen can navigate to
 */
public enum CartRouteID: String {
    case productDetail
    case nativeCheckout
    case webCheckout
    case login
    case shop
}

/**
 
    This the concrete platform implementation of the Routable protocol
 
    It implements methods that navigate to different screens from the Cart screen
 */
public class CartRouter: Routable {
    
    /// This method performs the routing/navigation to a the specified route
    ///
    /// - Parameter route: a Route object that enscapsulates the information needed to navigate to a specific screen
    public func route(to route: Route) {
        
        let routeId = route.routeIdentifier
        
        switch routeId {
    
        case CartRouteID.productDetail.rawValue:
    
            guard let productIds = route.data as? (String, String?)  else {
                
                assertionFailure("Wrong or no data provided for route \(String(describing: routeId))")
                return
            }
            
            // The new Cart API only uses the external product Id, so we send 0 for the internal product Id
            NavigationHelper.sharedInstance.loadProduct(Int(productIds.0) ?? 0, externalId: productIds.1)
            
        case CartRouteID.login.rawValue:

            NavigationHelper.sharedInstance.loadLogin(isModal: true, isViewAnimated: true, isFromLoginOptions: true)
                
        case CartRouteID.nativeCheckout.rawValue:
            
            NavigationHelper.sharedInstance.openURL(NavigationHelper.sharedInstance.checkoutOrderSummaryURL)
    
        case CartRouteID.webCheckout.rawValue:
                
            NavigationHelper.sharedInstance.openCartTransfer()
            
        case CartRouteID.shop.rawValue:
            
            NavigationHelper.sharedInstance.loadShop()
            
        default:
            Log.error("Route not supported by router")
        }
    }
}
