//
//  PoqTracker.swift
//  Public API for sending abstracted tracking events
//
//  Created by Mahmut Canga on 09/02/2015.
//  Copyright (c) 2015 macromania. All rights reserved.
//

import Foundation
import PoqModuling
import PoqNetworking
import PoqUtilities

public struct CheckoutAction {
   public var step: Int
   public var option: String
}

public struct CheckoutActionType {
    
    public static let ReviewBag = CheckoutAction(step:1, option:"ReviewBag")
    public static let OrderSummary =  CheckoutAction(step:2, option:"OrderSummary")
    public static let BillingAddress =  CheckoutAction(step:3, option:"BillingAddress")
    public static let ShippingAddress =  CheckoutAction(step:4, option:"ShippingAddress")
    public static let DeliveryOptions =  CheckoutAction(step:5, option:"DeliveryOptions")
    public static let PaymentOptions =  CheckoutAction(step:6, option:"PaymentOptions")
    public static let Payment =  CheckoutAction(step:7, option:"Payment")
    public static let OrderCompleted =  CheckoutAction(step:8, option:"OrderCompleted")
}

open class PoqTracker : PoqTrackingProtocol {

    /* Singleton access */
    public static let sharedInstance: PoqTracker = PoqTracker()

    public var trackingProviders: [PoqTrackingProtocol]?
    
   public static let attributionUrlUserDefaultKey = "attributionUrlUserDefaultKey"
   public static let attributionScreenEventId = "AppScreen"

