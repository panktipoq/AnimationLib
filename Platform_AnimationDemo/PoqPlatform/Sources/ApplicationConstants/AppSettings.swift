//
//  GlobalSettings.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/20/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqModuling
import PoqNetworking
import PoqUtilities
import Stripe
import UIKit

public enum WishListViewType: Double {

    case list = 1
    case grid = 2
}

public enum PushRegistrationType: Double {

    case afterLikeOrAddToBag = 1
    case onHomeScreenStraight = 2
}

public enum PoqImageContentMode: String {
    case ScaleAspectFit = "ScaleAspectFit"
    case ScaleAspectFill = "ScaleAspectFill"
}

public enum TabbarItem: String {

    case Home = "home"
    case Shop = "shop"
    case Stores = "stores"
    case Bag = "bag"
    case Wishlist = "wishlist"
    case More = "more"
    case MyProfile = "my_profile"
}

public enum BagEditButtonDirection: String {

    case Left = "left"
    case Right = "right"
}

public enum CheckoutComplete: Double {

    case byTitle = 1
    case byMultipleURLs = 2
}

public enum BagType: Double {

    case transfer = 1
    case native = 2
}

public enum SubmitButtonType: Double {

    case white = 1
    case black = 2
}

public enum ShopPageType: Double {
    case accordionMenu = 1
    case native = 2
}

public enum PasswordValidationType: Double {

    case `default` = 1 // Min 8 characters and at least 1 number
    case light = 2 // Min 6 characters
}

public enum CellSeparatorType: Double {

    case none = 0 // Cell don't have separator
    case solid = 1 // Use really solid line
    case paintcodeHorizontal = 2 // Paintcode style, for HoF it is dashed, for Missguided solid line too
}

public enum OrderDetailViewType: Double {
    case platform = 1
    case hoF = 2
    case missguided = 3
}

public enum PDPProductColor: Double {
    case image = 0
    case title = 1
}

public enum ProductDetailViewType: Double {

    case classic = 1
    case modular = 2
}

/// We have 2 search: 
///   1. Oldone/classic - we search when user press "Search" and directly opem PLP with keyword
///   2. Predictive: while user typing we show suggestions
public enum SearchType: Double {

    case classic = 1
    case predictive = 2
}

public enum ProductSizeSelectorType: Double {
    case classic = 1
    case sheet = 2
}

public final class AppSettings: NSObject, AppConfiguration {

    public static var sharedInstance = AppSettings()

    class func resetSharedInstance() {
        sharedInstance = AppSettings()
    }

    public let configurationType: PoqSettingsType = .config

    // Mark: - Navigation bar
    @objc public var navigationBarHeight: Double = 40
    @objc public var navigationBarWidth: Double = 150

    @objc public var statusBarStyle: Double = PoqStatusBarStyle.dark.rawValue

    // MARK: - Navigation Menu
    @objc public var showNavMenu: Bool = false
    @objc public var sideMenuPosition: String = "left"

    // MARK: - BADGE IN THE BAG
    @objc public var bagViewInNavigation: Bool = false
    //used for plist key
    @objc public var customBadgeName: String = "MissguidedBadge"

    // MARK: - TABS
    @objc public var showMiddleButton: Bool = false

    //icons
    @objc public var tabIcon1: String = "icn-home-off"
    @objc public var tabIcon2: String = "icn-shop-off"
    @objc public var tabIcon3: String = "icn-bag-off"
    @objc public var tabIcon4: String = "icn-wish-off"
    @objc public var tabIcon5: String = "icn-more-off"

    @objc public var selectedTabIcon1: String = "icn-home-on"
    @objc public var selectedTabIcon2: String = "icn-shop-on"
    @objc public var selectedTabIcon3: String = "icn-bag-on"
    @objc public var selectedTabIcon4: String = "icn-wish-on"
    @objc public var selectedTabIcon5: String = "icn-more-on"

    // tab functionalities
    @objc public var tab1: String = "home"
    @objc public var tab2: String = "shop"//"stores"
    @objc public var tab3: String = "bag"
    @objc public var tab4: String = "wishlist"
    @objc public var tab5: String = "more"//"my_profile"

    //tab bar title
    @objc public var tabTitle1 = "HOME".localizedPoqString
    @objc public var tabTitle2 = "SHOP".localizedPoqString //("STORES", comment: "stores")
    @objc public var tabTitle3 = "BAG".localizedPoqString
    @objc public var tabTitle4 = "WISHLIST".localizedPoqString
    @objc public var tabTitle5 = "MORE".localizedPoqString //("YOU", comment: "You")

    @objc public var tabBarTranslucent: Bool = false

    @objc public var homeTabIndex: Double = 0
    @objc public var storeTabIndex: Double = 1
    @objc public var shoppingBagTabIndex: Double = 2
    @objc public var wishListTabIndex: Double = 3
    @objc public var myProfileTabIndex: Double = 4


    @objc public var storeISOCountryCode = "GB"

    @objc public var isSubCategoriesModalPresent: Bool = false

    /// All valid types listed in NavigationBarHelper. This is raw values for enum
    @objc public var navigationRightButtonType: String = "Default"
    @objc public var navigationLeftButtonType: String = "Default"

    // Used only if navigationLeftButtonType/navigationRightButtonType is Bordered
    @objc public var navigationBorderedButtonBorderWidth: Double = 1.0
    @objc public var navigationBorderedButtonCornerRadius: Double = 5.0

    // MARK: PUSH NOTIFICATION REGISTRATION TYPE

    @objc public var pushRegistrationType: Double = PushRegistrationType.afterLikeOrAddToBag.rawValue

    // MARK: SEARCH
    @objc public var searchType: Double = 1.0
    @objc public var showNoSearchResultsIcon: Bool = true
    
    // MARK: - VISUAL SEARCH
    /// This var will not be added to MB, needs to be configured at build time
    @objc public var enableVisualSearch: Bool = false

    // MARK: HOME SEARCH BAR
    @objc public var enableSearchBarOnHome: Bool = false
    @objc public var showFilterTypeCategory: Bool = false
    @objc public var enableSearchBarOnHomeWhiteBackground: Bool = false

    // MARK: HOME SEARCH BAR

