//
//  PoqTrackerConstants.swift
//  PoqAnalytics
//
//  Created by Rachel McGreevy on 1/15/18.
//

import Foundation

public struct TrackingEvents {

    /// MARK: - Bag Trackable Events
    public struct Bag {
        public static let removeFromBag = "removeFromBag"
        public static let clearBag = "clearBag"
        public static let bagUpdate = "bagUpdate"
        public static let removeFromWishlist = "removeFromWishlist"
        public static let clearWishlist = "clearWishlist"
        public static let applyVoucher = "applyVoucher"
        public static let applyStudentDiscount = "applyStudentDiscount"
    }

    /// MARK: - Loyalty Trackable Events
    struct Loyalty {
        static let voucherAction = "voucherAction"
    }
    
    /// MARK: - Content Trackable Events
    struct Content {
        static let onboarding = "onboarding"
        static let appOpen = "appOpen"
        static let bannerTap = "bannerTap"
        static let lookbookTap = "lookbookTap"
        static let storeFinder = "storeFinder"
        static let appStories = "appStories"
    }

    /// MARK: - Catalogue Trackable Events
    struct Catalogue {
        static let viewProduct = "viewPdp"
        static let viewProductList = "viewPlp"
        static let viewSearchResults = "viewSearchResults"
        static let addToBag = "addToBag"
        static let addToWishlist = "addToWishlist"
        static let share = "share"
        static let barcodeScan = "barcodeScan"
        static let sortProducts = "sortProducts"
        static let filterProducts = "filterProducts"
        static let peekAndPop = "peekAndPop"
        static let fullScreenImageView = "fullScreenImageView"
        static let readReviews = "readReviews"
        static let videoPlay = "videoPlay"
        static let visualSearchSubmit = "visualSearchSubmit"
        static let visualSearchResults = "visualSearchResults"
    }

    /// MARK: - Checkout Trackable Events
    struct Checkout {
        static let beginCheckout = "beginCheckout"
        static let checkoutUrlChange = "checkoutUrlChange"
        static let checkoutAddressChange = "checkoutAddressChange"
        static let checkoutPaymentChange = "checkoutPaymentChange"
        static let orderFailed = "orderFailed"
        static let orderSuccessful = "order"
    }

    /// MARK: - My Account Trackable Events
    struct MyAccount {        
        static let addressBook = "addressBook"
        static let signUp = "signUp"
        static let login = "login"
        static let logout = "logout"
        static let editDetails = "editDetails"
        static let switchCountry = "switchCountry"
    }
}

public struct TrackingInfo {
    public static let productId = "productId"
    public static let productTitle = "productTitle"
    public static let total = "total"
    public static let voucher = "voucher"
    public static let action = "action"
    public static let userId = "userId"
    public static let voucherId = "voucherId"
    public static let method = "method"
    public static let campaign = "campaign"
    public static let title = "title"
    public static let type = "type"
    public static let screenNumber = "screenNumber"
    public static let storeName = "storeName"
    public static let cardTitle = "cardTitle"
    public static let source = "source"
    public static let categoryId = "categoryId"
    public static let categoryTitle = "categoryTitle"
    public static let parentCategoryId = "parentCategoryId"
    public static let keyword = "query"
    public static let result = "result"
    public static let quantity = "quantity"
    public static let price = "price"
    public static let currency = "currency"
    public static let ean = "EAN"
    public static let colors = "colours"
    public static let categories = "categories"
    public static let sizes = "sizes"
    public static let brands = "brands"
    public static let styles = "styles"
    public static let minPrice = "minPrice"
    public static let maxPrice = "maxPrice"
    public static let reviewCount = "numberOfReviews"
    public static let value = "value"
    public static let url = "url"
    public static let error = "error"
    public static let tax = "tax"
    public static let delivery = "delivery"
    public static let transactionId = "transactionId"
    public static let rrp = "rrp"
    public static let countryCode = "countryCode"
    public static let status = "status"
    public static let marketingOptIn = "marketingOptIn"
    public static let dataOptIn = "dataOptIn"
    public static let crop = "crop"
}

public enum LoyaltyVoucherAction: String {
    case details = "Details"
    case applyToBag = "ApplyToBag"
}

public enum LookbookProductSource: String {
    case shopTheLook = "shopTheLook"
    case hotspot = "hotspot"
    case hotspotDetail = "hotSpotDetail"
}

public enum StoreFinderAction: String {
    case details = "Details"
    case phoneCall = "PhoneCall"
    case directions = "Directions"
}

public enum AppStoriesAction: String {
    case dismiss = "Dismiss"
    case pdpSwipe = "PDPSwipe"
    case plpSwipe = "PLPSwipe"
    case webviewSwipe = "webviewSwipe"
    case videoSwipe = "videoSwipe"
}

public enum ViewProductSource: String {
    case appStories = "AppStoriesPDP"
    case bag = "Bag"
    case modalBag = "ModalBag"
    case brandedPLP = "BrandedPLP"
    case lookbookHotspot = "lookbookHotspot"
    case lookbookHotspotDetail = "LookbookHotspotDetail"
    case lookbookShopTheLook = "LookbookShopTheLook"
    case productsCarousel = "ProductsCarousel"
    case groupedPLP = "GroupedPLP"
    case plp = "PLP"
    case peekViewDetails = "PeekViewDetails"
    case peekForceTouch = "PeekForceTouch"
    case recentlyViewedPLP = "RecentlyViewedPLP"
    case visualSearch = "visualSearch"
    case barcodeScanner = "BarcodeScanner"
    case classicSearch = "ClassicSearch"
    case swipe2Hype = "Swipe2Hype"
    case wishlistGrid = "WishlistGrid"
    case wishlist = "Wishlist"
}

public enum ActionResultType: String {
    case successful = "successful"
    case unsuccessful = "unsuccessful"
}

public enum PeekAndPopAction: String {
    case peek = "Peek"
    case details = "Details"
}

public enum SearchResultType: String {
    case history = "history"
    case predictive = "predictiveSearch"
    case search = "search"
}

public enum CheckoutMethod: String {
    case card = "card"
    case applePay = "applePay"
    case web = "web"
}

public enum CheckoutPaymentMethod: String {
    case paypal = "paypal"
    case card = "card"
    case klarna = "klarna"
}

public enum AddressBookAction: String {
    case change = "Change"
    case add = "Add"
    case remove = "Remove"
}

public enum OnboardingAction: String {
    case begin = "begin"
    case complete = "complete"
}

public enum VisualSearchResult: String {
    case successful
    case unsuccessful
}

public enum VisualSearchImageSource: String {
    case camera
    case photos
}