    // TODO trigger from the splash screen
    func initCloudSettings() {
        PoqTrackerEventType.AddToBag = EventTrackerSettings.sharedInstance.eventTypeAddToBag
        PoqTrackerEventType.AddToWishList = EventTrackerSettings.sharedInstance.eventTypeAddToWishList
        PoqTrackerEventType.AppBackground = EventTrackerSettings.sharedInstance.eventTypeAppBackground
        PoqTrackerEventType.AppForeground = EventTrackerSettings.sharedInstance.eventTypeAppForeground
        PoqTrackerEventType.AppLaunch = EventTrackerSettings.sharedInstance.eventTypeAppLaunch
        PoqTrackerEventType.ApplePay = EventTrackerSettings.sharedInstance.eventTypeApplePay
        PoqTrackerEventType.ApplyFilters = EventTrackerSettings.sharedInstance.eventTypeApplyFilters
        PoqTrackerEventType.ApplySort = EventTrackerSettings.sharedInstance.eventTypeApplySort
        PoqTrackerEventType.Bag = EventTrackerSettings.sharedInstance.eventTypeBag
        PoqTrackerEventType.BagMerged = EventTrackerSettings.sharedInstance.eventTypeBagMerged
        PoqTrackerEventType.BagScreen = EventTrackerSettings.sharedInstance.eventTypeBagScreen
        PoqTrackerEventType.CategoryLoaded = EventTrackerSettings.sharedInstance.eventTypeCategoryLoaded
        PoqTrackerEventType.CheckoutError = EventTrackerSettings.sharedInstance.eventTypeCheckoutError
        PoqTrackerEventType.CheckoutExit = EventTrackerSettings.sharedInstance.eventTypeCheckoutExit
        PoqTrackerEventType.CheckoutOrderUpdate = EventTrackerSettings.sharedInstance.eventTypeCheckoutOrderUpdate
        PoqTrackerEventType.CheckoutURLRequest = EventTrackerSettings.sharedInstance.eventTypeCheckoutURLRequest
        PoqTrackerEventType.FullScreenImageViewLoad = EventTrackerSettings.sharedInstance.eventTypeFullScreenImageViewLoad
        PoqTrackerEventType.FullScreenImageViewSharing = EventTrackerSettings.sharedInstance.eventTypeFullScreenImageViewSharing
        PoqTrackerEventType.GroupProductListLoad = EventTrackerSettings.sharedInstance.eventTypeGroupProductListLoad
        PoqTrackerEventType.HomeAction = EventTrackerSettings.sharedInstance.eventTypeHomeAction
        PoqTrackerEventType.LayerActions = EventTrackerSettings.sharedInstance.eventTypeLayerActions
        PoqTrackerEventType.LayerSales = EventTrackerSettings.sharedInstance.eventTypeLayerSales
        PoqTrackerEventType.LinkClicked = EventTrackerSettings.sharedInstance.eventTypeLinkClicked
        PoqTrackerEventType.LookBookOpen = EventTrackerSettings.sharedInstance.eventTypeLookBookOpen
        PoqTrackerEventType.LookBookShopIt = EventTrackerSettings.sharedInstance.eventTypeLookBookShopIt
        PoqTrackerEventType.MyReward = EventTrackerSettings.sharedInstance.eventTypeMyReward
        PoqTrackerEventType.MySize = EventTrackerSettings.sharedInstance.eventTypeMySize
        PoqTrackerEventType.MyStore = EventTrackerSettings.sharedInstance.eventTypeMyStore
        PoqTrackerEventType.NativeBagScreen = EventTrackerSettings.sharedInstance.eventTypeNativeBagScreen
        PoqTrackerEventType.NativeCheckout = EventTrackerSettings.sharedInstance.eventTypeNativeCheckout
        PoqTrackerEventType.OpenReview = EventTrackerSettings.sharedInstance.eventTypeOpenReview
        PoqTrackerEventType.OrderList = EventTrackerSettings.sharedInstance.eventTypeOrderList
        PoqTrackerEventType.OrderSummary = EventTrackerSettings.sharedInstance.eventTypeOrderSummary
        PoqTrackerEventType.PageScreen = EventTrackerSettings.sharedInstance.eventTypePageScreen
        PoqTrackerEventType.ProductAvailabilityLoad = EventTrackerSettings.sharedInstance.eventTypeProductAvailabilityLoad
        PoqTrackerEventType.ProductDetailLoad = EventTrackerSettings.sharedInstance.eventTypeProductDetailLoad
        PoqTrackerEventType.ProductListLoad = EventTrackerSettings.sharedInstance.eventTypeProductListLoad
        PoqTrackerEventType.PushNotification = EventTrackerSettings.sharedInstance.eventTypePushNotification
        PoqTrackerEventType.RecentlyViewed = EventTrackerSettings.sharedInstance.eventTypeRecentlyViewed
        PoqTrackerEventType.Recognition = EventTrackerSettings.sharedInstance.eventTypeRecognition
        PoqTrackerEventType.Register = EventTrackerSettings.sharedInstance.eventTypeRegister
        PoqTrackerEventType.RemoveFromBag = EventTrackerSettings.sharedInstance.eventTypeRemoveFromBag
        PoqTrackerEventType.RemoveFromWishList = EventTrackerSettings.sharedInstance.eventTypeRemoveFromWishList
        PoqTrackerEventType.ReviewsLoad = EventTrackerSettings.sharedInstance.eventTypeReviewsLoad
        PoqTrackerEventType.RewardCard = EventTrackerSettings.sharedInstance.eventTypeRewardCard
        PoqTrackerEventType.Scan = EventTrackerSettings.sharedInstance.eventTypeScan
        PoqTrackerEventType.Search = EventTrackerSettings.sharedInstance.eventTypeSearch
        PoqTrackerEventType.SecureCheckout = EventTrackerSettings.sharedInstance.eventTypeSecureCheckout
        PoqTrackerEventType.SelectMySizes = EventTrackerSettings.sharedInstance.eventTypeSelectMySizes
        PoqTrackerEventType.SelectMyStore = EventTrackerSettings.sharedInstance.eventTypeSelectMyStore
        PoqTrackerEventType.SetSizeForKids = EventTrackerSettings.sharedInstance.eventTypeSetSizeForKids
        PoqTrackerEventType.SetSizeForMale = EventTrackerSettings.sharedInstance.eventTypeSetSizeForMale
        PoqTrackerEventType.SetSizeForWomen = EventTrackerSettings.sharedInstance.eventTypeSetSizeForWomen
        PoqTrackerEventType.SetSizeForOppositeGender = EventTrackerSettings.sharedInstance.eventTypeSetSizeForOppositeGender
        PoqTrackerEventType.Share = EventTrackerSettings.sharedInstance.eventTypeShare
        PoqTrackerEventType.ShopScreenLoaded = EventTrackerSettings.sharedInstance.eventTypeShopScreenLoaded
        PoqTrackerEventType.Store = EventTrackerSettings.sharedInstance.eventTypeStore
        PoqTrackerEventType.StoreAddToFavorite = EventTrackerSettings.sharedInstance.eventTypeStoreAddToFavorite
        PoqTrackerEventType.StoreList = EventTrackerSettings.sharedInstance.eventTypeStoreList
        PoqTrackerEventType.SwipeToHype = EventTrackerSettings.sharedInstance.eventTypeSwipeToHype
        PoqTrackerEventType.TermsAndConditions = EventTrackerSettings.sharedInstance.eventTypeTermsAndConditions
        PoqTrackerEventType.User = EventTrackerSettings.sharedInstance.eventTypeUser
        PoqTrackerEventType.WishScreen = EventTrackerSettings.sharedInstance.eventTypeWishScreen
        
        PoqTrackerActionType.ActionLike = EventTrackerSettings.sharedInstance.actionTypeActionLike
        PoqTrackerActionType.ActionDislike = EventTrackerSettings.sharedInstance.actionTypeActionDislike
        PoqTrackerActionType.ActionOpenPDP = EventTrackerSettings.sharedInstance.actionTypeActionOpenPDP
        PoqTrackerActionType.ActionEndOfDeckInCategory = EventTrackerSettings.sharedInstance.actionTypeActionEndOfDeckInCategory
        PoqTrackerActionType.ActionEndOfDeckInProducts = EventTrackerSettings.sharedInstance.actionTypeActionEndOfDeckInProducts
        PoqTrackerActionType.ActionSwitchToAllProductsFeed = EventTrackerSettings.sharedInstance.actionTypeActionSwitchToAllProductsFeed
        PoqTrackerActionType.ActivityType = EventTrackerSettings.sharedInstance.actionTypeActivityType
        PoqTrackerActionType.AddToBag = EventTrackerSettings.sharedInstance.actionTypeAddToBag
        PoqTrackerActionType.AddToWishlist = EventTrackerSettings.sharedInstance.actionTypeAddToWishlist
        PoqTrackerActionType.AppDelegate = EventTrackerSettings.sharedInstance.actionTypeAppDelegate
        PoqTrackerActionType.BagMerged = EventTrackerSettings.sharedInstance.actionTypeBagMerged
        PoqTrackerActionType.Category = EventTrackerSettings.sharedInstance.actionTypeCategory
        PoqTrackerActionType.CategoryLoaded = EventTrackerSettings.sharedInstance.actionTypeCategoryLoaded
        PoqTrackerActionType.Checkout = EventTrackerSettings.sharedInstance.actionTypeCheckout
        PoqTrackerActionType.CheckoutPrice = EventTrackerSettings.sharedInstance.actionTypeCheckoutPrice
        PoqTrackerActionType.Colours = EventTrackerSettings.sharedInstance.actionTypeColours
        PoqTrackerActionType.Count = EventTrackerSettings.sharedInstance.actionTypeCount
        PoqTrackerActionType.CreditCard = EventTrackerSettings.sharedInstance.actionTypeCreditCard
        PoqTrackerActionType.DeepLink = EventTrackerSettings.sharedInstance.actionTypeDeepLink
        PoqTrackerActionType.Error = EventTrackerSettings.sharedInstance.actionTypeError
        PoqTrackerActionType.FavouriteStore = EventTrackerSettings.sharedInstance.actionTypeFavouriteStore
        PoqTrackerActionType.ImageURL = EventTrackerSettings.sharedInstance.actionTypeImageURL
        PoqTrackerActionType.InvalidTotalCost = EventTrackerSettings.sharedInstance.actionTypeInvalidTotalCost
        PoqTrackerActionType.FailedCode = EventTrackerSettings.sharedInstance.actionTypeFailedCode
        PoqTrackerActionType.Female = EventTrackerSettings.sharedInstance.actionTypeFemale
        PoqTrackerActionType.Loaded = EventTrackerSettings.sharedInstance.actionTypeLoaded
        PoqTrackerActionType.Login = EventTrackerSettings.sharedInstance.actionTypeLogin
        PoqTrackerActionType.Logout = EventTrackerSettings.sharedInstance.actionTypeLogout
        PoqTrackerActionType.Male = EventTrackerSettings.sharedInstance.actionTypeMale
        PoqTrackerActionType.MyProfile = EventTrackerSettings.sharedInstance.actionTypeMyProfile
        PoqTrackerActionType.MySizes = EventTrackerSettings.sharedInstance.actionTypeMySizes
        PoqTrackerActionType.NoResults = EventTrackerSettings.sharedInstance.actionTypeNoResults
        PoqTrackerActionType.NumberOfReviews = EventTrackerSettings.sharedInstance.actionTypeNumberOfReviews
        PoqTrackerActionType.OpenExternalLink = EventTrackerSettings.sharedInstance.actionTypeOpenExternalLink
        PoqTrackerActionType.OpenedLayarViewer = EventTrackerSettings.sharedInstance.actionTypeOpenedLayarViewer
        PoqTrackerActionType.OpenQRCode = EventTrackerSettings.sharedInstance.actionTypeOpenQRCode
        PoqTrackerActionType.Order = EventTrackerSettings.sharedInstance.actionTypeOrder
        PoqTrackerActionType.Product = EventTrackerSettings.sharedInstance.actionTypeProduct
        PoqTrackerActionType.ProductID = EventTrackerSettings.sharedInstance.actionTypeProductID
        PoqTrackerActionType.ProductName = EventTrackerSettings.sharedInstance.actionTypeProductName
        PoqTrackerActionType.PushNotificationLandingPage = EventTrackerSettings.sharedInstance.actionTypePushNotificationLandingPage
        PoqTrackerActionType.PurchasedAfterUsingScanner = EventTrackerSettings.sharedInstance.actionTypePurchasedAfterUsingScanner
        PoqTrackerActionType.Recognition = EventTrackerSettings.sharedInstance.actionTypeRecognition
        PoqTrackerActionType.Register = EventTrackerSettings.sharedInstance.actionTypeRegister
        PoqTrackerActionType.RegisterRewardCard = EventTrackerSettings.sharedInstance.actionTypeRegisterRewardCard
        PoqTrackerActionType.RemoveFromBag = EventTrackerSettings.sharedInstance.actionTypeRemoveFromBag
        PoqTrackerActionType.RemoveFromWishList = EventTrackerSettings.sharedInstance.actionTypeRemoveFromWishList
        PoqTrackerActionType.Refresh = EventTrackerSettings.sharedInstance.actionTypeRefresh
        PoqTrackerActionType.Scan = EventTrackerSettings.sharedInstance.actionTypeScan
        PoqTrackerActionType.Screen = EventTrackerSettings.sharedInstance.actionTypeScreen
        PoqTrackerActionType.Search = EventTrackerSettings.sharedInstance.actionTypeSearch
        PoqTrackerActionType.SelectSize = EventTrackerSettings.sharedInstance.actionTypeSelectSize
        PoqTrackerActionType.ShareTapped = EventTrackerSettings.sharedInstance.actionTypeShareTapped
        PoqTrackerActionType.Shop = EventTrackerSettings.sharedInstance.actionTypeShop
        PoqTrackerActionType.ShopItButtonClicked = EventTrackerSettings.sharedInstance.actionTypeShopItButtonClicked
        PoqTrackerActionType.SignUp = EventTrackerSettings.sharedInstance.actionTypeSignUp
        PoqTrackerActionType.Size = EventTrackerSettings.sharedInstance.actionTypeSize
        PoqTrackerActionType.SortBy = EventTrackerSettings.sharedInstance.actionTypeSortBy
        PoqTrackerActionType.Store = EventTrackerSettings.sharedInstance.actionTypeStore
        PoqTrackerActionType.StoreName = EventTrackerSettings.sharedInstance.actionTypeStoreName
        PoqTrackerActionType.Successful = EventTrackerSettings.sharedInstance.actionTypeSuccessful
        PoqTrackerActionType.SuccessfulScan = EventTrackerSettings.sharedInstance.actionTypeSuccessfulScan
        PoqTrackerActionType.Title = EventTrackerSettings.sharedInstance.actionTypeTitle
        PoqTrackerActionType.Unsuccessful = EventTrackerSettings.sharedInstance.actionTypeUnsuccessful
        PoqTrackerActionType.UnsuccessfulScan = EventTrackerSettings.sharedInstance.actionTypeUnsuccessfulScan
        PoqTrackerActionType.UpdateAccount = EventTrackerSettings.sharedInstance.actionTypeUpdateAccount
        PoqTrackerActionType.UpdatedTotalCost = EventTrackerSettings.sharedInstance.actionTypeUpdatedTotalCost
        PoqTrackerActionType.URL = EventTrackerSettings.sharedInstance.actionTypeURL
        
        PoqTrackerLabelType.Featured = EventTrackerSettings.sharedInstance.labelTypeFeatured
        PoqTrackerLabelType.Female = EventTrackerSettings.sharedInstance.labelTypeFemale
        PoqTrackerLabelType.FromHomescreen = EventTrackerSettings.sharedInstance.labelTypeFromHomescreen
        PoqTrackerLabelType.FromNavigation = EventTrackerSettings.sharedInstance.labelTypeFromNavigation
        PoqTrackerLabelType.HisSizes = EventTrackerSettings.sharedInstance.labelTypeHisSizes
        PoqTrackerLabelType.HerSizes = EventTrackerSettings.sharedInstance.labelTypeHerSizes
        PoqTrackerLabelType.Kids = EventTrackerSettings.sharedInstance.labelTypeKids
        PoqTrackerLabelType.Loaded = EventTrackerSettings.sharedInstance.labelTypeLoaded
        PoqTrackerLabelType.Male = EventTrackerSettings.sharedInstance.labelTypeMale
        PoqTrackerLabelType.Newest = EventTrackerSettings.sharedInstance.labelTypeNewest
        PoqTrackerLabelType.NotCompleted = EventTrackerSettings.sharedInstance.labelTypeNotCompleted
        PoqTrackerLabelType.Price = EventTrackerSettings.sharedInstance.labelTypePrice
        PoqTrackerLabelType.PurchasedAfterUsingScanner = EventTrackerSettings.sharedInstance.labelTypePurchasedAfterUsingScanner
        PoqTrackerLabelType.Rating = EventTrackerSettings.sharedInstance.labelTypeRating
        PoqTrackerLabelType.Received = EventTrackerSettings.sharedInstance.labelTypeReceived
        PoqTrackerLabelType.SignIn = EventTrackerSettings.sharedInstance.labelTypeSignIn
        PoqTrackerLabelType.SignUp = EventTrackerSettings.sharedInstance.labelTypeSignUp
        PoqTrackerLabelType.Share = EventTrackerSettings.sharedInstance.labelTypeShare
        PoqTrackerLabelType.Shop = EventTrackerSettings.sharedInstance.labelTypeShop
        PoqTrackerLabelType.SuccessfulScan = EventTrackerSettings.sharedInstance.labelTypeSuccessfulScan
        PoqTrackerLabelType.Unknown = EventTrackerSettings.sharedInstance.labelTypeUnknown
        PoqTrackerLabelType.UnsuccessfullScann = EventTrackerSettings.sharedInstance.labelTypeUnsuccessfullScann
        PoqTrackerLabelType.ValueSwipe = EventTrackerSettings.sharedInstance.labelTypeValueSwipe
        PoqTrackerLabelType.ValueTap = EventTrackerSettings.sharedInstance.labelTypeValueTap
        
    }
    