    @objc public var displayFirstTimeBanner: Bool = false
    @objc public var useCustomisedFirstTimeBanner: Bool = false
    @objc public var enableScanOnSearchBar: Bool = false

    // MARK: FOR HOF only
    @objc public var retainSearchBarWidthForiPad: Bool = false
    @objc public var homeSearchBarForiPadPadding: Double = 184.0

    // MARK: SHOP SEARCH BAR
    @objc public var enableSearchBarOnShop: Bool = true
    @objc public var enableSearchBarOnShopWhiteBackground: Bool = false
    @objc public var showSearchResultsLabelWithUppercaseLetters: Bool = false
    @objc public var enableSearchLetterSpacing: Bool = false

    // MARK: SPLASH IMAGE
    @objc public var splashImageUrl_iPhone: String = "splashImageUrl_iPhone"
    @objc public var splashImageUrl_iPhone4: String = "splashImageUrl_iPhone4"
    @objc public var splashImageUrl_iPad: String = "splashImageUrl_iPad"

    // MARK: USE MATERIAL SPINNER
    @objc public var loadingIndicatorStyle: String = "RingSpinner"
    @objc public var loadingIndicatorDimension: Double = 40

    // Disable/enable category images in shop tab
    @objc public var isCategoryImageEnabled: Bool = true
    @objc public var isDisclosureIndicatorEnabledOnShop: Bool = true

    // Show/hide header image on Category List
    @objc public var isCategoryHeaderVisible: Bool = false

    // MARK: - SHOP
    // Disable/enable top banner in shop tab
    @objc public var isShopTabBannerEnabled: Bool = true
    @objc public var shopTableViewCellHeight: Double = 75
    @objc public var shopTableViewCellSubLevelsHeight: Double = 44
    @objc public var shopCategoryNameCase: String = "Default"
    @objc public var isShopTableEnableSeparator: Bool = true
    @objc public var subcategoryIndent: Double = 10
    @objc public var brandedTextCategoryCellHeight: Double = 60.0
    @objc public var brandedPlpCellImageContainerRatio: Double = 1.0
    @objc public var brandedPlpCellInsetTop: Double = 10.0
    @objc public var brandedPlpCellInsetBottom: Double = 10.0
    @objc public var brandedPlpCellInsetLeft: Double = 10.0
    @objc public var brandedPlpCellInsetRight: Double = 10.0
    // MARK: WISHLIST
    // Wishlist view type 1: ListView, 2:GridView
    @objc public var wishListViewType: Double = WishListViewType.grid.rawValue
    @objc public var wishListCellLeftPadding: Double = 0
    @objc public var wishListCellRightPadding: Double = 0
    @objc public var wishListCellTopPadding: Double = 10
    @objc public var wishListCellBottomPadding: Double = 5
    @objc public var enableAddToBagOnWishlist: Bool = false
    @objc public var enableChooseColorWheAddToBagOnWishList: Bool = false
    @objc public var wishListPageSize: Double = 300

    // MARK: BAG
    @objc public var isBagSwipeToDeleteEnabled: Bool = true

    // Should we check PoqProduct isInStoke before we add product to bag
    @objc public var shouldCheckForOutOfStockeProducts: Bool = false
    // MARK: - CONTINUE SHOPPING DEEPLINK URL
    @objc public var continueShoppingDeeplinkURL: String = "shop"

    // Rating on PDP

    @objc public var pdpProductHasRatingEnabled: Bool = false

    // Size guide link on PDP
    @objc public var isSizeGuideOnPDPEnabled: Bool = true
    @objc public var sizeGuideOnPDPPageId: String = ""
    @objc public var isSizeInformationRowShown: Bool = true

    // Care Details link on PDP
    @objc public var isCareDetailsPageOnPDPEnabled: Bool = false
    @objc public var careDetailsOnPDPPageId: String = ""

    // Add To Bag Button on PDP
    @objc public var isAddToBagBlockOnClassicPdpEnabled: Bool = false

    // Product Details on PDP
    @objc public var isProductRewardDetailsOnClassicPdpEnabled: Bool = false
    @objc public var isProductsCarouselOnPdpEnabled: Bool = false

    //Search
    @objc public var isProductsCarouselOnSearchEnabled: Bool = false

    // Delivery & Returns
    @objc public var isDeliveryPageOnPDPEnabled: Bool = false
    @objc public var deliveryPageOnPDPPageId: String = ""
    @objc public var pdpDeliveryPolicyLinkUrl: String = ""
    @objc public var pdpReturnsPolicyLinkUrl: String = ""

    @objc public var isEmptyCellOnTheBottomOfPDPEnabled: Bool = false

    //Caroussel
    @objc public var maxProductsOnProductsCarousel: Double = 10
    @objc public var productsPerScreenOnProductsCarousel: Double = 2.5
    @objc public var productsCarouselImageRatio: Double = 0.75 // w/h
    @objc public var productsCarouselTextAreaHeight: Double = 90.0

    //html in webview
    @objc public var wrappedHTMLStringFormat = "<html><head><link rel='stylesheet' type='text/css' href='%@' /></head><body class='appcontent'>%@</body></html>"

    @objc public var isAuthenticationRequired: Bool = true
    @objc public var userName: String = "storefront"
    @objc public var passWord: String = "B-kerStr--t"
    @objc public var showCartURL: String = ""

    /// We create second version of cart transfer. V1 is still default
    @objc public var cartTransferVersion: String = "V1"

    // PoqWebView

    @objc public var shouldResizeWebContent: Bool = false

    // MARK: URL BASED CHECKOUT TRACKING
    @objc public var isCheckoutURLBased: Bool = false
    @objc public var isCheckoutTitleBased: Bool = false
    @objc public var checkoutCompleteType: Double = CheckoutComplete.byMultipleURLs.rawValue
    @objc public var checkoutCompleteURL: String = ""
    @objc public var checkoutCompleteTitle: String = ""
    @objc public var checkoutCompleteURLSeperator: String = "|"
    @objc public var checkoutCompleteOrderNumberKey: String = ""
    @objc public var checkoutCompleteOrderNumberURL: String = ""
    @objc public var checkoutUserEmailParserEnabled: Bool = true
    @objc public var checkoutContinueShoppingURL: String = "Cart-ContinueShopping"
    @objc public var checkoutContinueShoppingDeepLink: String = ""
    @objc public var forgotPasswordURL: String = ""
    @objc public var privacyPolicyURL: String = ""

