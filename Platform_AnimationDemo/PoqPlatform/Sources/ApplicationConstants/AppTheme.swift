//
//  AppTheme.swift
//  Poq.iOS
//
//  Created by Jun Seki on 28/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqModuling
import UIKit

final public class AppTheme: NSObject, AppConfiguration {

    public static var sharedInstance = AppTheme()

    public let configurationType: PoqSettingsType = .theme

    // MARK: - TAB
    @objc public var tabBarBackgroundColour = UIColor.white

    // MARK: - Main
    @objc public var mainColor = UIColor.gray // UIColor(red: 255.0/255.0, green: 15.0/255.0, blue: 190/255.0, alpha: 1)
    @objc public var mainTextFont = UIFont.systemFont(ofSize: 16) // Cloud
    @objc public var mainTextColor = UIColor.black // Cloud
    @objc public var checkoutConfirmationTotalLabelFont = UIFont.boldSystemFont(ofSize: 22)

    @objc public var naviBarTitleFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var naviBarTitleColor = UIColor.black

    @objc public var primaryButtonBackgroundColor = UIColor.white
    @objc public var primaryButtonBackgroundColorForDisabledState = UIColor.gray
    @objc public var primaryButtonBackgroundColorForHighligtedState = UIColor.lightGray
    @objc public var primaryButtonFont = UIFont.boldSystemFont(ofSize: 17)
    @objc public var primaryButtonFontColor = UIColor.black
    @objc public var primaryButtonFontColorForDisabledState = UIColor.gray
    @objc public var primaryButtonCornerRadius: Double = 2.0
    @objc public var primaryButtonBorderWidth: Double = 1.0
    @objc public var primaryButtonBorderColor = UIColor.white
    @objc public var checkoutOrderConfirmationTotalDetailLabelColor = UIColor.black

    @objc public var secondaryButtonBackgroundColor = UIColor.white
    @objc public var secondaryButtonBackgroundColorForDisabledState = UIColor.gray
    @objc public var secondaryButtonBackgroundColorForHighligtedState = UIColor.lightGray
    @objc public var secondaryButtonFont = UIFont.boldSystemFont(ofSize: 17)
    @objc public var secondaryButtonFontColor = UIColor.black
    @objc public var secondaryButtonFontColorForDisabledState = UIColor.gray
    @objc public var secondaryButtonCornerRadius: Double = 2.0
    @objc public var secondaryButtonBorderWidth: Double = 1.0
    @objc public var secondaryButtonBorderColor = UIColor.white

    @objc public var blackButtonFont = UIFont.systemFont(ofSize: 17)
    @objc public var whiteButtonFont = UIFont.systemFont(ofSize: 17)

    /// These settings apply to right bar button item
    @objc public var naviBarItemFont = UIFont.systemFont(ofSize: 14)
    @objc public var naviBarItemColor = UIColor.black
    @objc public var naviBarItemPressedColor = UIColor.gray
    @objc public var naviBarItemDisabledColor = UIColor.gray

    /// These settings apply to both: right and left bar button items
    @objc public var naviBarLeftItemFont = UIFont.systemFont(ofSize: 14)
    @objc public var naviBarLeftItemColor = UIColor.black
    @objc public var naviBarLeftItemPressedColor = UIColor.gray
    @objc public var naviBarLeftItemDisabledColor = UIColor.gray

    // Will be used only for first view controller

    @objc public var naviBarTintColor = UIColor.white

    // MARK: - Home
    @objc public var dismissButtonFont = UIFont.systemFont(ofSize: 15)
    @objc public var dismissButtonTextColor = UIColor.white

    // MARK: - Search
    @objc public var searchHistoryHeaderFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var searchHistoryFont = UIFont.systemFont(ofSize: 14)
    @objc public var searchHistoryColor = UIColor.black
    @objc public var searchHistoryHeaderColor = UIColor.black

    @objc public var searchBarPlaceholderFont = UIFont.systemFont(ofSize: 12)
    @objc public var searchBarPlaceholderColor = UIColor.lightGray

    @objc public var searchBarCancelButtonFont = UIFont.systemFont(ofSize: 14)
    @objc public var searchBarCancelButtonColor = UIColor.black

    @objc public var searchBarTextAreaBackground = UIColor(white: 0.9, alpha: 1.0)
    @objc public var searchBarBackground = UIColor.white

    @objc public var searchHeaderBackground = UIColor(white: 0.93, alpha: 1)
    @objc public var searchHeaderTextColor = UIColor.darkGray
    @objc public var searchHeaderTextFont = UIFont.systemFont(ofSize: 17)

    @objc public var searchHistoryClearButtonFont = UIFont.systemFont(ofSize: 17)

    @objc public var searchHistoryClearButtonColor = UIColor.gray
    @objc public var searchHistoryClearButtonSelectedColor = UIColor.white

    @objc public var searchHistoryClearButtonSelectedBackgroundColor = UIColor.gray

    @objc public var searchResultTextColor = UIColor.black
    @objc public var searchResultParentTextColor = UIColor.blue
    @objc public var searchResultParentFont = UIFont.systemFont(ofSize: 17)
    @objc public var searchResultTextFont = UIFont.systemFont(ofSize: 17)

    // MARK: - PLP
    @objc public var sortingOptionsBarBackgroundColor = UIColor.white

    @objc public var plpCollectionViewBackgroundColor = UIColor.white

    @objc public var sortingOptionTextColor = UIColor.black
    @objc public var sortingOptionSelectedTextColor = UIColor.black

    @objc public var sortingButtonNormalFont: UIFont =  UIFont.systemFont(ofSize: 14)
    @objc public var sortingButtonPressedFont = UIFont.boldSystemFont(ofSize: 14)

    @objc public var plpBrandLabelColor = UIColor.black
    @objc public var plpBrandLabelFont = UIFont.boldSystemFont(ofSize: 17)

    @objc public var plpGroupedProductCollectionViewBackgroundColor = UIColor.white

    @objc public var plpGroupedBrandFont = UIFont.boldSystemFont(ofSize: 16)
    @objc public var plpGroupedBrandColor = UIColor.black

