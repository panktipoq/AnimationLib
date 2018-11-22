//
//  PoqTrackerHelper.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 2/22/16.
//
//

import Foundation
import PoqModuling
import PoqNetworking

open class PoqTrackerEventType {
    
    public static var  ActionTypeSearchHistory = EventTrackerSettings.sharedInstance.eventTypeSearchHistory
    public static var  AddToBag = EventTrackerSettings.sharedInstance.eventTypeAddToBag
    public static var  AddToWishList = EventTrackerSettings.sharedInstance.eventTypeAddToWishList
    public static var  AppBackground = EventTrackerSettings.sharedInstance.eventTypeAppBackground
    public static var  AppForeground = EventTrackerSettings.sharedInstance.eventTypeAppForeground
    public static var  AppLaunch = EventTrackerSettings.sharedInstance.eventTypeAppLaunch
    public static var  ApplePay = EventTrackerSettings.sharedInstance.eventTypeApplePay
    public static var  ApplyFilters = EventTrackerSettings.sharedInstance.eventTypeApplyFilters
    public static var  ApplySort = EventTrackerSettings.sharedInstance.eventTypeApplySort
    public static var  AppStories = EventTrackerSettings.sharedInstance.eventTypeAppStories
    public static var  Bag = EventTrackerSettings.sharedInstance.eventTypeBag
    public static var  BagMerged = EventTrackerSettings.sharedInstance.eventTypeBagMerged
    public static var  BagScreen = EventTrackerSettings.sharedInstance.eventTypeBagScreen
    public static var  CategoryLoaded = EventTrackerSettings.sharedInstance.eventTypeCategoryLoaded
    public static var  CheckoutError = EventTrackerSettings.sharedInstance.eventTypeCheckoutError
    public static var  CheckoutExit = EventTrackerSettings.sharedInstance.eventTypeCheckoutExit
    public static var  CheckoutOrderUpdate = EventTrackerSettings.sharedInstance.eventTypeCheckoutOrderUpdate
    public static var  CheckoutURLRequest = EventTrackerSettings.sharedInstance.eventTypeCheckoutURLRequest
    public static var  FullScreenImageViewLoad = EventTrackerSettings.sharedInstance.eventTypeFullScreenImageViewLoad
    public static var  FullScreenImageViewSharing = EventTrackerSettings.sharedInstance.eventTypeFullScreenImageViewSharing
    public static var  GroupProductListLoad = EventTrackerSettings.sharedInstance.eventTypeGroupProductListLoad
    public static var  HomeAction = EventTrackerSettings.sharedInstance.eventTypeHomeAction
    public static var  LayerActions = EventTrackerSettings.sharedInstance.eventTypeLayerActions
    public static var  LayerSales = EventTrackerSettings.sharedInstance.eventTypeLayerSales
    public static var  LinkClicked = EventTrackerSettings.sharedInstance.eventTypeLinkClicked
    public static var  LookBookOpen = EventTrackerSettings.sharedInstance.eventTypeLookBookOpen
    public static var  LookBookShopIt = EventTrackerSettings.sharedInstance.eventTypeLookBookShopIt
    public static var  MyReward = EventTrackerSettings.sharedInstance.eventTypeMyReward
    public static var  MySize = EventTrackerSettings.sharedInstance.eventTypeMySize
    public static var  MyStore = EventTrackerSettings.sharedInstance.eventTypeMyStore
    public static var  NativeBagScreen = EventTrackerSettings.sharedInstance.eventTypeNativeBagScreen
    public static var  NativeCheckout = EventTrackerSettings.sharedInstance.eventTypeNativeCheckout
    public static var  Onboarding = EventTrackerSettings.sharedInstance.eventTypeOnboarding
    public static var  OpenReview = EventTrackerSettings.sharedInstance.eventTypeOpenReview
    public static var  OrderList = EventTrackerSettings.sharedInstance.eventTypeOrderList
    public static var  OrderSummary = EventTrackerSettings.sharedInstance.eventTypeOrderSummary
    public static var  PageScreen = EventTrackerSettings.sharedInstance.eventTypePageScreen
    public static var  PeekAction = EventTrackerSettings.sharedInstance.eventTypePeekAction
    public static var  PeekOpen = EventTrackerSettings.sharedInstance.eventTypePeekOpen
    public static var  ProductAvailabilityLoad = EventTrackerSettings.sharedInstance.eventTypeProductAvailabilityLoad
    public static var  ProductDetailLoad = EventTrackerSettings.sharedInstance.eventTypeProductDetailLoad
    public static var  ProductListLoad = EventTrackerSettings.sharedInstance.eventTypeProductListLoad
    public static var  PushNotification = EventTrackerSettings.sharedInstance.eventTypePushNotification
    public static var  RecentlyViewed = EventTrackerSettings.sharedInstance.eventTypeRecentlyViewed
    public static var  Recognition = EventTrackerSettings.sharedInstance.eventTypeRecognition
    public static var  Register = EventTrackerSettings.sharedInstance.eventTypeRegister
    public static var  RemoveFromBag = EventTrackerSettings.sharedInstance.eventTypeRemoveFromBag
    public static var  RemoveFromBagSwiping = EventTrackerSettings.sharedInstance.eventTypeRemoveFromBagSwiping
    public static var  RemoveFromWishList = EventTrackerSettings.sharedInstance.eventTypeRemoveFromWishList
    public static var  ReviewsLoad = EventTrackerSettings.sharedInstance.eventTypeReviewsLoad
    public static var  RewardCard = EventTrackerSettings.sharedInstance.eventTypeRewardCard
    public static var  Scan = EventTrackerSettings.sharedInstance.eventTypeScan
    public static var  Search = EventTrackerSettings.sharedInstance.eventTypeSearch
    public static var  SecureCheckout = EventTrackerSettings.sharedInstance.eventTypeSecureCheckout
    public static var  SelectMySizes = EventTrackerSettings.sharedInstance.eventTypeSelectMySizes
    public static var  SelectMyStore = EventTrackerSettings.sharedInstance.eventTypeSelectMyStore
    public static var  SetSizeForKids = EventTrackerSettings.sharedInstance.eventTypeSetSizeForKids
    public static var  SetSizeForMale = EventTrackerSettings.sharedInstance.eventTypeSetSizeForMale
    public static var  SetSizeForWomen = EventTrackerSettings.sharedInstance.eventTypeSetSizeForWomen
    public static var  SetSizeForOppositeGender = EventTrackerSettings.sharedInstance.eventTypeSetSizeForOppositeGender
    public static var  Share = EventTrackerSettings.sharedInstance.eventTypeShare
    public static var  ShopScreenLoaded = EventTrackerSettings.sharedInstance.eventTypeShopScreenLoaded
    public static var  Store = EventTrackerSettings.sharedInstance.eventTypeStore
    public static var  StoreAddToFavorite = EventTrackerSettings.sharedInstance.eventTypeStoreAddToFavorite
    public static var  StoreList = EventTrackerSettings.sharedInstance.eventTypeStoreList
    public static var  SwipeToHype = EventTrackerSettings.sharedInstance.eventTypeSwipeToHype
    public static var  TermsAndConditions = EventTrackerSettings.sharedInstance.eventTypeTermsAndConditions
    public static var  User = EventTrackerSettings.sharedInstance.eventTypeUser
    public static var  Videos = EventTrackerSettings.sharedInstance.eventTypeVideos
    public static var  VisualSearch = EventTrackerSettings.sharedInstance.eventTypeVisualSearch
    public static var  WishScreen = EventTrackerSettings.sharedInstance.eventTypeWishScreen
}