    /*
     Tracking providers initializer
     
     :param: trackingSettings Settings object for enabling tracking providers
     */
    public func initProviders() {
        
        trackingProviders = []
        
        for module in PoqPlatform.shared.modules {
            let moduleTrackers = module.createTrackers()
            
            trackingProviders?.append(contentsOf: moduleTrackers)
        }
        
    }
    
    /* initial checkout order */
    
    open func trackInitOrder(_ trackingOrder: PoqTrackingOrder) {
        
        trackingProviders?.forEach({ $0.trackInitOrder(trackingOrder) })
    }
    
    /// Tracks successfully completed checkout order.
    /// - parameter trackingOrder: Order details to be tracked.
    public func trackCompleteOrder(_ order: PoqTrackingOrder) {
        
        trackingProviders?.forEach({ $0.trackCompleteOrder(order) })
    }
    
    open func trackProductDetails(for product: PoqTrackingProduct) {
        
        trackingProviders?.forEach({ $0.trackProductDetails(for: product) })
    }
    
    open func trackGroupedProducts(forParent parentProduct: PoqTrackingProduct, products: [PoqTrackingProduct]) {

        trackingProviders?.forEach({ $0.trackGroupedProducts(forParent: parentProduct, products: products) })
    }
    
    open func trackAddToBag(for product: PoqTrackingProduct, productSize: PoqTrackingProductSize) {
        
        trackingProviders?.forEach({ $0.trackAddToBag(for: product, productSize: productSize) })
    }
    