    // this merchantId will be used not only for shopify, but abd for all apple pay systems
    @objc public var applePayMerchantId: String = ""
    @objc public var displayMerchantName: String = ""
    /// comma separated list without spaces. Valid values can be found in PoqCardNetwork
    @objc public var applePayAvailablePaymentNetworks = "visa,amex,mastercard"

    // stripe SDK
    @objc public var stripePublishableKey: String = ""
    @objc public var prePopulateUserEmailJQuery: String {
        get {
            //dwfrm_requestpassword_email
            guard let userEmailAddress = LoginHelper.getEmail() else {
                return ""
            }
            return String(format: "if (jQuery(\"#emailAddress\").val()==\"\") {jQuery(\"#emailAddress\").val(\"%@\")} if (jQuery(\"#dwfrm_login_username\").val()==\"\") {jQuery(\"#dwfrm_login_username\").val(\"%@\")} if (jQuery(\".poqusername\").val()==\"\") {jQuery(\".poqusername\").val(\"%@\")} if (jQuery(\"#dwfrm_requestpassword_email\").val()==\"\") {jQuery(\"#dwfrm_requestpassword_email\").val(\"%@\")}", userEmailAddress, userEmailAddress, userEmailAddress, userEmailAddress)
        }
    }

    @objc public var clientDomain: String = "" // Used for NSURLConnection to skip ssl errors
    @objc public var clientCookieDomain: String = "" // Used for auto-login

    /// list of cookies formated as "<key1>=<value1>;<key2>=<value2>"
    @objc public var cleintCookies: String = ""

    @objc public var myProfileEditMyAddressLink: String = ""
    @objc public var acceptedCheckoutDomains: String = ""

    @objc public var shouldAddCheckoutViewPort: Bool = true
    @objc public var mobileViewPortCode: String = "if (document.querySelector('meta[name=viewport]')) {" +
        "document.querySelector('meta[name=viewport]').setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');" +
        "} else {;" +
        "var viewPortTag=document.createElement('meta');" +
        "viewPortTag.id='viewport';" +
        "viewPortTag.name = 'viewport';" +
        "viewPortTag.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "document.getElementsByTagName('head')[0].appendChild(viewPortTag);" +
    "}"

    //NOTE: NEED TO BEREMOVED
    @objc public var checkoutCSSURL: String = ""
    @objc public var checkoutJSURL: String = ""

    //Move from downloading asset into splash
    @objc public var checkoutCSS: String = ""
    @objc public var checkoutJavaScript: String = ""
    @objc public var checkoutDownLoadAssetsFirst: Bool = false

    @objc public var mobileCSS: String = ""
    @objc public var checkoutCookiesToSkipDeleting: String = ""

    @objc public var productOthersDetailViewWrapperHtml: String = "<html><head><style type='text/css'>%@</style></head><body class='%@'>%@</body></html>"

    @objc public var productDetailDescriptionPageStripCSS: String = ""
    @objc public var contentPageStripJS: String = ""
    @objc public var pdpSizeGuideCssSelector: String = ""
    @objc public var pdpDescriptionCssSelector: String = ""

    // checkoutCSSURL is downloaded once via CartViewModel and injected as inline
    @objc public var mobileInlineCSSJS: String = "var cssInlineTag=document.createElement('style');" +
        "cssInlineTag.type = 'text/css';" +
        "cssInlineTag.innerHTML = '%@';" +
    "document.getElementsByTagName('head')[0].appendChild(cssInlineTag);"

    // checkoutJSURL is downloaded once via CartViewModel and injected as inline
    @objc public var mobileCheckoutJS = "var jsTag=document.createElement('script');" +
        "jsTag.id ='poqmobilejs';" +
        "jsTag.name = 'poqmobilejs';" +
        "jsTag.type = 'text/javascript';" +
        "jsTag.innerHTML = '%@';" +
    "document.getElementsByTagName('head')[0].appendChild(jsTag);"

    @objc public var orderSummaryParser = "function getTotalCost(){var delivery='0';var total='0';var priceLabels=document.querySelectorAll('tbody .price');if(priceLabels){if(priceLabels.length>1){delivery=priceLabels[1].innerText;}}var totalLabel=document.querySelector('tfoot .price');if(totalLabel){total=totalLabel.innerText;}var order={delivery:delivery,total:total};return JSON.stringify(order);}getTotalCost();"

    @objc public var orderSummaryURL = ""
    @objc public var orderItemsSummaryParser = ""

    @objc public var orderNumberParser = "document.querySelector('.js-ohordnum').innerText;"

    // MARK: - PRICE
    @objc public var priceDecimalFormat: String = "%.2f"
    @objc public var priceDecimalFormatWithCurrency: String = "%@%.2f"
    // This format will be used for the normal price when the product has normal price and does not have special price
    @objc public var priceFormat: String = " Was %@"
    // This format will be used for the normal price when the product has normal price and special price
    @objc public var priceWithSpecialPriceFormat: String = " Orig. %@ %@"
    // This format will be used for the normal price range when the product has normal price and special price
    @objc public var priceRangeFormat: String = "Orig. %@"
    @objc public var isClearancePriceEnabled: Bool = false

    // Page specific

    // This format will be used for the normal price range when the product has normal price and does not have special price
    @objc public var plpPriceFormat: String = "%@"
    @objc public var pdpPriceFormat: String = "%@"
    @objc public var wishlistPriceFormat: String = "%@"
    @objc public var bagPriceFormat: String = "%@"
    @objc public var tinderPriceFormat: String = "%@"
    @objc public var groupPLPPriceFormat: String = "From %@"

    // This format will be used for the special price
    @objc public var specialPriceFormat: String = "Now %@"
    @objc public var clearanceSpecialPriceFormat: String = "Clearance %@"
    // This format will be used for the special price range
    @objc public var specialPriceRangeFormat: String = "Now %@"
    @objc public var clearanceSpecialPriceRangeFormat: String = "Clearance %@"
    @objc public var isNowPriceLeftWasPriceRight: Bool = true

    // MARK: - PLP