open class PoqTrackerActionType {
    
    public static var  ActionLike = EventTrackerSettings.sharedInstance.actionTypeActionLike
    public static var  ActionDislike = EventTrackerSettings.sharedInstance.actionTypeActionDislike
    public static var  ActionOpenPDP = EventTrackerSettings.sharedInstance.actionTypeActionOpenPDP
    public static var  ActionEndOfDeckInCategory = EventTrackerSettings.sharedInstance.actionTypeActionEndOfDeckInCategory
    public static var  ActionEndOfDeckInProducts = EventTrackerSettings.sharedInstance.actionTypeActionEndOfDeckInProducts
    public static var  ActionSwitchToAllProductsFeed = EventTrackerSettings.sharedInstance.actionTypeActionSwitchToAllProductsFeed
    public static var  ActivityType = EventTrackerSettings.sharedInstance.actionTypeActivityType
    public static var  AddToBag = EventTrackerSettings.sharedInstance.actionTypeAddToBag
    public static var  AddToWishlist = EventTrackerSettings.sharedInstance.actionTypeAddToWishlist
    public static var  AppDelegate = EventTrackerSettings.sharedInstance.actionTypeAppDelegate
    public static var  AppStoriesDismiss = EventTrackerSettings.sharedInstance.actionTypeAppStoriesDismiss
    public static var  AppStoriesOpen = EventTrackerSettings.sharedInstance.actionTypeAppStoriesOpen
    public static var  AppStoriesAutoOpen = EventTrackerSettings.sharedInstance.actionTypeAppStoriesAutoOpen
    public static var  AppStoriesPLPSwipe = EventTrackerSettings.sharedInstance.actionTypeAppStoriesPLPSwipe
    public static var  AppStoriesPDPSwipe = EventTrackerSettings.sharedInstance.actionTypeAppStoriesPDPSwipe
    public static var  AppStoriesVideoSwipe = EventTrackerSettings.sharedInstance.actionTypeAppStoriesVideoSwipe
    public static var  AppStoriesWebViewSwipe = EventTrackerSettings.sharedInstance.actionTypeAppStoriesWebViewSwipe
    public static var  BagMerged = EventTrackerSettings.sharedInstance.actionTypeBagMerged
    public static var  Category = EventTrackerSettings.sharedInstance.actionTypeCategory
    public static var  CategoryLoaded = EventTrackerSettings.sharedInstance.actionTypeCategoryLoaded
    public static var  Checkout = EventTrackerSettings.sharedInstance.actionTypeCheckout
    public static var  CheckoutPrice = EventTrackerSettings.sharedInstance.actionTypeCheckoutPrice
    public static var  Colours = EventTrackerSettings.sharedInstance.actionTypeColours
    public static var  Brands = EventTrackerSettings.sharedInstance.actionTypeBrands
    public static var  Sizes = EventTrackerSettings.sharedInstance.actionTypeSizes
    public static var  Categories = EventTrackerSettings.sharedInstance.actionTypeCategories
    public static var  MinPrice = EventTrackerSettings.sharedInstance.actionTypeMinPrice
    public static var  MaxPrice = EventTrackerSettings.sharedInstance.actionTypeMaxPrice
    public static var  Styles = EventTrackerSettings.sharedInstance.actionTypeStyles
    public static var  Count = EventTrackerSettings.sharedInstance.actionTypeCount
    public static var  CreditCard = EventTrackerSettings.sharedInstance.actionTypeCreditCard
    public static var  DeepLink = EventTrackerSettings.sharedInstance.actionTypeDeepLink
    public static var  Error = EventTrackerSettings.sharedInstance.actionTypeError
    public static var  FavouriteStore = EventTrackerSettings.sharedInstance.actionTypeFavouriteStore
    public static var  ImageURL = EventTrackerSettings.sharedInstance.actionTypeImageURL
    public static var  InvalidTotalCost = EventTrackerSettings.sharedInstance.actionTypeInvalidTotalCost
    public static var  FailedCode = EventTrackerSettings.sharedInstance.actionTypeFailedCode
    public static var  Female = EventTrackerSettings.sharedInstance.actionTypeFemale
    public static var  Loaded = EventTrackerSettings.sharedInstance.actionTypeLoaded
    public static var  Login = EventTrackerSettings.sharedInstance.actionTypeLogin
    public static var  Logout = EventTrackerSettings.sharedInstance.actionTypeLogout
    public static var  Male = EventTrackerSettings.sharedInstance.actionTypeMale
    public static var  MyProfile = EventTrackerSettings.sharedInstance.actionTypeMyProfile
    public static var  MySizes = EventTrackerSettings.sharedInstance.actionTypeMySizes
    public static var  NoResults = EventTrackerSettings.sharedInstance.actionTypeNoResults
    public static var  NumberOfReviews = EventTrackerSettings.sharedInstance.actionTypeNumberOfReviews
    public static var  OnboardingSwipe = EventTrackerSettings.sharedInstance.actionTypeOnboardingSwipe
    public static var  OnboardingSkip = EventTrackerSettings.sharedInstance.actionTypeOnboardingSkip
    public static var  OpenExternalLink = EventTrackerSettings.sharedInstance.actionTypeOpenExternalLink
    public static var  OpenedLayarViewer = EventTrackerSettings.sharedInstance.actionTypeOpenedLayarViewer
    public static var  OpenQRCode = EventTrackerSettings.sharedInstance.actionTypeOpenQRCode
    public static var  Order = EventTrackerSettings.sharedInstance.actionTypeOrder
    public static var  PeekAddToWishlistSKU = EventTrackerSettings.sharedInstance.actionTypePeekAddToWishlistSKU
    public static var  PeekAddToWishlistTitle = EventTrackerSettings.sharedInstance.actionTypePeekAddToWishlistTitle
    public static var  PeekProductSKU = EventTrackerSettings.sharedInstance.actionTypePeekProductSKU
    public static var  PeekProductTitle = EventTrackerSettings.sharedInstance.actionTypePeekProductTitle
    public static var  PeekShareSKU = EventTrackerSettings.sharedInstance.actionTypePeekShareSKU
    public static var  PeekShareTitle = EventTrackerSettings.sharedInstance.actionTypePeekShareTitle
    public static var  PeekViewDetailsSKU = EventTrackerSettings.sharedInstance.actionTypePeekViewDetailsSKU
    public static var  PeekViewDetailsTitle = EventTrackerSettings.sharedInstance.actionTypePeekViewDetailsTitle
    public static var  Play = EventTrackerSettings.sharedInstance.actionTypePlay
    public static var  Product = EventTrackerSettings.sharedInstance.actionTypeProduct
    public static var  ProductID = EventTrackerSettings.sharedInstance.actionTypeProductID
    public static var  ProductName = EventTrackerSettings.sharedInstance.actionTypeProductName
    public static var  PushNotificationLandingPage = EventTrackerSettings.sharedInstance.actionTypePushNotificationLandingPage
    public static var  PurchasedAfterUsingScanner = EventTrackerSettings.sharedInstance.actionTypePurchasedAfterUsingScanner
    public static var  Recognition = EventTrackerSettings.sharedInstance.actionTypeRecognition
    public static var  Register = EventTrackerSettings.sharedInstance.actionTypeRegister
    public static var  RegisterRewardCard = EventTrackerSettings.sharedInstance.actionTypeRegisterRewardCard
    public static var  RemoveFromBag = EventTrackerSettings.sharedInstance.actionTypeRemoveFromBag
    public static var  RemoveFromWishList = EventTrackerSettings.sharedInstance.actionTypeRemoveFromWishList
    public static var  Refresh = EventTrackerSettings.sharedInstance.actionTypeRefresh
    public static var  Scan = EventTrackerSettings.sharedInstance.actionTypeScan
    public static var  Screen = EventTrackerSettings.sharedInstance.actionTypeScreen
    public static var  Search = EventTrackerSettings.sharedInstance.actionTypeSearch
    public static var  PredictiveSearch = EventTrackerSettings.sharedInstance.actionTypePredictiveSearch
    public static var  SearchHistory = EventTrackerSettings.sharedInstance.eventTypeSearchHistory
    public static var  SearchNoResults = EventTrackerSettings.sharedInstance.eventTypeSearchNoResults
    public static var  SelectSize = EventTrackerSettings.sharedInstance.actionTypeSelectSize
    public static var  ShareTapped = EventTrackerSettings.sharedInstance.actionTypeShareTapped
    public static var  Shop = EventTrackerSettings.sharedInstance.actionTypeShop
    public static var  ShopItButtonClicked = EventTrackerSettings.sharedInstance.actionTypeShopItButtonClicked
    public static var  SignUp = EventTrackerSettings.sharedInstance.actionTypeSignUp
    public static var  Size = EventTrackerSettings.sharedInstance.actionTypeSize
    public static var  SortBy = EventTrackerSettings.sharedInstance.actionTypeSortBy
    public static var  Store = EventTrackerSettings.sharedInstance.actionTypeStore
    public static var  StoreName = EventTrackerSettings.sharedInstance.actionTypeStoreName
    public static var  Successful = EventTrackerSettings.sharedInstance.actionTypeSuccessful
    public static var  SuccessfulScan = EventTrackerSettings.sharedInstance.actionTypeSuccessfulScan
    public static var  Title = EventTrackerSettings.sharedInstance.actionTypeTitle
    public static var  Unsuccessful = EventTrackerSettings.sharedInstance.actionTypeUnsuccessful
    public static var  UnsuccessfulScan = EventTrackerSettings.sharedInstance.actionTypeUnsuccessfulScan
    public static var  UpdateAccount = EventTrackerSettings.sharedInstance.actionTypeUpdateAccount
    public static var  UpdatedTotalCost = EventTrackerSettings.sharedInstance.actionTypeUpdatedTotalCost
    public static var  URL = EventTrackerSettings.sharedInstance.actionTypeURL
    public static var  VisualSearchSubmission = EventTrackerSettings.sharedInstance.actionTypeVisualSearchSubmission
    public static var  VisualSearchResults = EventTrackerSettings.sharedInstance.actionTypeVisualSearchResults
}