    @objc public var plpGroupedProductNameColor = UIColor.black
    @objc public var plpGroupedProductNameFont = UIFont.systemFont(ofSize: 14)

    @objc public var plpGroupedPriceFont = UIFont.boldSystemFont(ofSize: 16)
    @objc public var plpGroupedSpecialPriceFont = UIFont.boldSystemFont(ofSize: 16)
    @objc public var plpGroupedPriceColor = UIColor(red: 255.0/255.0, green: 0/255.0, blue: 64/255.0, alpha: 1)
    @objc public var plpGroupedSpecialPriceColor = UIColor.black

    @objc public var plpTitleLabelColor = UIColor.black
    @objc public var plpTitleLabelFont = UIFont.systemFont(ofSize: 17)

    @objc public var plpSelectedSortTypeLabelFont = UIFont.systemFont(ofSize: 15)
    @objc public var plpSortTypeLabelFont = UIFont.systemFont(ofSize: 15)
    @objc public var plpSortTypeLabelBackground = UIColor.white

    @objc public var promotionLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var promotionLabelColor = UIColor.white
    @objc public var promotionAreaColor = UIColor(red: 225/255.0, green: 224/255.0, blue: 224/255.0, alpha: 0.85)

    @objc public var plpSortLabelFont = UIFont.systemFont(ofSize: 15)
    @objc public var plpSortLabelTextColor = UIColor.black
    @objc public var plpSortOptionsSeparatorColor = UIColor.clear

    @objc public var plpFilterLabelFont = UIFont.systemFont(ofSize: 15)
    @objc public var plpFilterLabelNormalTextColor = UIColor.black
    @objc public var plpFilterLabelDisabledTextColor = UIColor.lightGray
    @objc public var plpFiltersToolbarSeparatorColor = UIColor.lightGray

    @objc public var itemsSummaryViewBackgrounColor = UIColor.lightGray

    @objc public var plpNoSearchResultsNormalFont = UIFont.systemFont(ofSize: 17) // Will be used for most of phrase
    @objc public var plpNoSearchResultsBoldFont = UIFont.boldSystemFont(ofSize: 17) // Will be on "<QUERY>"

    // MARK: - PDP
    @objc public var pdpDetailOtherNavigationTitleFont = UIFont(name: "SourceSansPro-Bold", size: 19) ?? UIFont.boldSystemFont(ofSize: 19)
    @objc public var brandedPdpDetailOtherNavigationTitleFont = UIFont(name: "Arial", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
    @objc public var pdpDetailOtherNavigationTitleColor = UIColor.black

    @objc public var pdpReviewsLabelFont = UIFont.boldSystemFont(ofSize: 17)
    @objc public var iPadGoShoppingButtonFontSize: Double = 18
    @objc public var pdpReviewsLabelColor = UIColor.black
    @objc public var pdpBrandLabelFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var pdpBrandLabelColor = UIColor.black
    @objc public var pdpTitleLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var pdpTitleLabelColor = UIColor.black
    @objc public var pdpSizesLabelFont = UIFont.systemFont(ofSize: 16)
    @objc public var pdpSizesTitleLabelFont = UIFont.boldSystemFont(ofSize: 16)

    @objc public var pdpMoreColorsFont = UIFont.boldSystemFont(ofSize: 14)

    @objc public var pdpDescriptionLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var pdpDescriptionLabelColor = UIColor.black
    @objc public var pdpDescriptionTitleLabelFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var pdpDescriptionTitleLabelColor = UIColor.black

    @objc public var pdpProductColorTitleColor = UIColor.black
    @objc public var pdpProductColorTitleBorderColor = UIColor.black
    @objc public var pdpProductColorTitleFont = UIFont.systemFont(ofSize: 14)

    @objc public var pdpProductRewardDetailsCellRewardColor = UIColor.black
    @objc public var pdpProductRewardDetailsCellRewardFont = UIFont.systemFont(ofSize: 14)
    @objc public var pdpProductRewardDetailsCellPPUColor = UIColor.black
    @objc public var pdpProductRewardDetailsCellPPUFont = UIFont.systemFont(ofSize: 14)
    @objc public var pdpProductRewardDetailsCellCodeColor = UIColor.black
    @objc public var pdpProductRewardDetailsCellCodeFont = UIFont.systemFont(ofSize: 14)

    @objc public var pdpProductDescriptionCellHeadlineFont = UIFont.systemFont(ofSize: 14)
    @objc public var pdpProductDescriptionCellDescriptionFont = UIFont.systemFont(ofSize: 14)
    @objc public var pdpProductDescriptionLineSpacing: Double = 5.0
    @objc public var moreColorsFont = UIFont.boldSystemFont(ofSize: 12)
    @objc public var moreColorsColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204/255.0, alpha: 1)

    @objc public var sizeSelectHeaderFont = UIFont.boldSystemFont(ofSize: 16)
    @objc public var lowStockFont = UIFont.systemFont(ofSize: 14)
    @objc public var lowStockIndicatorTextColor = UIColor.yellow

    @objc public var starViewFillColor = UIColor.black
    @objc public var starViewUnfillColor = UIColor.white

    @objc public var colorSwatchImageBorder = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    @objc public var colorSwatchSelectorBorder = UIColor.gray
    @objc public var colorSwatchSelectorBorderWidth: Double = 1
    @objc public var pdpPageControlCurrentTintColor = UIColor.black
    @objc public var pdpPageControlTintColor = UIColor.darkGray

    @objc public var pdpSizeSelectorHeader = UIFont.systemFont(ofSize: 16)
    @objc public var pdpSizeSelectorHeaderTextColor = UIColor.black
    
    // The section beneath description
    @objc public var pdpSizeGuideLabelFont = UIFont.systemFont(ofSize: 16)
    @objc public var pdpSizeGuideLabelColor = UIColor.black
    @objc public var pdpCareDetailsLabelFont = UIFont.systemFont(ofSize: 16)
    @objc public var pdpDeliveryLabelFont = UIFont.systemFont(ofSize: 16)

    @objc public var addToBagButtonBackgroundColor = UIColor.black
    @objc public var pdpAddToBagButtonFont = UIFont.systemFont(ofSize: 16)
    @objc public var pdpAddToBagButtonCornerRadius: Double = 0.0