    /// Tracks event based analytics data with all added tracking providers.
    open func logAnalyticsEvent(_ event: String, action: String, label: String, value: Double = 0, extraParams: [String: String]?) {
        
        guard let providers = trackingProviders else {
            Log.warning("!!!PoqTracker is not initialized!!!")
            return
        }
        
        let event = filter(string: event)
        let action = filter(string: action)
        let label = label.isEmpty ? "(not set)" : filter(string: label)
        
        var extraParams = extraParams ?? [:]
        extraParams["PoqUserID"] = User.getUserId()
        extraParams = filter(parameters: extraParams)
      
        providers.forEach({ $0.logAnalyticsEvent(event, action: action, label: label, value: value, extraParams: extraParams) })
    }

    /// Tracks the screen name with all added tracking providers (usually just GA).
    /// - parameter screenName: Name of the screen or view to be tracked.
    open func trackScreenName(_ screenName: String) {
        
        let screenName = filter(string: screenName)
        trackingProviders?.forEach({ $0.trackScreenName(screenName) })
    }
    
    open func trackCheckoutAction(_ step: Int, option: String) {
        
        let option = filter(string: option)
        trackingProviders?.forEach({ $0.trackCheckoutAction(step, option: option) })
    }
    
    open func trackCampaignAttribution(from url: URL) {
        
        trackingProviders?.forEach({ $0.trackCampaignAttribution(from: url)})
    }
}

extension PoqTracker {
    
    /// Parses all parameter values in the dictionary to filter out emails, replacing them with {email}.
    internal final func filter(parameters: [String: String]) -> [String: String] {
        var parameters = parameters
        for pair in parameters {
            parameters[pair.key] = filter(string: pair.value)
        }
        return parameters
    }
    
    /// Parses the specified tracking string to filter out emails, replacing them with {email}.
    internal final func filter(string: String) -> String {
        let nsstring = NSMutableString(string: string)
        
        // Parse all emails in the tracking string and replace them with {email}
        if let emailRegex = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}") {
            let range = NSRange(location: 0, length: nsstring.length)
            emailRegex.replaceMatches(in: nsstring, options: [], range: range, withTemplate: "{email}")
        }
        
        return nsstring as String
    }
    
}