open class PoqTrackerLabelType {
    
    public static var  Featured = EventTrackerSettings.sharedInstance.labelTypeFeatured
    public static var  Female = EventTrackerSettings.sharedInstance.labelTypeFemale
    public static var  FromHomescreen = EventTrackerSettings.sharedInstance.labelTypeFromHomescreen
    public static var  FromNavigation = EventTrackerSettings.sharedInstance.labelTypeFromNavigation
    public static var  HisSizes = EventTrackerSettings.sharedInstance.labelTypeHisSizes
    public static var  HerSizes = EventTrackerSettings.sharedInstance.labelTypeHerSizes
    public static var  Kids = EventTrackerSettings.sharedInstance.labelTypeKids
    public static var  Loaded = EventTrackerSettings.sharedInstance.labelTypeLoaded
    public static var  Male = EventTrackerSettings.sharedInstance.labelTypeMale
    public static var  Newest = EventTrackerSettings.sharedInstance.labelTypeNewest
    public static var  NotCompleted = EventTrackerSettings.sharedInstance.labelTypeNotCompleted
    public static var  Price = EventTrackerSettings.sharedInstance.labelTypePrice
    public static var  Seller = EventTrackerSettings.sharedInstance.labelTypeSeller
    public static var  PurchasedAfterUsingScanner = EventTrackerSettings.sharedInstance.labelTypePurchasedAfterUsingScanner
    public static var  Rating = EventTrackerSettings.sharedInstance.labelTypeRating
    public static var  Received = EventTrackerSettings.sharedInstance.labelTypeReceived
    public static var  SignIn = EventTrackerSettings.sharedInstance.labelTypeSignIn
    public static var  SignUp = EventTrackerSettings.sharedInstance.labelTypeSignUp
    public static var  Share = EventTrackerSettings.sharedInstance.labelTypeShare
    public static var  Shop = EventTrackerSettings.sharedInstance.labelTypeShop
    public static var  SuccessfulScan = EventTrackerSettings.sharedInstance.labelTypeSuccessfulScan
    public static var  Unknown = EventTrackerSettings.sharedInstance.labelTypeUnknown
    public static var  UnsuccessfullScann = EventTrackerSettings.sharedInstance.labelTypeUnsuccessfullScann
    public static var  ValueSwipe = EventTrackerSettings.sharedInstance.labelTypeValueSwipe
    public static var  ValueTap = EventTrackerSettings.sharedInstance.labelTypeValueTap
}

