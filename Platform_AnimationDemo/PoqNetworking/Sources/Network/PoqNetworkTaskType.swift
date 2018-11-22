//
//  PoqNetworkTaskType.swift
//  Poq.iOS
//
//  Incremental enumarators for network task types
//
//  Created by Mahmut Canga on 07/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation

/// Protocol should help identifing
public protocol PoqNetworkTaskTypeProvider {
    var type: String { get }
}

public func ==(lhs: PoqNetworkTaskTypeProvider, rhs: PoqNetworkTaskTypeProvider) -> Bool {
    return lhs.type == rhs.type
}

public func !=(lhs: PoqNetworkTaskTypeProvider, rhs: PoqNetworkTaskTypeProvider) -> Bool {
    return lhs.type != rhs.type
}

public enum PoqNetworkTaskType: String {
    
    case undefined = "undefined"
    case homeBanner = "homeBanner"
    case categories = "categories"
    case productDetails = "productDetails"
    case pages = "pages"
    case pageDetails = "pageDetails"
    case splash = "splash"
    case productsByQuery = "productsByQuery"
    case productsByBundle = "productsByBundle"
    case productsByFilters = "productsByFilters"
    case productsByIds = "productsByIds"
    case productsByExternalIds = "productByExternalIds"
    case productsByCategory = "productsByCategory"
    case lookbookImages = "lookbookImages"
    case lookbookImageProducts = "lookbookImageProducts"
    case productsScan = "productsScan"
    case productsVisualSearch = "productsVisualSearch"
    case getMySizes = "getMySizes"
    case postMySizes = "postMySizes"
    case stores = "stores"
    case storeDetail = "storeDetail"
    case storeStock = "storeStock"
    case order = "order"
    case updateOrder = "updateOrder"
    case productReviews = "productReviews"
    case brands = "brands"
    case localization = "localization"
    case theme = "theme"
    case config = "config"
    case plugin = "plugin"
    case getBag = "getBag"
    case getBagWebView = "getBagWebView"
    case putBagWebView = "putBagWebView"
    case postBag = "postBag"
    case deleteBagItem = "deleteBagItem"
    case deleteAllBag = "deleteAllBag"
    case getWhishList = "getWhishList"
    case getWhishListProductIds = "getWhishListProductIds"
    case postWhishList = "postWhishList"
    case deleteWishList = "deleteWishList"
    case deleteAllWishList = "deleteAllWishList"
    case postFacebookAccount = "postFacebookAccount"
    case postAccount = "postAccount"
    case registerAccount = "registerAccount"
    case getAccount = "getAccount"
    case updateAccount = "updateAccount"
    case downloadAppCSS = "downloadAppCSS"
    case getOrderSummary = "getOrderSummary"
    case getOrderList = "getOrderList"
    case getBagItemCount = "getBagItemCount"
    case getWishListItemCount = "getWishListItemCount"
    case getVouchers = "getVouchers"
    case getOffers = "getOffers"
    case getVoucherDetails = "getVoucherDetails"
    case postVoucher = "postVoucher"
    case postStudentVoucher = "postStudentVoucher"
    case getCheckoutDetails = "getCheckoutDetails"
    case postAddresses = "postAddresses"
    case saveAddressesToOrder = "saveAddressesToOrder"
    case getAddresses = "getAddresses"
    case postDeliveryOption = "postDeliveryOption"
    case postPaymentOption = "postPaymentOption"
    case postOrder = "postOrder"
    case removeVoucher = "removeVoucher"
    case getUserAddresses = "getUserAddresses"
    case saveUserAddresses = "saveUserAddresses"
    case deleteUserAddress = "deleteUserAddress"
    case updateUserAddress = "updateUserAddress"
    case blocks = "blocks"
    case tinderProducts = "tinderProducts"
    case tinderProductsInCategory = "tinderProductsInCategory"
    case tinderLike = "tinderLike"
    case getStoryDetail = "getStoryDetail"
    case refreshToken = "refreshToken"
    case getOnboarding = "getOnboarding"
    case getModularBag = "getModularBag"
    case getGiftsAvailable = "getGiftsAvailable"
    case getVouchersDashboard = "getVouchersDashboard"
    case getGiftOptionsAvailable = "getGiftOptionsAvailable"
    case postGiftOptionsShoppingBag = "ostGiftOptionsShoppingBag"
    case addGiftsToBag = "addGiftsToBag"
    case getPredictiveSearch = "getPredictiveSearch"
    case startCartTransfer = "startCartTransfer"
    case completeCartTransfer = "completeCartTransfer"
    case recentlyViewed = "recentlyViewed"
    case clearRecentlyViewed = "clearRecentlyViewed"
    case appStories = "appStories"
    case appStoriesQueryProducts = "appStoriesQueryProducts"
    case postCartItems = "postCartItems"
    
    //MADE
    case getDeliveryOptionTypes
    case getDeliveryOptionsForType
    case postCustomDeliveryOption
    // MISSGUIDED
    case getCompleteGuestMail = "getCompleteGuestMail"
    
    // STRIPE
    case stripeCreateSource = "stripeCreateSource"
    case stripeCardTokenization = "stripeCardTokenization"
    case createCustomer = "createCustomer"
    case stripeAttachCard = "stripeAttachCard"
    case stripeAttachCardCreateCustomer = "stripeAttachCardCreateCustomer"
    case stripeCheckCardToken = "stripeCheckCardToken"
    case stripeDeleteCardToken = "stripeDeleteCardToken"
    case stripeGetCards = "stripeGetCards"
    
    // BRAINTREE
    case braintreeGenerateToken = "braintreeGenerateToken"
    case braintreeGenerateNonce = "braintreeGenerateNonce"
    case braintreeGetCustomer = "braintreeGetCustomer"
    case braintreeHandle3DSecurePayment = "braintreeHandle3DSecurePayment"
    case braintreeUpdateCustomer = "braintreeUpdateCustomer"
    case braintreeDeletePaymentSource = "braintreeDeletePaymentSource"

}

extension PoqNetworkTaskType: PoqNetworkTaskTypeProvider {
    public var type: String {
        return rawValue
    }
}

public func ==(lhs: PoqNetworkTaskTypeProvider, rhs: PoqNetworkTaskType) -> Bool {
    return lhs.type == rhs.type
}

public func !=(lhs: PoqNetworkTaskTypeProvider, rhs: PoqNetworkTaskType) -> Bool {
    return lhs.type != rhs.type
}