    @objc public var customisedRangeSlider: Bool = false
    @objc public var brandedProductCellBottomContentHeight: Double = 130
    @objc public var brandedProductCellImageHeight: Double = 200
    @objc public var plpColumns_iPhone: Double = 2
    @objc public var plpColumns_iPad: Double = 3
    @objc public var plpMoreColoursIconImageName: String = "colors-icon"

    @objc public var plpFeaturedSortingOptionAvailable: Bool = true
    @objc public var plpNewestSortingOptionAvailable: Bool = true
    @objc public var plpRatingSortingOptionAvailable: Bool = true
    @objc public var plpPriceSortingOptionAvailable: Bool = true
    @objc public var plpSellerSortingOptionAvailable: Bool = false

    @objc public var plpFeaturedSortingOptionPosition: Double = 0
    @objc public var plpNewestSortingOptionPosition: Double = 1
    @objc public var plpRatingSortingOptionPosition: Double = 2
    @objc public var plpPriceSortingOptionPosition: Double = 3
    @objc public var plpSellerSortingOptionPosition: Double = 4

    @objc public var plpProductCellBottomContentHeight: Double = 80
    @objc public var plpProductCellImageContainerRatio: Double = 1.0

    @objc public var plpCollectionViewRowSpacing: Double = 0.0

    // MARK: PROMOTION BANNER PLP

    @objc public var promotionBannerPlace: Double = 3.0
    @objc public var promotionBannerTitleTopPadding: Double = 5.0
    @objc public var promotionBannerDescriptionBottomPadding: Double = 5.0
    @objc public var promotionBannerType: Double = 0.0
    // MARK: - gPLP

    @objc public var isGroupPLPWithPriceFormatFrom: Bool = false
    @objc public var showFixedParentProductTitleOnGPLP: Bool = false

    // MARK: - PLP Swatch Buttons
    @objc public var isPlpColorSwatchesEnabled: Bool = false
    @objc public var plpMaxSwatchesToDisplay: Double = 4.0

    @objc public var strikethroughForNormalPrice: Bool = false
    @objc public var hidePDPLikeButton: Bool = false
    @objc public var hidePLPLikeButton: Bool = false
    @objc public var plpPriceTextAligment: String = "Left"
    @objc public var plpTitleTextAligment: String = "Left"
    @objc public var plpSortFiltersOnToolBarEnable: Bool = false

    @objc public var plpCategoryNameLowercase: Bool = true
    @objc public var plpSortingOptionsHeight: Double = 50

    @objc public var bagSecureCheckoutButtonLabelFontSize: Double = 21.0
    @objc public var brandedPLPImageHeight: Double = 200
    @objc public var brandedPLPColumns: Double = 1
    @objc public var brandedPLPBottomHeight: Double = 150

    // MARK: - Grouped PLP
    @objc public var plpHasGroupedProductImage: Bool = false
    @objc public var plpGroupedProductCollectionViewRowSpacing: Double = 0
    @objc public var isGroupedPLPShowingHeader: Bool = true

    // MARK: - PLP Filters
    @objc public var rangeSliderCustomisedHeight: Double = 40.0
    @objc public var rangeSliderTrackCustomisedHeight: Double = 10.0
    @objc public var filterPageShowCloseButton: Bool = true

    @objc public var isPLPFiltersButtonHidden: Bool = false
    @objc public var isPLPFiltersToolbarEnableSeparator: Bool = false
    @objc public var shouldShowFilterPriceSlider: Bool = true

    /// comma separated filter types. If some types doesn't listed - we won't show them.
    /// Filter values should be taken from FilterType enum
    @objc public var desiredFiltersOrder: String = "brand,category,color,size,style"

    // MARK: - Peek & Pop
    @objc public var peekShowsProductPrice: Bool = false
    @objc public var isVideoEnabledOnPeek: Bool = false

    // MARK: - Page List
    @objc public var pagelistSearchBarHidden: Bool = true

    // MARK: - PDP
    @objc public var pdpViewType: Double = ProductDetailViewType.classic.rawValue
    @objc public var pdpNavigationBarHidden: Bool = false
    @objc public var pdpHasShareButton: Bool = false
    @objc public var isVideoButtonEnabledOnPdp: Bool = false
    @objc public var enablePageControl: Bool = true

    @objc public var pdpBottomConstraint: Double = 90
    @objc public var pdpAddToBagLabelFontSize: Double = 16.0
    @objc public var pdpPriceFontSize: Double = 21
    @objc public var pdpFullScreenCloseButtonHasBackground: Bool = true
    @objc public var pdpSizeSelectorBehindViewAlpha: CGFloat = 0.5

    @objc public var pdpSizeSelectorType: Double = ProductSizeSelectorType.classic.rawValue
    @objc public var isLowStockEnabledOnSizeSelector: Bool = true
    @objc public var lowStockProductLevel: Double = 8
    
    @objc public var pdpProductImageContentMode: String = PoqImageContentMode.ScaleAspectFit.rawValue
    @objc public var pdpLikePositionBasedOnImageFrame: Bool = false
    @objc public var isShareButtonAddedAsLastBlockOnPdp: Bool = false

    /// pdpProductColor will be casted into PDPProductColor enum.
    @objc public var pdpProductColor: Double = 0.00

    @objc public var pdpProductColorsViewHeight: CGFloat = 42.0

    // PDP Product Color values for Title type
    @objc public var pdpProductColorTitleCornerRadius: CGFloat = 4.0
    @objc public var pdpProductColorTitleBorderWidth: CGFloat = 1.0
    @objc public var pdpProductColorTitleHorizontalPadding: CGFloat = 10.0
    @objc public var pdpProductColorTitlePaddingBetween: CGFloat = 5.0
    @objc public var pdpProductColorTitleMinimumHorizontalSize: CGFloat = 75.0
    @objc public var pdpProductColorTitleVerticalSize: CGFloat = 25.0
    // PDP Product Color values for Imege type
    @objc public var pdpProductColorImageSize: CGFloat = 32.0
    @objc public var pdpProductColorImageCornerRadius: CGFloat = 16.0
    @objc public var pdpProductColorImageBorderWidth: CGFloat = 0.5
    @objc public var pdpProductColorImagePaddingBetween: CGFloat = 5.0