open class PoqTrackerHelper {
    
    public static func trackApplePay(_ action: String, label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.ApplePay, action: action, label: label, extraParams: extraParams)
    }
    
    public static func trackCategoryLoaded(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.CategoryLoaded, action: PoqTrackerActionType.CategoryLoaded, label: label, extraParams: extraParams)
    }
    
    public static func trackHomeAction(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.HomeAction, action: PoqTrackerActionType.Title, label: label, extraParams: extraParams)
    }
    
    public static func trackLayerAction(_ action: String, label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.LayerActions, action: action, label: label, extraParams: extraParams)
    }
    
    public static func trackOrderListLoaded() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.OrderList, action: PoqTrackerActionType.Screen, label: PoqTrackerLabelType.Loaded, extraParams: nil)
    }
    
    public static func trackOrderSummaryLoaded(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.OrderSummary, action: PoqTrackerActionType.Loaded, label: label, extraParams: extraParams)
    }
    
    public static func trackPageScreen(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.PageScreen, action: PoqTrackerActionType.Title, label: label, extraParams: extraParams)
    }
    
    public static func trackPushNotification() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.PushNotification, action: PoqTrackerActionType.PushNotificationLandingPage, label: PoqTrackerLabelType.Received, extraParams: nil)
    }
    
    public static func trackRegisterRewardCard() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.MyReward, action: PoqTrackerActionType.RegisterRewardCard, label: User.getUserId(), extraParams: nil)
    }
    
    public static func trackReviewsLoad(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.ReviewsLoad, action: PoqTrackerActionType.ProductID, label: label, extraParams: extraParams)
    }
    
    public static func trackScan(_ action: String, label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.Scan, action: action, label: label, extraParams: extraParams)
    }
    
    public static func trackScannBarcode() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.RewardCard, action: PoqTrackerActionType.Scan, label: User.getUserId(), extraParams: nil)
    }
    
    public static func trackShopScreenLoaded() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.ShopScreenLoaded, action: PoqTrackerActionType.Shop, label: PoqTrackerLabelType.Shop, extraParams: nil)
    }
    
    public static func trackSwipeToHype(_ action: String, label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.SwipeToHype, action: action, label: label, extraParams: extraParams)
    }
    
    public static func trackTermsAndConditions(_ extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.TermsAndConditions, action: PoqTrackerActionType.OpenExternalLink, label: PoqTrackerLabelType.SignUp, extraParams: extraParams)
    }
}