    // MARK: - IPAD
    @objc public var iPadAddToBagButtonTextSize: Double = 18

    @objc public var iPadSignButtonFontSize: Double = 18
    @objc public var iPadSignUpButtonFontSize: Double = 18
    @objc public var iPadSignInButtonFontSize: Double = 18
    @objc public var iPadUnlockTheseFeaturesButtonFontSize: Double = 18
    @objc public var iPadMyProfileGoShoppingButtonFontSize: Double = 18
    @objc public var iPadOrderListGoShoppingButtonFontSize: Double = 18
    @objc public var iPadScanManualEnterButtonFontSize: Double = 18
    @objc public var iPadScanManuallyEnterSubmitButtonFontSize: Double = 18

    // MARK: - TAB BAR
    @objc public var tabBarTintColor = UIColor.black
    @objc public var tabBarSelectedTintColor = UIColor(red: 255.0/255.0, green: 15.0/255.0, blue: 190/255.0, alpha: 1)

    @objc public var tabBarFont = UIFont.systemFont(ofSize: 12)
    @objc public var tabBarSelectedFont: UIFont?
    @objc public var tabBarFontColor = UIColor.black
    @objc public var tabBarShadowColor = UIColor.gray

    // MARK: - BADGE
    @objc public var navigationBadgeFont = UIFont.boldSystemFont(ofSize: 12)
    @objc public var badgeFont = UIFont.boldSystemFont(ofSize: 10)
    @objc public var badgeBackgroundColor = UIColor.white
    @objc public var badgeTextColor = UIColor.black
    @objc public var badgeBorderColor = UIColor(red: 255.0/255.0, green: 15.0/255.0, blue: 190/255.0, alpha: 1)

    // MARK: - PRICE
    @objc public var priceFont = UIFont.systemFont(ofSize: 14)
    @objc public var plpPriceFont = UIFont.systemFont(ofSize: 12)
    @objc public var singlePriceFont = UIFont.systemFont(ofSize: 12)
    @objc public var productsCarouselSinglePriceFont = UIFont.systemFont(ofSize: 16)
    @objc public var productsCarouselPriceFont = UIFont.systemFont(ofSize: 16)
    @objc public var productsCarouselSpecialPriceFont = UIFont.systemFont(ofSize: 16)

    @objc public var priceTextColor: UIColor=UIColor.black
    @objc public var singlePriceTextColor = UIColor.black

    @objc public var specialPriceFont = UIFont.boldSystemFont(ofSize: 14)

    @objc public var peekPriceFont = UIFont.systemFont(ofSize: 16)
    @objc public var peekSpecialPriceFont = UIFont.systemFont(ofSize: 16)

    @objc public var pdpPriceFont = UIFont.systemFont(ofSize: 14)
    @objc public var pdpSpecialPriceFont = UIFont.boldSystemFont(ofSize: 14)

    @objc public var plpSpecialPriceFont = UIFont.boldSystemFont(ofSize: 12)

    @objc public var specialPriceTextColor: UIColor=UIColor.red
    @objc public var strikethroughPriceTextColor = UIColor.lightGray