    @objc public var isPdpProductColorSwatchesCentered: Bool = true
    @objc public var pdpProductColorSwatchesShowsSelectedColorName: Bool = false

    @objc public var productDescriptionCellHeight: CGFloat = 120.0
    @objc public var modularPdpDescriptionBlockLinesLimit: Double = 4.0

    // PDP Classic Info Cell

    @objc public var isClassicPDPInfoCellFixedHeight: Bool = false
    @objc public var classicPDPInfoCellFixedHeight: CGFloat = 390.0

    // MARK: - Tinder
    @objc public var tinderPriceFontSize: Double = 16
    @objc public var tinderNumberOfProductsToFetch: Double = 50
    @objc public var tinderProductCategoryID: String = "88627"
    @objc public var tinderFirstTimeLoadSkipButtonFontSize: Double = 12

    // MARK: - WISHLIST
    @objc public var wishlistUsesPaginationApi: Bool = false
    @objc public var wishListAddToBagLabelFontSize: Double = 12.0
    @objc public var isWishlistToolbarEnableSeparator: Bool = false

    //HOF
    @objc public var wishListIconName: String = "White-Heart"
    @objc public var wishlistTopViewConstraint: Double = 0
    @objc public var wishListClearAllIsHidden: Bool = false

    // MARK: - BAG
    @objc public var bagTextGoToShoppingButtonDistance: Double = 200.0
    @objc public var bagItemColourAndSizeSeparator = " "
    @objc public var voucherTotalInfoPanelHeight: CGFloat = 154
    //HOF only
    @objc public var bagNoItemIconName: String = "White-Bag"
    @objc public var bagProductCellHeight: Double = 180
    @objc public var bagItemPriceHidden: Bool = true
    @objc public var signButtonFontSize: Double = 17.0
    @objc public var bagViewTableHasSeparator: Bool = true
    @objc public var bagEnableDeleteConfirmation: Bool = false

    // MARK: - Search bar
    @objc public var defaultSeparatorStyle: Bool = true
    @objc public var searchBarTitleViewWhite: Bool = false
    @objc public var searchClearHistoryButtonVisible: Bool = true
    @objc public var ignoreImageURL: String = "http://az412776.vo.msecnd.net/app29/4-320.jpg"
    @objc public var isShowingMostRecentSearchesEnabled: Bool = false
    @objc public var searchNoItemsIconName: String = "EmptyStateSearch"

    @objc public var shopHeaderImageURL_iPhone: String = "http://az412776.vo.msecnd.net/app126/993562-1.jpg"
    @objc public var shopHeaderImageURL_iPad: String = "http://az412776.vo.msecnd.net/app126/993562-1.jpg"
    @objc public var shopHeaderViewHeight: Double = 140.0

    @objc public var currentAbandonedBagDate: Date?
    @objc public var keyForDeeplinkPush: String = "Track"
    @objc public var keyForUALandingPagePush: String = "Track"
    @objc public var unattributedUACampaignElapsedTime: Double = 12

    // MARK: - SettingParser Keys for Tracking
    @objc public var bespokeGoogleAnalyticsId: String = "" // cloud
    @objc public var googleAnalyticsID: String = "" // cloud

    // MARK: Facebook key
    @objc public var facebookAppID: String = ""
    @objc public var facebookDisplayName: String = ""

    // MARK: Tune Marketing SDK
    @objc public var tuneAdvertiserId: String = ""
    @objc public var tuneConversionKey: String = ""

    // MARK: - STORES
    @objc public var favoriteButtonFontSize: Double = 14.0
    @objc public var mapZoomInDistance: Double = 5000
    @objc public var storesScreenShouldDisplayCityTab = true
    @objc public var storeTableViewCellHeight: Double = 60.0
    @objc public var favoriteStoreRequiresLoggedInUser = true

    @objc public var storesPagesOriginY: Double = 64.0

    @objc public var isIntellisenseEnabled: Bool = false

    //Mark:- Store Detail
    @objc public var storeDetailMapCellHeight: Double = 150.0
    @objc public var storeDetailMapCellHeightShort: Double = 100.0
    @objc public var iPadStoreDetailMapCellHeight: Double = 550.0
    @objc public var storeDetailNameCellHeight: CGFloat = 80.00
    @objc public var storeDetailHoursCellHeight: CGFloat = 255.00
    @objc public var storeDetailCallCellHeight: CGFloat = 85.00
    @objc public var storeDetailFavoriteCellHeight: CGFloat = 85.00
    @objc public var storeDetailNameOnNavigationBar: Bool = true
    @objc public var storeDetailDirectionsBarButtonItemStyle = 0.0

    // MARK: - My profile content
    // MARK: - My profile other information
    @objc public var myProfileBannerURL: String = "http://az412776.vo.msecnd.net/app96/687617-1.jpg" // cloud
    @objc public var myProfileBannerBackgroundURL: String = "http://az412776.vo.msecnd.net/app96/687618-1.jpg"
    @objc public var myProfileLoginContentMode: String = PoqImageContentMode.ScaleAspectFill.rawValue
    @objc public var myProfileActionButtonHeight: Double = 80

    @objc public var myProfileLinkCardUrl: String = ""
    @objc public var myProfileRewardCardInfoImage: String = "http://az412776.vo.msecnd.net/app96/693426-1.png"//UAT image with stars"http://az412776.vo.msecnd.net/app96/691832-1.png"

    @objc public var showGoShoppingButton: Bool = false
    @objc public var myProfileFavoriteStoreOpeningTimesFormat: String = " %@ %@ %@"

    @objc public var isMyProfileBannerAfterLoginEnabled: Bool = true
    @objc public var isMyProfileFavoriteStoreEnabled: Bool = true
    @objc public var isMyProfileMySizesEnabled: Bool = true
    @objc public var isMyProfileHistoryEnabled: Bool = true
    @objc public var isMyProfileUnlockFeaturesLinkEnabled: Bool = true
    @objc public var isMyProfilePlatfromLoginEnabled: Bool = false
    @objc public var bottomDistanceFromSignUpButton: Double = 40
    @objc public var myProfilePlatformLoginViewCellMinHeight: Double = 160
    // MARK: - My sizes
    // MARK: - Generic