// MARK: - Application change state tracker events
extension PoqTrackerHelper {
    
    public static func trackAppBackground() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.AppBackground, action: PoqTrackerActionType.AppDelegate, label: "Background", extraParams: ["Application": "applicationDidEnterBackground"])
    }
    
    public static func trackAppForeground() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.AppForeground, action: PoqTrackerActionType.AppDelegate, label: "Foreground", extraParams: ["Application": "applicationDidBecomeActive"])
    }
    
    public static func trackAppLaunch() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.AppLaunch, action: PoqTrackerActionType.AppDelegate, label: "Start", extraParams: ["Application": "didFinishLaunchingWithOptions"])
    }
}

// MARK: - Bag tracker events
extension PoqTrackerHelper {
    
    public static func trackAddToBag(_ extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.User, action: PoqTrackerActionType.AddToBag, label: User.getUserId(), extraParams: extraParams)
    }
    
    public static func trackBagMerged() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.BagMerged, action: PoqTrackerActionType.BagMerged, label: User.getUserId(), extraParams: nil)
    }
    
    public static func trackSelectSize(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.AddToBag, action: PoqTrackerActionType.SelectSize, label: label, extraParams: extraParams)
    }
    
    public static func trackBagScreenLoaded(_ event: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(event, action: PoqTrackerActionType.Screen, label: PoqTrackerLabelType.Loaded, extraParams: nil)
    }
    
    public static func trackBagScreenCheckout() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.BagScreen, action: PoqTrackerActionType.Checkout, label: "", extraParams: nil)
    }
    
    public static func trackRemoveFromBag(_ extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.RemoveFromBag, action: PoqTrackerActionType.RemoveFromBag, label: User.getUserId(), extraParams: extraParams)
    }
}