    @objc public var brandedPageTitleFont = UIFont(name: "Arial", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
    @objc public var brandedPageTitleColor = UIColor.black

    @objc public var brandedProductTitleFont = UIFont(name: "Arial", size: 12) ?? UIFont.boldSystemFont(ofSize: 12)

    @objc public var brandedPlpTitleLabelColor = UIColor.black

    @objc public var bagNavigationBarItemTextColorActive = UIColor.black
    @objc public var bagNavigationBarItemTextColorDisable = UIColor.gray

    @objc public var brandedPlpPriceFont = UIFont(name: "Arial-BoldMT", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    @objc public var brandedPlpSpecialPriceFont = UIFont(name: "Arial", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)

    @objc public var brandedPlpBrandLabelFont = UIFont(name: "Arial-BoldMT", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    @objc public var brandedPlpTitleLabelFont = UIFont(name: "Arial", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)

    @objc public var recentlyViewedPriceFont = UIFont(name: "Arial-BoldMT", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    @objc public var recentlyViewedSpecialPriceFont = UIFont(name: "Arial", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    @objc public var recentlyViewedCarouselProductTitleFont = UIFont.systemFont(ofSize: 12)
    @objc public var recentlyViewedCarouselTitleFont = UIFont(name: "Arial", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    @objc public var recentlyViewCarouselDetailTitleFont = UIFont(name: "Arial", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    @objc public var recentlyViewedCarouselDetailTitleColor = UIColor.blue

    @objc public var brandedPdpPriceFont = UIFont(name: "Arial-BoldMT", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    @objc public var brandedPdpSpecialPriceFont = UIFont(name: "Arial", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)

    @objc public var brandedPdpBrandLabelFont = UIFont(name: "Arial-BoldMT", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    @objc public var brandedPdpTitleLabelFont = UIFont(name: "Arial", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)

    @objc public var wishlistPriceFont = UIFont(name: "Arial-BoldMT", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
    @objc public var wishlistSpecialPriceFont = UIFont(name: "Arial", size: 17) ?? UIFont.systemFont(ofSize: 17)

    @objc public var bagPriceFont = UIFont(name: "Arial-BoldMT", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
    @objc public var bagSpecialPriceFont = UIFont(name: "Arial", size: 17) ?? UIFont.systemFont(ofSize: 17)

    @objc public var checkoutButtonPressedColor = UIColor.white

    @objc public var checkoutButtonTextColor = UIColor.white

    @objc public var availabilityFont = UIFont.systemFont(ofSize: 16)
    @objc public var availabilityNotInStoreTextColor = UIColor.black
    @objc public var availabilityInStoreTextColor = UIColor.hexColor("#79C456")
    @objc public var availabilityOffTextColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)

    // MARK: - No Items fonts and color
    @objc public var noItemscontentCenterYConstraint: Double = -50.0
    @objc public var noItemsLabelFont = UIFont.systemFont(ofSize: 23)
    @objc public var noItemsLabelColor = UIColor.black
    @objc public var noItemsInstructionsLabelFont = UIFont.systemFont(ofSize: 16)
    @objc public var noItemsInstructionsLabelColor = UIColor.gray
    @objc public var tryAgainLabelFont = UIFont.systemFont(ofSize: 16)
    @objc public var tryAgainLabelColor = UIColor.gray

    // MARK: - Scan
    @objc public var scanNavigationTitleFont = UIFont.boldSystemFont(ofSize: 18)
    @objc public var scanTopLabelFont = UIFont.systemFont(ofSize: 16)
    @objc public var scanBottomLabelFont = UIFont.systemFont(ofSize: 16)
    @objc public var scanButtonLabelFont = UIFont.boldSystemFont(ofSize: 17)
    @objc public var scanLabelColor = UIColor.white

    @objc public var scanFocusMarkColor = UIColor.red
    @objc public var scanBarcodeLineColor = UIColor.white

    // MARK: - Wishlist screen
    @objc public var wishListCountLabelFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var wishListClearAllFont = UIFont.systemFont(ofSize: 14)
    @objc public var wishlistNavigationBarItemTextColor = UIColor.black

    @objc public var wishlistClearAllButtonTintColor = UIColor(red: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0)
    @objc public var wishlistToolbarSeparatorColor = UIColor.lightGray

    @objc public var wishlistBrandLabelFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var wishlistBrandLabelColor = UIColor.black
    @objc public var wishlistTitleLabelColor = UIColor.black
    @objc public var wishlistTitleLabelFont = UIFont.systemFont(ofSize: 14)

    // MARK: - Bag Screen
    @objc public var subTotalFont = UIFont.boldSystemFont(ofSize: 17)

    @objc public var totalLabelFont = UIFont.boldSystemFont(ofSize: 17)
    @objc public var totalFont = UIFont.boldSystemFont(ofSize: 17)

    @objc public var bagItemsCountLabelFont = UIFont.boldSystemFont(ofSize: 17)

    @objc public var bagTotalLabelColor = UIColor.black
    @objc public var bagTotalWordColor = UIColor.black

    // Individual cell
    @objc public var bagProductTitleLabelFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var bagProductTitleLabelColor = UIColor.black

    // 1 x £39.99
    @objc public var bagSubtotalFormulaLabelFont = UIFont.boldSystemFont(ofSize: 12)
    @objc public var bagSubtotalFormulaLabelColor = UIColor.black

    @objc public var bagQtyFont = UIFont.boldSystemFont(ofSize: 17)
    @objc public var bagQtyColor = UIColor.black
    @objc public var bagCheckoutFont = UIFont.systemFont(ofSize: 14)
    @objc public var bagSizeColorLabelColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1)
    @objc public var bagSizeColorLabelFont = UIFont.systemFont(ofSize: 17)

    @objc public var bagVoucherCodeFont = UIFont.systemFont(ofSize: 17)
    @objc public var bagVoucherCodeTextColor = UIColor.black

    @objc public var popUpTextFont = UIFont.systemFont(ofSize: 16)
    @objc public var popUpBackgroundColor = UIColor.white
    @objc public var popUpForegroundColor = UIColor.black

    // Empty state and background color
    @objc public var bagEmptyViewBackgroundColor = UIColor.white

    @objc public var wishlistEmptyViewBackgroundColor = UIColor.white

    // MARK: - Sign in
    @objc public var loginBigTitleLabelColor = UIColor.white
    @objc public var loginBigTitleLabelFont = UIFont.systemFont(ofSize: 35)

    @objc public var loginSmallTitleLabelColor = UIColor.white
    @objc public var loginSmallTitleLabelFont = UIFont.systemFont(ofSize: 16)

    @objc public var loginTextFieldFont = UIFont.systemFont(ofSize: 16)

    @objc public var loginMasterCardLabelFont = UIFont.systemFont(ofSize: 14)

    @objc public var signInRegisterInputPlaceHolderColor = UIColor.gray

    // MARK: - Page Menu params
    @objc public var scrollMenuBackgroundColor = UIColor.white
    @objc public var viewBackgroundColor: UIColor =  UIColor.white
    @objc public var selectionIndicatorColor = UIColor(red: 255.0/255.0, green: 15.0/255.0, blue: 190/255.0, alpha: 1)
    @objc public var bottomMenuHairlineColor = UIColor(red: 255.0/255.0, green: 15.0/255.0, blue: 190/255.0, alpha: 1)
    @objc public var selectedMenuItemLabelColor = UIColor(red: 255.0/255.0, green: 15.0/255.0, blue: 190/255.0, alpha: 1)
    @objc public var unselectedMenuItemLabelColor = UIColor.black
    @objc public var selectedMenuItemLabelFont = UIFont.boldSystemFont(ofSize: 18)
    @objc public var unselectedMenuItemLabelFont = UIFont.systemFont(ofSize: 16)
    @objc public var menuHeight = 40.0
    @objc public var menuItemWidth = 90.0
    @objc public var centerMenuItems = true
    @objc public var scrollMenuSeparatorColor = UIColor.white
    @objc public var scrollMenuSeparatorWidth = 1.0
    @objc public var scrollMenuSeparatorPercentageHeight = 0.6

    // MARK: - Filters types
    @objc public var filterTypeSelectedBackgroundColor = UIColor.white
    @objc public var filterTypeDefaultBackgroundColor = UIColor.white
    @objc public var filterTypeUnselectedFont = UIFont.systemFont(ofSize: 16)
    @objc public var filterTypeSelectedFont = UIFont.boldSystemFont(ofSize: 18)
    @objc public var filterTypeUnselectedLabelColor = UIColor.black
    @objc public var filterTypeSelectedLabelColor = UIColor(red: 255.0/255.0, green: 15.0/255.0, blue: 190/255.0, alpha: 1)
    @objc public var filterPriceFont = UIFont.boldSystemFont(ofSize: 16)
    @objc public var filterTypeNaviBtnFont = UIFont.systemFont(ofSize: 18)
    @objc public var filterClearAllTypeNaviBtnFont = UIFont.systemFont(ofSize: 18)
    @objc public var filterClearAllTypeNaviBarItemColor = UIColor.black
    @objc public var filterTypeTitleFont = UIFont.boldSystemFont(ofSize: 18)
    @objc public var filterCellTextColor = UIColor.black
    @objc public var filterCellDetailTextColor = UIColor.black
    @objc public var filterCellTextFont = UIFont.systemFont(ofSize: 18)
    @objc public var filterCellDetailTextFont = UIFont.systemFont(ofSize: 14)
    @objc public var filterClearAllColor = UIColor.black
    @objc public var filterClearAllBackgroundColor = UIColor.white
    @objc public var filterTypesTableCellBackgroundColor = UIColor.white
    @objc public var filterCellTintColor = UIColor.black

    // MARK: - RangeSlider
    @objc public var trackHighlightTintColor = UIColor(red: 180.0/255.0, green: 180.0/255.0, blue: 180.0/255.0, alpha: 1)

    @objc public var trackTintColor = UIColor(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1)

    @objc public var thumbTintColor = UIColor.black // HexAlphaColor("#FFDF2591")

    // MARK: - Store
    @objc public var storeDistanceFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var storeNameFont = UIFont.boldSystemFont(ofSize: 18)
    @objc public var storeAddressFont = UIFont.systemFont(ofSize: 14)
    @objc public var storeContactFont = UIFont.systemFont(ofSize: 13)
    @objc public var storeOpeningHoursFont = UIFont.systemFont(ofSize: 14)
    @objc public var storeTodayFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var storeDetailOpeningHoursTitleFont = UIFont.boldSystemFont(ofSize: 16)
    @objc public var callButtonFont = UIFont.systemFont(ofSize: 14)
    @objc public var callButtonTextColor = UIColor.black

    // MARK: - Sign up
    @objc public var textFieldActiveTitleFont = UIFont.systemFont(ofSize: 12)
    @objc public var signUpTextFieldFont = UIFont.systemFont(ofSize: 16)
    @objc public var signUpPromotionFont = UIFont.systemFont(ofSize: 16)
    @objc public var signUpPromotionBoldFont = UIFont.boldSystemFont(ofSize: 16)

    @objc public var signUpLabelFont = UIFont.boldSystemFont(ofSize: 17)
    @objc public var welcomeLabelFont = UIFont.systemFont(ofSize: 16)
    @objc public var companyLabelFont = UIFont.systemFont(ofSize: 35)
    @objc public var loyaltyPointsLabelFont = UIFont.systemFont(ofSize: 23)

    // MARK: - Favorite Store
    @objc public var favouriteStoreFont = UIFont.boldSystemFont(ofSize: 18)
    @objc public var favouriteStoreStockAvailabilityFont = UIFont.systemFont(ofSize: 14)
    @objc public var favoriteStoreButtonColor = UIColor.black
    @objc public var favoriteStoreButtonFont = UIFont.systemFont(ofSize: 16)

    // MARK: - Sign in
    @objc public var signInFont = UIFont.boldSystemFont(ofSize: 17)

    // MARK: - Opt out
    @objc public var optOutFont = UIFont.systemFont(ofSize: 10)

    @objc public var linkButtonColor = UIColor(red: 0/255.0, green: 132.0/255.0, blue: 203.0/255.0, alpha: 1.0)
    @objc public var linkButtonFont = UIFont.boldSystemFont(ofSize: 16)

    // MARK: - Other features
    @objc public var otherFeaturesFont = UIFont.systemFont(ofSize: 23)

    // MARK: - My profile
    @objc public var fullScreenBarcodeNaviTitleFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var fullScreenBarcodeTextFont = UIFont.systemFont(ofSize: 85)
    @objc public var checkoutNaviTitleFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var profileTitleFont = UIFont.boldSystemFont(ofSize: 19)
    @objc public var profileTitleLabelTextColor = UIColor.black
    @objc public var profileLinkFont = UIFont.systemFont(ofSize: 18)
    @objc public var unlockFeatureLabelFont = UIFont.boldSystemFont(ofSize: 17)
    @objc public var recentlyViewedLabelFont = UIFont.systemFont(ofSize: 23)
    @objc public var editMyProfileBirthdayPointsFont = UIFont.boldSystemFont(ofSize: 13)
    @objc public var profileLinkTitleFont = UIFont.boldSystemFont(ofSize: 15)
    @objc public var profileLinkTitleLabelTextColor = UIColor.black
    @objc public var editMyProfileBirthdayPlaceholderColor = UIColor.black

    // MARK: - dob date font
    @objc public var dobDateFont = UIFont.systemFont(ofSize: 16)

    // MARK: - In-store availability
    @objc public var productAvailabilityNavigationTitleFont = UIFont.boldSystemFont(ofSize: 22)
    @objc public var productAvailabilityBannerTitleFont = UIFont.boldSystemFont(ofSize: 23)
    @objc public var productAvailabilityBannerDescriptionFont = UIFont.systemFont(ofSize: 16)
    @objc public var productAvailabilitySelectionNameLabelFont = UIFont.systemFont(ofSize: 18)
    @objc public var productAvailabilitySelectionValueFont = UIFont.boldSystemFont(ofSize: 18)
    @objc public var productAvailabilityResultFont = UIFont.boldSystemFont(ofSize: 19)

    // MARK: - My sizes
    @objc public var mySizesNavigationTitleFont = UIFont.boldSystemFont(ofSize: 22)
    @objc public var mySizesBannerTitleFont = UIFont.boldSystemFont(ofSize: 23)
    @objc public var mySizesSelectionNameLabelFont = UIFont.systemFont(ofSize: 18)
    @objc public var mySizesSelectedSizeLabelFont = UIFont.systemFont(ofSize: 18)
    @objc public var mySizesSelectionValueFont = UIFont.boldSystemFont(ofSize: 18)

    // MARK: - Order
    @objc public var orderListCountLabelFont = UIFont.boldSystemFont(ofSize: 16)
    @objc public var orderListNoItemsLabelFont = UIFont.systemFont(ofSize: 23)
    @objc public var orderListNoItemsSubLabelFont = UIFont.systemFont(ofSize: 16)
    @objc public var orderListNoItemsSubLabelColor = UIColor.hexColor("#A6A6A6")
    @objc public var orderInfoViewBackgroundcolor = UIColor.white
    @objc public var orderCountLabelFont = UIFont.systemFont(ofSize: 17)
    @objc public var orderCountLabelTextColor = UIColor.black
    @objc public var trackOrderButtonLabelFont = UIFont.systemFont(ofSize: 16)

    // MARK: - Order status color
    @objc public var orderPinkColor = UIColor.hexColor("#FF0FBE")
    @objc public var orderDarkGreenColor = UIColor.hexColor("#04CB3D")
    @objc public var orderLightGreenColor = UIColor.hexColor("#C0DE39")
    @objc public var orderYellowColor = UIColor.hexColor("#FFCD0F")
    @objc public var orderRedColor = UIColor.hexColor("#D0021B")

    // MARK: - Order Summary
    @objc public var orderNumberTitleLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var orderNumberTitleLabelColor = UIColor.black

    @objc public var orderNumberLabelFont = UIFont.systemFont(ofSize: 32)
    @objc public var orderNumberLabelColor = UIColor.black

    @objc public var orderStatusLabelFont = UIFont.systemFont(ofSize: 18)
    @objc public var orderDetailStatusFont = UIFont.systemFont(ofSize: 18)
    @objc public var orderDetailStatusTextColor = UIColor.black

    @objc public var orderNameLabelFont = UIFont.systemFont(ofSize: 18)
    @objc public var orderNameLabelTextColor = UIColor.black

    @objc public var orderDeliveryFullNameLabelFont = UIFont.systemFont(ofSize: 18)
    @objc public var orderDeliveryFullNameLabelTextColor = UIColor.black

    @objc public var orderInfoTitleLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var orderInfoTitleLabelColor = UIColor.hexColor("#A6A6A6")

    @objc public var orderInfoLabelFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var orderInfoLabelColor = UIColor.black

    @objc public var giftMessageTitleLabelFont = UIFont.systemFont(ofSize: 16)
    @objc public var giftMessageTitleLabelColor = UIColor.black

    @objc public var giftMessageLabelFont = UIFont.systemFont(ofSize: 15)
    @objc public var giftMessageLabelColor = UIColor.black

    @objc public var orderSubTotalTitleLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var orderSubTotalLabelFont = UIFont.boldSystemFont(ofSize: 18)

    @objc public var orderVATTitleLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var orderVATAmountLabelFont = UIFont.boldSystemFont(ofSize: 18)

    @objc public var orderTotalTitleLabelFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var orderTotalLabelFont = UIFont.boldSystemFont(ofSize: 25)

    @objc public var orderProductCodeLabelColor = UIColor.black
    @objc public var orderProductCodeLabelFont = UIFont.systemFont(ofSize: 14)

    @objc public var orderSummaryTotalLabelBagItemsFont = UIFont.boldSystemFont(ofSize: 18)
    @objc public var orderSummaryTotalPriceLabelBagItemsFont = UIFont.boldSystemFont(ofSize: 18)

    // TnC
    @objc public var orderSummaryTermsAndConditionsFont = UIFont.systemFont(ofSize: 14)
    @objc public var orderSummaryTermsAndConditionsLabelColor = UIColor.black

    // MARK: - Order Confirmation
    @objc public var checkoutConfirmationSendMessageLabelFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var checkoutConfirmationEmailLabelFont = UIFont.boldSystemFont(ofSize: 20)
    @objc public var checkoutConfirmationOrderNumberFont = UIFont.systemFont(ofSize: 14)
    @objc public var checkoutConfirmationOrderNumberTextColor = UIColor.black
    @objc public var checkoutConfirmationOrderDateFont = UIFont.systemFont(ofSize: 13)
    @objc public var bagSecureCheckoutButtonLabelFont = UIFont.systemFont(ofSize: 21)
    // OrderConfirmationAddress
    @objc public var confirmationOrderAddressTypeFont = UIFont.systemFont(ofSize: 13)
    @objc public var confirmationOrderNameFont = UIFont.boldSystemFont(ofSize: 15)
    @objc public var confirmationOrderAddressFont = UIFont.systemFont(ofSize: 15)

    // ProductCell
    @objc public var confirmationOrderProductNameFont = UIFont.systemFont(ofSize: 13)
    @objc public var confirmationOrderProductQuantityFont = UIFont.systemFont(ofSize: 13)
    @objc public var confirmationOrderProductPriceFont = UIFont.systemFont(ofSize: 15)
    // Total Price
    @objc public var confirmationOrderTotalPayLabelFont = UIFont.systemFont(ofSize: 18)
    @objc public var confirmationOrderTotalPayValueFont = UIFont.systemFont(ofSize: 21)
    // SubTotal Price
    @objc public var checkoutOrderConfirmationSubTotalTitleLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var checkoutOrderConfirmationPriceFont = UIFont.systemFont(ofSize: 14)
    // Colors
    @objc public var confirmationBlackColor = UIColor.black
    @objc public var confirmationGrayColor = UIColor.gray
    @objc public var confirmationDarkGrayColor = UIColor.darkGray

    // MARK: - Review
    @objc public var reviewNameFont = UIFont.boldSystemFont(ofSize: 16)
    @objc public var reviewTitleFont = UIFont.systemFont(ofSize: 16)
    @objc public var reviewContentFont = UIFont.systemFont(ofSize: 16)
    @objc public var reviewColor = UIColor.black

    // MARK: - Loading Progress Hud
    @objc public var progressHudBackgroundColour = UIColor.hexColor("#FFFFFFFF")
    @objc public var progressHudForegroundColour = UIColor.hexColor("#FFFF0FBE")
    @objc public var progressHudFont = UIFont.systemFont(ofSize: 14)
    @objc public var progressHudFontColour = UIColor.black

    // MARK: - Lookbook
    @objc public var shopTheLookButtonBackgroundColour = UIColor.hexColor("#FFFFFF")
    @objc public var shopTheLookButtonLabelFont = UIFont.boldSystemFont(ofSize: 12)

    // MARK: - Shop tab    
    @objc public var shopTableBackgroundColor = UIColor.white
    @objc public var shopTableCellSelectedBackgroundColor = UIColor.gray

    @objc public var shopTabDefaultCategoryBackgroundColor = UIColor.white
    @objc public var shopTabDefaultCategoryTextColor = UIColor.black
    @objc public var shopTabDefaultCategoryFont = UIFont.boldSystemFont(ofSize: 17)

    @objc public var shopTabParentCategoryBackgroundColor = UIColor.white
    @objc public var shopTabParentCategoryTextColor = UIColor.black
    @objc public var shopTabParentCategoryFont = UIFont.boldSystemFont(ofSize: 17)

    @objc public var shopTabChildrenCategoryBackgroundColor = UIColor.white
    @objc public var shopTabChildrenCategoryTextColor = UIColor.black
    @objc public var shopTabChildrenCategoryFont = UIFont.boldSystemFont(ofSize: 14)

    @objc public var shopTabCategorySeparatorColor = UIColor.gray
    @objc public var shopTabBrandedCategorySeparatorColor = UIColor.clear

    @objc public var brandTextCategoryFont: UIFont = {
        let fontSize: CGFloat = DeviceType.IS_IPAD ? 14 : 16
        return UIFont(name: "Arial", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }()
    @objc public var brandImageCategoryFont = UIFont(name: "Arial", size: 14) ?? UIFont.systemFont(ofSize: 14)

    // MARK: - Page list
    @objc public var pagelistCellLabelFont = UIFont.systemFont(ofSize: 18)
    @objc public var pageListBackgroundColor = UIColor.groupTableViewBackground

    // MARK: - Vouchers
    @objc public var vouchersButtonFont = UIFont.systemFont(ofSize: 15)
    @objc public var vouchersApplyToBagButtonBackgroundColor = UIColor.black
    @objc public var vouchersApplyToBagButtonFontColor = UIColor.white
    @objc public var voucherListUseInStoreButtonBackgroundColor = UIColor.white
    @objc public var voucherListUseInStoreButtonFontColor = UIColor(red: 0.27, green: 0.60, blue: 0.74, alpha: 1.0)
    @objc public var voucherListUseInStoreButtonBorderColor = UIColor(red: 0.27, green: 0.60, blue: 0.74, alpha: 1.0)

    // MARK: - Offer
    @objc public var offerNameLabelFont = UIFont.systemFont(ofSize: 18)
    @objc public var offerDetailLabelFont = UIFont.systemFont(ofSize: 15)
    @objc public var offerCaptionLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var offerNameLabelColor = UIColor.black
    @objc public var offerDetailLabelColor = UIColor.black
    @objc public var offerCaptionLabelColor = UIColor.lightGray

    // MARK: - Apply Voucher
    @objc public var applyVoucherTitleLabelFont = UIFont.boldSystemFont(ofSize: 15)
    @objc public var applyVoucherTextFieldFont = UIFont.boldSystemFont(ofSize: 16)
    @objc public var voucherTypeTextFieldFont = UIFont.boldSystemFont(ofSize: 12)
    @objc public var voucherTypeSecelectionBackgroundColor = UIColor.black

    // MARK: - Invalid Text Color
    @objc public var invalidTextFieldColor = UIColor.red

    // MARK: - Splash
    @objc public var splashBackgroundColor = UIColor.white

    // MARK: - Checkout Cells title
    @objc public var nativeCheckoutFirstLineFont = UIFont.boldSystemFont(ofSize: 17)
    @objc public var nativeCheckoutFirstLineColor = UIColor.black
    @objc public var nativeCheckoutSecondLineFont = UIFont.systemFont(ofSize: 14)
    @objc public var nativeCheckoutSecondLineColor = UIColor.lightGray
    @objc public var nativeCheckoutThirdLineLabelLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var nativeCheckoutThirdLineLabelLabelColor = UIColor.lightGray
    @objc public var nativeCheckoutStepNumberTextColor = UIColor.gray
    @objc public var nativeCheckoutStepNumberTextFont = UIFont.boldSystemFont(ofSize: 18)

    // MARK: - Checkout Order Summary
    @objc public var checkoutOrderSummeryTotalLabelFont = UIFont.boldSystemFont(ofSize: 18)
    @objc public var checkoutOrderSummeryTotalDetailLabelFont = UIFont.boldSystemFont(ofSize: 18)
    @objc public var checkoutOrderSummeryTotalDetailLabelColor = UIColor.black
    @objc public var checkoutOrderSummeryDiscountLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var checkoutOrderSummeryDiscountLabelColor = UIColor.darkGray
    @objc public var checkoutOrderSummeryDiscountDetailLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var checkoutOrderSummeryDiscountDetailLabelColor = UIColor.darkGray
    @objc public var checkoutOrderSummeryBagItemTitleLabelFont = UIFont.systemFont(ofSize: 13)
    @objc public var checkoutOrderSummeryBagItemPriceLabelFont = UIFont.systemFont(ofSize: 13)
    @objc public var checkoutOrderSummeryDeliveryTitleLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var checkoutOrderSummeryDeliveryPriceLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var checkoutOrderSummarySameAddressTitleFont = UIFont.systemFont(ofSize: 15)
    @objc public var checkoutOrderSummarySameAddressTitleTextColor = UIColor.black
    @objc public var checkoutOrderSummeryDeliveryTitleLabelColor = UIColor.black
    @objc public var checkoutOrderSummeryDeliveryTitleInvalidLabelColor = UIColor.gray
    @objc public var checkoutOrderSummeryDeliveryPriceLabelColor = UIColor.black
    @objc public var checkoutOrderSummaryPaymentOptionFont = UIFont.systemFont(ofSize: 14)
    @objc public var checkoutOrderSummaryPaymentOptionLabelColor = UIColor.black

    @objc public var checkoutOrderSummaryTnCLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var checkoutOrderSummaryTnCLabelTextColor = UIColor.black

    @objc public var checkoutOrderSummaryCellSubTitleFont = UIFont.systemFont(ofSize: 13)
    @objc public var checkoutOrderSummaryCellSubTitleTextColor = UIColor.lightGray

    @objc public var chooseSortTypeLabelBackgroundColor = UIColor.white

    @objc public var checkoutOrderSummaryCellContentFont = UIFont.systemFont(ofSize: 14)
    @objc public var checkoutOrderSummaryCellContentTextColor = UIColor.black

    @objc public var checkoutOrderSummaryTableViewBackgroundColor = UIColor.groupTableViewBackground

    @objc public var checkoutOrderSummaryCellPriceFont = UIFont.systemFont(ofSize: 14)
    @objc public var checkoutDeliveryOptionsTitleFont = UIFont.systemFont(ofSize: 17)
    @objc public var checkoutDeliveryOptionsPriceFont = UIFont.systemFont(ofSize: 16)
    @objc public var checkoutDeliveryOptionsSubPriceFont = UIFont.systemFont(ofSize: 12)
    @objc public var checkoutDeliveryOptionsAccessoryTypeColor = UIColor.black

    // Total
    @objc public var checkoutOrderConfirmationTotalTitleLabelFont = UIFont.systemFont(ofSize: 22)
    @objc public var checkoutOrderConfirmationTotalPriceLabelFont = UIFont.systemFont(ofSize: 22)
    @objc public var checkoutOrderconfirmationOrderDateLabelFont = UIFont.systemFont(ofSize: 17)
    @objc public var checkoutAddressSelectionCellTitleFont = UIFont.boldSystemFont(ofSize: 16)
    
    @objc public var checkoutOrderSummeryCellTextColor = UIColor.black
    @objc public var checkoutOrderSummeryCellDetailTextColor = UIColor.black

    @objc public var solidLineColor = UIColor.lightGray

    // MARK: - Add Payment method
    @objc public var addPaymentMethodCardDetailTitleFont = UIFont.boldSystemFont(ofSize: 15)
    @objc public var addPaymentMethodCardInfoTextFieldFont = UIFont.systemFont(ofSize: 18)

    @objc public var addPaymentMethodSaveButtonFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var addPaymentMethodSaveButtonNormalColor = UIColor.white
    @objc public var addPaymentMethodSaveButtonDisabledColor = UIColor.lightGray
    @objc public var securePaymentInfoLabelColor = UIColor.black
    @objc public var securePaymentInfoLabelFont = UIFont.systemFont(ofSize: 10)

    @objc public var addressTypeFont = UIFont.boldSystemFont(ofSize: 25)
    @objc public var addressTypeColour = UIColor.black

    @objc public var myProfileEmptyAddressBookBigMessageFont = UIFont.boldSystemFont(ofSize: 25)
    @objc public var myProfileEmptyAddressBookSmallMessageFont = UIFont.systemFont(ofSize: 13)

    @objc public var myProfileAddressBookNameTextFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var myProfileAddressBookTypeTextFont = UIFont.systemFont(ofSize: 13.0)
    @objc public var myProfileAddressBookDetailsTextFont = UIFont.systemFont(ofSize: 15.0)

    // MARK: - Tinder / Swipe to hype
    @objc public var tinderProductTitleLabelFont = UIFont.systemFont(ofSize: 18)
    @objc public var tinderSwipeRightFont = UIFont.systemFont(ofSize: 24)
    @objc public var tinderSwipeLeftFont = UIFont.systemFont(ofSize: 24)

    @objc public var unavailableLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var unavailableLabelTextColor = UIColor.red

    @objc public var bagDeliveryInfoLabelFont = UIFont.systemFont(ofSize: 14)

    // Country selection
    @objc public var countrySelectionCellTextFont = UIFont.systemFont(ofSize: 17)
    @objc public var countrySelectionCellTextColor = UIColor.black
    @objc public var countrySelectionCurrentCountryLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var countrySelectionCurrentCountryLabelColor = UIColor.lightGray

    // Bordered bar button
    @objc public var borderedBarButtonFont = UIFont.systemFont(ofSize: 15)

    // Onboarding
    @objc public var onboardingTiteBlockFont = UIFont.boldSystemFont(ofSize: 19)
    @objc public var onboardingTiteBlockColor = UIColor.black

    @objc public var onboardingDescriptionBlockFont = UIFont.systemFont(ofSize: 14)
    @objc public var onboardingDescriptionBlockColor = UIColor.black

    @objc public var onboardingLinkBlockFont = UIFont.boldSystemFont(ofSize: 19)
    @objc public var onboardingLinkBlockColor = UIColor.black

    @objc public var onboardingCurrentPageIndicatorColor = UIColor.black
    @objc public var onboardingPageIndicatorColor = UIColor.white

    // MARK: - Voucher
    @objc public var vouchersCategoryElementCellTitleColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1.0)
    @objc public var vouchersCategoryElementCellCountLabelColor = UIColor(red: 100/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1.0)
    @objc public var vouchersCategoryExpiresSoonTextColor = UIColor(red: 192.0/255.0, green: 49.0/255.0, blue: 69.0/255.0, alpha: 1.0)
    @objc public var vouchersCategorySectionHeaderCellBackgroundColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1.0)

    // MARK: - StoreFinderMap

    @objc public var storeFinderPinColor = UIColor.purple

    // MARK: - Force update
    @objc public var forceUpdateButtonBackgroundColor = UIColor.white
    @objc public var forceUpdateButtonFont = UIFont.systemFont(ofSize: 14)
    @objc public var forceUpdateButtonColor = UIColor.black

    @objc public var forceUpdateLabelFont = UIFont.systemFont(ofSize: 14)
    @objc public var forceUpdateLabelColor = UIColor.black

    // MARK: - App Story
    @objc public var appStoryTitleFont = UIFont.systemFont(ofSize: 14)
    @objc public var appStoryNewStoryLabelFont = UIFont.systemFont(ofSize: 10)
    @objc public var appStoryNewStoryLabelTextColor = UIColor.white
    @objc public var appStoryNewStoryLabelColor = UIColor.black.withAlphaComponent(0.5)
    @objc public var appStoryBottomCTALabelFont = UIFont.systemFont(ofSize: 17)
    @objc public var appStoryBottomCTALabelTextColor = UIColor.white
    
    @objc public var appStoryProductListTitleFont = UIFont.systemFont(ofSize: 15)
    @objc public var appStoryProductListTitleTextColor = UIColor.black
    @objc public var appStoryProductListCancelButtonFont = UIFont.systemFont(ofSize: 15)
    @objc public var appStoryProductListCancelButtonTextColor = UIColor(red: 0, green: 125.0/255.0, blue: 237.0/255.0, alpha: 1.0)
}