    @objc public var myProfileTitleViewCellHeight: CGFloat = 80.0

    // MyProfileLinkViewCell
    @objc public var profileLinkCellLeftAlignment: CGFloat = 10.0

    // MARK: - MY PROFILE

    @objc public var isLoginViewPresentedModally: Bool = false
    @objc public var isSignUpViewPresentedModally: Bool = true
    @objc public var shouldLoginHeaderBeShown: Bool = true
    @objc public var shouldShowVersionInfo: Bool = false

    // MARK: - SIGN UP
    @objc public var solidLineHasSeparator: Bool = false
    @objc public var passwordValidationType: Double = PasswordValidationType.default.rawValue

    @objc public var isMyProfileDOBEnabled: Bool = true

    // Platform Core Shopping offering doesn't allow editing email.
    // This has to be updated for Magento customers
    @objc public var isMyProfileEmailEnabled: Bool = false

    @objc public var isPromotionCellEnabledOnSignup: Bool = true
    @objc public var isMasterCardCellEnabledOnSignup: Bool = true
    @objc public var isCardImageCellEnabledOnSignup: Bool = true
    @objc public var isGenderCellEnabledOnSignup: Bool = true

    @objc public var allowDataSharingCellEnabledOnSignup: Bool = true
    @objc public var signUpNameCellSeparatorStyle: Double = CellSeparatorType.solid.rawValue
    @objc public var signUpEmailCellSeparatorStyle: Double = CellSeparatorType.paintcodeHorizontal.rawValue
    @objc public var signUpPasswordCellSeparatorStyle: Double = CellSeparatorType.solid.rawValue
    @objc public var showErrorOnInvalidEmailWhileTyping: Bool = true // both login and registration
    //MARK SimplyBe web SignUP

    @objc public var webViewRegistrationURL: String = ""
    @objc public var webViewSuccessfulRegistrationURL: String = ""

    // MARK: - SIGN IN

    @objc public var loginPageId: String = "2326" //UAT 2036

    @objc public var signUpPageId: String = "2327"//UAT :2258

    @objc public var submitButtonType: Double = SubmitButtonType.white.rawValue
    @objc public var signUpHideVerticalSeparator: Bool = true

    @objc public var signUpViewForPlatform: Bool = true
    @objc public var showHeaderImageOnSignUp: Bool = true
    @objc public var imageHeaderCellId: String = "ImageHeader"
    @objc public var signUpIsSeparatorBetweenNamesVisible: Bool = true

    @objc public var headerCellHeightForPlatform: CGFloat = 80.0

    // MARK: - EDIT MY PROFILE
    @objc public var editMyProfilePageID: String = "3346"//Prod: 3346 //UAT:2259
    @objc public var editMyProfileDefaultDate: String = "0001-01-01T00:00:00"
    @objc public var editMyProfileRegisterUserDefaultDate: String = "01/01/1900"
    @objc public var editMyProfileBannerCellHeight: Double = 180.0

    @objc public var minimumBagItemsCountForAccordionView: Double = 3
    @objc public var dateLocale: String = "en_GB" //https://gist.github.com/jacobbubu/1836273
    @objc public var editMyProfileDefaultDateChoose: String = "01/01/1980"
    @objc public var editMyProfilePastDateIntervalStart: String = "01/01/1900"

    // MARK: - SCAN
    @objc public var scanPlatformDesign: Bool = true

    // MARK: - STORE STOCK
    @objc public var productAvailabilityBannerUrl: String = "http://az412776.vo.msecnd.net/app96/687619-1.jpg"

    // MARK: - My sizes
    @objc public var mySizesBannerUrl = "http://az412776.vo.msecnd.net/app96/687619-1.jpg"

    // MARK: - Order history
    @objc public var orderHistoryListCellHeight: CGFloat = 200.0
    @objc public var isOrderHistoryTitleListShown: Bool = true
    @objc public var shouldShowOrderCount: Bool = true
    @objc public var orderDetailViewType: Double = OrderDetailViewType.platform.rawValue
    @objc public var shouldShowOrderSpinner: Bool = false
    @objc public var shouldMakeOrderStatusViewCircle: Bool = false

    // MARK: - Order history details
    @objc public var orderDetailsBasicInfoCellHeight: Double = 240.0
    @objc public var orderDetailsTotalInfoCellHeight: Double = 130.0
    @objc public var orderDetailsProductInfoCellHeight: Double = 150.0

    // MARK: - OrderStatuses
    @objc public var orderPinkColorStatuses: String = "Placed"

    @objc public var orderDarkGreenColorStatuses: String = "Despatched;Despatched / Partially Returned;Despatched to Store;Ready for Collection;Collected;Despatched to Store / Partially Refunded;Collected / Partially Refunded;"

    @objc public var orderLightGreenColorStatuses: String = "Partially Despatched;Partially Despatched to Store;"

    @objc public var orderYellowColorStatuses: String = "Partially Returned;Partially Refunded;"

    @objc public var orderRedColorStatuses: String = "Fully Returned;Refund Issued, Uncollected;Refund Issued, Arrived Damaged;Refund Issued, Out of Stock;"

    @objc public var orderStatusesSeperator: String = ";"

    // MARK: - Lookbook
    @objc public var shopTheLookButtonWidth: Double = 300

    @objc public var lookbookPreviousAndNextButtonAlpha: Double = 0.8
    @objc public var lookbookCloseButtonAlpha: Double = 0.8

    @objc public var lookbookImageContentMode: String = PoqImageContentMode.ScaleAspectFit.rawValue

    @objc public var lookbookImageProductsPerPage: Double = 2
    @objc public var lookbookImageShopButtonHeight: Double = 45
    @objc public var lookbookImageShopButtonCornerRadius: Double = 5
    @objc public var lookbookSwipeViewTabbarHeight: Double = 45.0
    @objc public var lookbookHasCircleBackground: Bool = true