// MARK: - Card transfer tracker events
extension PoqTrackerHelper {
    
    public static func trackCardTransferCheckoutErrorRefresh(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.CheckoutError, action: PoqTrackerActionType.Refresh, label: label, extraParams: extraParams)
    }
    
    public static func trackCardTransferCheckoutError(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.CheckoutError, action: PoqTrackerActionType.Error, label: label, extraParams: extraParams)
    }
    
    public static func trackCardTransferCheckoutURLRequest(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.CheckoutURLRequest, action: PoqTrackerActionType.URL, label: label, extraParams: extraParams)
    }
    
    public static func trackLayerSales(_ action: String, label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.LayerSales, action: action, label: label, extraParams: extraParams)
    }
}

// MARK: - Checkout tracker events
extension PoqTrackerHelper {
    
    public static func trackNativeCheckout(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.NativeCheckout, action: PoqTrackerActionType.CreditCard, label: label, extraParams: extraParams)
    }
    
    public static func trackCheckoutOrderUpdateTotalCost<OrderItemType: OrderItem>(_ action: String, order: PoqOrder<OrderItemType>) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.CheckoutOrderUpdate, action: action, label: "\(String(describing: order.id))", extraParams: ["Total Cost": "\(String(describing: order.totalPrice))", "Shipping": "\(String(describing: order.deliveryCost))"])
    }
    
    public static func trackCheckoutPostOrder<CheckoutItemType: CheckoutItem>(_ checkoutItem: CheckoutItemType?, actionTitle: String = "Total Cost") {
        
        var params: [String: String] = [:]
        params.updateValue(String(describing: checkoutItem?.totalPrice), forKey: actionTitle)
        params.updateValue(String(describing: checkoutItem?.deliveryOption?.price), forKey: "Shipping")
        
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.CheckoutOrderUpdate, action: PoqTrackerActionType.UpdatedTotalCost, label: "\(String(describing: checkoutItem?.poqOrderId))", extraParams: params)
    }
    
    public static func trackCheckoutExit(_ extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.CheckoutExit, action: PoqTrackerActionType.Order, label: PoqTrackerLabelType.NotCompleted, extraParams: extraParams)
    }
    
    public static func trackSecureCheckout(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.SecureCheckout, action: PoqTrackerActionType.CheckoutPrice, label: label, extraParams: extraParams)
    }
}

// MARK: - My profile tracker events
extension PoqTrackerHelper {
    
    public static func trackUserLogin(extraParams: [String: String]? = nil, label: String? = nil) {
        // FIXME: Hacky trackprovider exception
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.User, action: PoqTrackerActionType.Login, label: label ?? "", extraParams: extraParams)
    }
    
    public static func trackUserLogout() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.User, action: PoqTrackerActionType.Logout, label: "", extraParams: nil)
    }
    
    public static func trackLoginRecognition(_ extraParams: [String: String]? = nil, label: String? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.Recognition, action: PoqTrackerActionType.Recognition, label: label ?? "", extraParams: extraParams)
    }
    
    public static func trackSignUp(_ extraParams: [String: String]? = nil, label: String? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.User, action: PoqTrackerActionType.SignUp, label: label ?? "", extraParams: extraParams)
    }
    
    public static func trackSignUpLinkClicked(_ extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.LinkClicked, action: PoqTrackerActionType.MyProfile, label: PoqTrackerLabelType.SignIn, extraParams: extraParams)
    }
    
    public static func trackRegisterUser(_ extraParams: [String: String]? = nil, label: String? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.Register, action: PoqTrackerActionType.Register, label: label ?? "", extraParams: extraParams)
    }
    
    public static func trackUpdateAccount(_ extraParams: [String: String]? = nil, label: String? = nil) {
        // FIXME: Hacky trackprovider exception
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.User, action: PoqTrackerActionType.UpdateAccount, label: label ?? "", extraParams: extraParams)
    }
}

// MARK: - LookBook tracker events
extension PoqTrackerHelper {
    
    public static func trackLookBookOpen(_ action: String, label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.LookBookOpen, action: action, label: label, extraParams: extraParams)
    }
    
    public static func trackLookBookShopIt(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.LookBookShopIt, action: PoqTrackerActionType.ShopItButtonClicked, label: label, extraParams: extraParams)
    }
}

// MARK: - Store tracker events
extension PoqTrackerHelper {
    
    public static func trackAddStoreToFavorite(_ label: String) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.StoreAddToFavorite, action: PoqTrackerActionType.FavouriteStore, label: label, extraParams: nil)
    }
    
    public static func trackStoreDetails(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.Store, action: PoqTrackerActionType.Title, label: label, extraParams: extraParams)
    }
    
    public static func trackStoreList(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.StoreList, action: PoqTrackerActionType.Count, label: label, extraParams: extraParams)
    }
    
    public static func trackStoreSelected(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.MyStore, action: PoqTrackerActionType.StoreName, label: label, extraParams: extraParams)
    }
}

// MARK: - Size change tracker events
extension PoqTrackerHelper {
    
    public static func trackMySize(_ action: String, label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.MySize, action: action, label: label, extraParams: extraParams)
    }
    
    public static func trackSetSizeForMale() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.SetSizeForMale, action: PoqTrackerActionType.MySizes, label: PoqTrackerLabelType.Male, extraParams: nil)
    }
    
    public static func trackSetSizeForWomen() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.SetSizeForWomen, action: PoqTrackerActionType.MySizes, label: PoqTrackerLabelType.Female, extraParams: nil)
    }
    
    public static func trackSetSizeForKids() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.SetSizeForKids, action: PoqTrackerActionType.MySizes, label: PoqTrackerLabelType.Kids, extraParams: nil)
    }
    
    public static func trackSetSizeForOpposite(_ action: String, label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.SetSizeForOppositeGender, action: action, label: label, extraParams: extraParams)
    }
}

// MARK: - Products tracker events
extension PoqTrackerHelper {
    
    public static func trackApplyFilters(action: String, _ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.ApplyFilters, action: action, label: label, extraParams: extraParams)
    }
    
    public static func trackApplySort(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.ApplySort, action: PoqTrackerActionType.SortBy, label: label, extraParams: extraParams)
    }
    
    public static func trackGroupProductListLoad(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.GroupProductListLoad, action: PoqTrackerActionType.Category, label: label, extraParams: extraParams)
    }
    
    public static func trackFullScreenImageViewLoad(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.FullScreenImageViewLoad, action: PoqTrackerActionType.ProductName, label: label, extraParams: extraParams)
    }
    
    public static func trackFullScreenImageViewSharing(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.FullScreenImageViewSharing, action: PoqTrackerActionType.ActivityType, label: label, extraParams: extraParams)
    }
    
    public static func trackProductAvailabilityLoad(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.ProductAvailabilityLoad, action: PoqTrackerActionType.Product, label: label, extraParams: extraParams)
    }
    
    public static func trackProductDetailLoad(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.ProductDetailLoad, action: PoqTrackerActionType.ProductName, label: label, extraParams: extraParams)
    }
    
    public static func trackProductListLoad(_ action: String, label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.ProductListLoad, action: action, label: label, extraParams: extraParams)
    }
    
    public static func trackProductSelectSize(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.SelectMySizes, action: PoqTrackerActionType.Size, label: label, extraParams: extraParams)
    }
    
    public static func trackProductRecentlyViewed() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.RecentlyViewed, action: PoqTrackerActionType.Screen, label: PoqTrackerLabelType.Loaded, extraParams: nil)
    }
    
    public static func trackSelectMyStore(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.SelectMyStore, action: PoqTrackerActionType.Store, label: label, extraParams: extraParams)
    }
    
    public static func trackOpenProductReviews(_ label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.OpenReview, action: PoqTrackerActionType.NumberOfReviews, label: label, extraParams: extraParams)
    }
    
    public static func trackSearchAction(_ action: String, label: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.Search, action: action, label: label, extraParams: extraParams)
    }
    
    public static func trackShareProduct() {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.Share, action: PoqTrackerActionType.ShareTapped, label: PoqTrackerLabelType.Share, extraParams: nil)
    }
    
    public static func trackVideoPlayed(for productTitle: String) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.Videos, action: PoqTrackerActionType.Play, label: productTitle, extraParams: nil)
    }
}