    // MARK: - iPad
    @objc public var addToBagButtonWidth: Double = 250
    @objc public var addToBagButtonHeight: Double = 48
    @objc public var iPadGoShoppingButtonLeadingSpace: Double = 175.0
    @objc public var iPadGoShoppingButtonTrailingSpace: Double = 175.0
    @objc public var iPadSignInButtonLeadingSpace: Double = 175.0
    @objc public var iPadSigninButtonTrailingSpace: Double = 175.0
    @objc public var iPadSignupButtonLeadingSpace: Double = 175.0
    @objc public var iPadSignupButtonTrailingSpace: Double = 175.0
    @objc public var iPadUnlockTheseFeaturesButtonLeadingSpace: Double = 180.0
    @objc public var iPadUnlockTheseFeaturesButtonTrailingSpace: Double = 180.0
    @objc public var iPadUnlockTheseFeaturesButtonVerticalSpaceFromTop: Double = 17.5
    @objc public var iPadUnlockTheseFeaturesButtonVerticalSpaceFromBottom: Double = 17.5
    @objc public var iPadMyProfileStartShoppingButtonWidth: Double = 395.0
    @objc public var iPadOrderListGoShoppingButtonLeadingSpace: Double = 175.0
    @objc public var iPadOrderListGoShoppingButtonTrailingSpace: Double = 175.0

    @objc public var iPadScanEnterButtonLeadingSpace: Double = 175.0
    @objc public var iPadScanEnterButtonTrailingSpace: Double = 175.0
    @objc public var iPadScanEnterSubmitButtonLeadingSpace: Double = 175.0
    @objc public var iPadScanEnterSubmitButtonTrailingSpace: Double = 175.0

    @objc public var iPadPDPColorPickerLeadingSpace: Double = 400.0

    @objc public var iPadLoginBannerCellHeight: Double = 300.0
    @objc public var iPadEditProfileBannerCellHeight: Double = 300.0
    @objc public var iPadShopHeaderViewHeight: Double = 300.0

    @objc public var iPadAddToBagFontSize: Double = 18
    @objc public var iPadCheckoutFontSize: Double = 18
    @objc public var iPadGoShoppingFontSize: Double = 18
    @objc public var iPadSignFontSize: Double = 18
    @objc public var iPadSignUpFontSize: Double = 18
    @objc public var iPadSignInFontSize: Double = 18
    @objc public var iPadUnlockTheseFeaturesFontSize: Double = 18
    @objc public var iPadMyProfileGoShoppingFontSize: Double = 18
    @objc public var iPadOrderListGoShoppingFontSize: Double = 18
    @objc public var iPadScanManualEnterFontSize: Double = 18
    @objc public var iPadScanManuallyEnterSubmitFontSize: Double = 18

    // MARK: - iPad banner urls
    @objc public var iPadMyProfileBannerBackgroundURL: String = "http://az412776.vo.msecnd.net/app96/1114971-1536.png"
    @objc public var iPadMySizesBannerUrl: String = "http://az412776.vo.msecnd.net/app96/1114973-1024.png"
    @objc public var iPadMyProfileBannerURL: String = "http://az412776.vo.msecnd.net/app96/1114970-1536.png"
    @objc public var iPadProductAvailabilityBannerUrl: String = "http://az412776.vo.msecnd.net/app96/687619-1.jpg"
    @objc public var iPadloginPageId: String = "2329"

    // MARK: - Review
    @objc public var reviewUserIconName: String = "Avatar"

    // MARK: - VoucherList
    @objc public var voucherListCellHeight: Double = 160.0
    @objc public var voucherListApplyToBagButtonCornerRadius: Double = 3.0
    @objc public var voucherListUseInStoreBorderWidth: Double = 1.0
    @objc public var voucherListUseInStoreCornerRadius: Double = 3.0
    @objc public var voucherEndDateFormat: String = "yyyy-MM-dd"
    @objc public var voucherEndDateDisplayFormat: String = "EEEE MM/dd"
    @objc public var voucherListEndDateFormatString: String = "Ends %@"

    // MARK: - VoucherDetail
    @objc public var voucherBarcodeFormat: String = PoqBarcodeType.Code128.rawValue

    // MARK: - Offers
    @objc public var offerListCellHeight: Double = 124.0
    @objc public var offerListRowSpacing: Double = 5.0

    // MARK: - Apply Voucher
    @objc public var editButtonDirection: String = "right"
    @objc public var showIconOnNoItemView: Bool = false

    // Mark:- Layar
    @objc public var layarConsumerKey: String = "epySQxgZcJVCjEnw"
    @objc public var layarConsumerSecret: String = "TkPzErHuWOwagGFixnVUfsQopZvClyqJ"

    // MARK: - Apply Voucher
    @objc public var studentVoucherCode: String = "xYHlDuL716n-dppFVFk2"

    @objc public var applyVoucherSuccessIconName: String = "icn-done"

    // MARK: - Native Checkout
    @objc public var checkoutBagType: Double = BagType.transfer.rawValue
    @objc public var shopType: Double = ShopPageType.accordionMenu.rawValue

    @objc public var showSubtotalOnBag: Bool = true
    @objc public var checkoutPayWithCardFontSize: Double = 15

    @objc public var checkoutOrderSummaryTermsAndConditionPageId: String = ""
    
    @objc public var enable3DSecure: Bool = false

    // MARK: - Checkout Address
    @objc public var importButtonFontSize: Double = 14.0
    @objc public var checkoutAddressTableViewCellHeight: CGFloat = 60.0
    @objc public var checkoutAddressTableViewPoqTitleBlockHeight: CGFloat = 40.0
    @objc public var checkoutAddressPickerTableViewCellHeight: CGFloat = 200.0

    @objc public var billingAddressInformationLenght: Double = 10
    @objc public var deliveryAddressInformationLenght: Double = 11
    @objc public var emailFieldEnabledForAddress: Bool = false
    @objc public var companyFieldEnabledForAddress: Bool = false
    @objc public var countyFieldEnabledForAddress: Bool = false

    @objc public var nativeCheckoutShowStepNumbers: Bool = true
    //SimplyBe specific - required login before checkout
    @objc public var checkoutLoginGateEnabled: Bool = false

    /// Describe location of 'Save' button on 'CreateCardPaymentMethod' sceen. All values described in NativeCheckoutStylingHelper
    @objc public var nativeCheckoutSaveButtonLocation: String = "Bottom"

    @objc public var isChooseFromContactsEnabled: Bool = true