// MARK: - Wishlist tracker events
extension PoqTrackerHelper {
    
    public static func trackUserAddToWishList(_ extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.User, action: PoqTrackerActionType.AddToWishlist, label: User.getUserId(), extraParams: extraParams)
    }
    
    public static func trackAddToWishList(_ label: String, value: Double, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.AddToWishList, action: PoqTrackerActionType.ProductName, label: label, value: value, extraParams: extraParams)
    }
    
    public static func trackRemoveFromWishList(_ extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.User, action: PoqTrackerActionType.RemoveFromWishList, label: User.getUserId(), extraParams: extraParams)
    }
    
    public static func trackWishScreenLoaded(_ extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.WishScreen, action: PoqTrackerActionType.Screen, label: PoqTrackerLabelType.Loaded, extraParams: nil)
    }
}

// MARK: - Peek and Pop tracker events
extension PoqTrackerHelper {
    
    public static func trackOpenPeek(_ titleLabel: String, skuLabel: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.PeekOpen, action: PoqTrackerActionType.PeekProductTitle, label: titleLabel, extraParams: extraParams)
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.PeekOpen, action: PoqTrackerActionType.PeekProductSKU, label: skuLabel, extraParams: extraParams)
    }
    public static func trackPeekLoadPDP(_ titleLabel: String, skuLabel: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.PeekAction, action: PoqTrackerActionType.PeekViewDetailsTitle, label: titleLabel, extraParams: extraParams)
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.PeekAction, action: PoqTrackerActionType.PeekViewDetailsSKU, label: skuLabel, extraParams: extraParams)
    }
    public static func trackPeekAddToWishlist(_ titleLabel: String, skuLabel: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.PeekAction, action: PoqTrackerActionType.PeekAddToWishlistTitle, label: titleLabel, extraParams: extraParams)
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.PeekAction, action: PoqTrackerActionType.PeekAddToWishlistSKU, label: skuLabel, extraParams: extraParams)
    }
    public static func trackPeekShare(_ titleLabel: String, skuLabel: String, extraParams: [String: String]? = nil) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.PeekAction, action: PoqTrackerActionType.PeekShareTitle, label: titleLabel, extraParams: extraParams)
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.PeekAction, action: PoqTrackerActionType.PeekShareSKU, label: skuLabel, extraParams: extraParams)
    }
}

extension PoqTrackerHelper {
    
    public static func trackOpenAppStories(storyTitle: String) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.AppStories, action: PoqTrackerActionType.AppStoriesOpen, label: storyTitle, extraParams: nil)
    }
    
    public static func trackAutoplayAppStory(storyTitle: String) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.AppStories, action: PoqTrackerActionType.AppStoriesAutoOpen, label: storyTitle, extraParams: nil)
    }
    
    public static func trackAppStoryPLPSwipe(storyAndCardTitle: String) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.AppStories, action: PoqTrackerActionType.AppStoriesPLPSwipe, label: storyAndCardTitle, extraParams: nil)
    }
    
    public static func trackAppStoryPDPSwipe(storyAndCardTitle: String) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.AppStories, action: PoqTrackerActionType.AppStoriesPDPSwipe, label: storyAndCardTitle, extraParams: nil)
    }
    
    public static func trackAppStoryVideoSwipe(storyAndCardTitle: String) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.AppStories, action: PoqTrackerActionType.AppStoriesVideoSwipe, label: storyAndCardTitle, extraParams: nil)
    }
    
    public static func trackAppStoryWebViewSwipe(storyAndCardTitle: String) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.AppStories, action: PoqTrackerActionType.AppStoriesWebViewSwipe, label: storyAndCardTitle, extraParams: nil)
    }
    
    public static func trackAppStoryDismiss(storyAndCardTitle: String) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.AppStories, action: PoqTrackerActionType.AppStoriesDismiss, label: storyAndCardTitle, extraParams: nil)
    }
}

// MARK: - Visual Search

extension PoqTrackerHelper {
    
    public static func trackVisualSearchImageSubmission(forSource: String) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.VisualSearch, action: PoqTrackerActionType.VisualSearchSubmission, label: forSource, extraParams: nil)
    }
    
    public static func trackVisualSearchResults(forNumberOfCategories: String) {
        PoqTracker.sharedInstance.logAnalyticsEvent(PoqTrackerEventType.VisualSearch, action: PoqTrackerActionType.VisualSearchResults, label: forNumberOfCategories, extraParams: nil)
    }
}