    // MARK: - Validation
    @objc public var phoneRegex: String = "^[0-9()+ -]+$"
    @objc public var postCodeUKRegex: String = "(GIR 0AA)|((([A-Z-[QVX]][0-9][0-9]?)|(([A-Z-[QVX]][A-Z-[IJZ]][0-9][0-9]?)|(([A-Z-[QVX‌​]][0-9][A-HJKSTUW])|([A-Z-[QVX]][A-Z-[IJZ]][0-9][ABEHMNPRVWXY]))))\\s?[0-9][A-Z-[C‌​IKMOV]]{2})"
    @objc public var zipCodeUSARegex: String = "\\d{5}(?:[-\\s]\\d{4})?$"
    @objc public var shouldShowOrderSpinnerOnOrderStatusDetails: Bool = true

    // MARK: - Payment Method
    @objc public var viewAmendButtonTextFontSize: Double = 14.0
    @objc public var displayFAQTextWithShrinkToSize: Bool = true

    // MARK: - EDIT ADDRESS
    @objc public var addressTypeTitleEnabled: Bool = true
    @objc public var isMyProfileAddNewAddressEnabled: Bool = true
    @objc public var isMyProfileEditAddressEnabled: Bool = true
    @objc public var myProfileAddressSystemTopRightButton: Bool = false
    //my profile visual
    @objc public var myProfileLinkViewCellHeight: Double = 45

    @objc public var setAsPrimaryBillingAddressFieldEnabled: Bool = true
    @objc public var setAsPrimaryShippingAddressFieldEnabled: Bool = true

    // MARK: - iBeacon
    @objc public var isBeaconEnabled: Bool = true

    // MARK: - Tinder
    @objc public var tinderFirstTimeLoadImageURL: String = ""

    // MARK: SHOW/HIDE hamburger menu
    @objc public var hideRightNavigationMenuOnStore: Bool = true
    @objc public var hideRightNavigationMenuOnBag: Bool = true
    @objc public var hideRightNavigationMenuOnWish: Bool = true
    @objc public var hideRightNavigationMenuOnMyProfile: Bool = true
    @objc public var resetBeaconPresrentedInfoOnLeaveRegion: Bool = true

    // MARK: Optimizely FOR AB TESTING
    //default is poq sales
    @objc public var optimizelyProjectToken: String = ""

    //enable recognition tracking
    @objc public var enableRecognitionTracking: Bool = false

    //enable nearest store name tracking
    @objc public var enableNearestStoreTracking: Bool = false

    //enable progress hud stlye message (MSG only)
    @objc public var enableProgressHudOnEditMyProfile: Bool = false

    //disable that for HOF
    @objc public var enableHideCountLabelOnBag: Bool = true

    @objc public var svprogressHudCornerRadius: CGFloat = 14

    @objc public var svprogressIconSize: CGFloat = 28

    @objc public var platformLoginLengthBetweenSigninAndRegisterButton: CGFloat = 20
    @objc public var shouldShowImageonTheWholeScreen: Bool = true

    /// Brand Landing page
    @objc public var brandingLandingImageRatio: CGFloat = 0.75 // w/h

    @objc public var showCheckoutNavigation: Bool = true

    // MARK: ACCOUNT
    @objc public var changePasswordComponentUrl: String = ""
    @objc public var forgetPasswordComponentUrl: String = ""

    @objc public var changePasswordSaveActionJS: String = "document.forms[0].submit()"
    @objc public var forgetPasswordSaveActionJS: String = "document.forms[0].submit()"

    @objc public var emailValidationRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    @objc public var passwordValidationRegExp: String = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"

    @objc public var logoutUserOnChangeCountry: Bool = true
    @objc public var phoneNumberFormat = ""

    // MARK: Onboarding
    @objc public var isOnboardingAvailable: Bool = false
    @objc public var onboardingShowPageControl: Bool = true
    @objc public var onboardingSeparatorHeight: Double = 20

    // MARK: Gifs 
    /// Number of gifs, which will be stored in memory for faster access
    @objc public var inMemeoryCacheGifsNumber: Double = 5.0

    @objc public var isPriceEnabledOnSizeSelector: Bool = false
    @objc public var shouldDisplayAddressCountry: Bool = true
    @objc public var shouldDisplayAddressState: Bool = false

    // MARK: force update
    @objc public var forceUpdate: Bool = false
    @objc public var forceUpdateButtonCornerRadius: Double = 4.0
    @objc public var forceUpdateItunesLink: String = ""

    @objc public var forceUpdateUrl_iPhone: String = "http://bathinfashion-4021.kxcdn.com/wp-content/uploads/2016/02/state-of-fashion-event-thumb.jpg"
    @objc public var forceUpdateUrl_iPhone4: String = "http://bathinfashion-4021.kxcdn.com/wp-content/uploads/2016/02/state-of-fashion-event-thumb.jpg"
    @objc public var forceUpdateUrl_iPad: String = "http://bathinfashion-4021.kxcdn.com/wp-content/uploads/2016/02/state-of-fashion-event-thumb.jpg"

    @objc public var forceUpdateBottomPadding: Double = 20.0
    @objc public var forceUpdateTopPadding: Double = 20.0

    // MARK: App stories

    @objc public var appStoriesCarouselImageRatio: Double = 2.3 // w/h
    // This feature flag will determine whether the AppStories will be shown in the home screen or not. This is configurable through MB.
    @objc public var isStoriesCarouselOnHomeEnabled = false

    @objc public var versionBuildAPINumbers: String {
        let dictionary = Bundle.main.infoDictionary
        let version = dictionary?["CFBundleShortVersionString"]
        let build = dictionary?["CFBundleVersion"]
        let cloudSettingsVersion = PListHelper.sharedInstance.getApiVersion()
        return "Version: \(version ?? "") Build: \(build ?? "" ) API: \(cloudSettingsVersion ?? "")"
    }

    // FIXME: this functions here, because some settings are not really can be used with Key-Value-Coding, and we want avoid crash
    override public func setValue(_ value: Any?, forUndefinedKey key: String) {
        Log.error("We are trying set value for unexisted property: \(key) in \(type(of: self))")
    }

    override public func value(forUndefinedKey key: String) -> Any? {
        Log.error("We are trying get value for unexisted property: \(key) in \(type(of: self))")
        return nil
    }

}
