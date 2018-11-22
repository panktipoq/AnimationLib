//
//  AppLocalization.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 07/06/2016.
//
//

import Foundation
import PoqModuling
import PoqUtilities
import UIKit

public final class AppLocalization: NSObject, AppConfiguration {

    public static var sharedInstance = AppLocalization()

    static func resetSharedInstance() {
        sharedInstance = AppLocalization()
    }
    
    public let configurationType: PoqSettingsType = .localization
    
    @objc public var popOverNavigationTitle_iPad = "SHOP".localizedPoqString
    
    // Tab bar title
    @objc public var tabTitle1 = "HOME".localizedPoqString
    @objc public var tabTitle2 = "SHOP".localizedPoqString
    @objc public var tabTitle3 = "BAG".localizedPoqString
    @objc public var tabTitle4 = "WISHLIST".localizedPoqString
    @objc public var tabTitle5 = "MORE".localizedPoqString
    
    @objc public var dismissButtonText = "Skip".localizedPoqString
    
    // Sizes sectino on PDP
    @objc public var pdpSizesTitleLabelText = "SIZES".localizedPoqString
    @objc public var pdpSizesOneSizeText = "ONE_SIZE".localizedPoqString
    
    // PDP
    @objc public var sizeGuidePageOnPDPTitle: String = "SIZE_GUIDE".localizedPoqString
    @objc public var careDetailsOnPDPTitle: String = "Care Details".localizedPoqString
    @objc public var deliveryPageOnPDPTitle = "Delivery".localizedPoqString
    @objc public var productDescriptionOnPDPTitle = "Description".localizedPoqString
    
    // Checkout navigation
    @objc public var checkoutButtonText: String = "CHECKOUT_SECURELY".localizedPoqString
    @objc public var checkoutNavigationTitle: String = "SECURE_CHECKOUT".localizedPoqString
    
    @objc public var checkoutOrderConfirmationTitle: String = ""
    
    @objc public var groupedPriceFormat: String = "From".localizedPoqString
    
    // PDP
    @objc public var pdpProductDescriptionHeadline: String = ""
    
    // PLP
    @objc public var plpSortByLabelText: String = "SORT_BY".localizedPoqString
    @objc public var plpFeaturedText: String = "FEATURED".localizedPoqString
    @objc public var plpNewestText: String = "NEWEST".localizedPoqString
    @objc public var plpRatingText: String = "RATING".localizedPoqString
    @objc public var plpPriceDownText: String = "PRICE_DOWN".localizedPoqString
    @objc public var plpSellerText: String = "SELLER".localizedPoqString
    @objc public var plpPriceUpText: String = "PRICE_UP".localizedPoqString
    @objc public var plpNoItemsText: String = "NO_RESULTS_FOUND".localizedPoqString
    @objc public var plpTryAgainText: String = "PLEASE_TRY_AGAIN".localizedPoqString
    @objc public var plpMoreColorText: String = "MORE_COLOURS_TEXT".localizedPoqString
    
    // Product Peek & Pop
    @objc public var peekQuickActionViewDetails: String = "View Details".localizedPoqString
    @objc public var peekQuickActionWishlist: String = "Add to Wishlist".localizedPoqString
    @objc public var peekQuickActionShare: String = "Share".localizedPoqString
    
    // GPLP
    
    @objc public var groupedPLPParentProductTitle: String = "gPLP_PARENT_PRODUCT_TITLE".localizedPoqString
    
    // MARK: - PLP Filters
    @objc public var plpFiltersButtonText: String = "FILTERS".localizedPoqString
    @objc public var filtersNavigationTitle: String = "FILTER_RESULTS".localizedPoqString
    @objc public var filterTypeColourTitle: String = "FILTER_COLOUR".localizedPoqString
    @objc public var filterTypeSizeTitle: String = "FILTER_SIZE".localizedPoqString
    @objc public var filterTypeBrandTitle: String = "FILTER_BRAND".localizedPoqString
    @objc public var filterTypeStyleTitle: String = "FILTER_STYLE".localizedPoqString
    @objc public var filterTypeCategoryTitle: String = "FILTER_CATEGORY".localizedPoqString
    @objc public var filterClearAllTitle: String = "CLEAR_ALL_FILTERS".localizedPoqString
    @objc public var filterClearTitle: String = "CLEAR_FILTERS".localizedPoqString
    @objc public var filterCancelTitle: String = "CANCEL".localizedPoqString
    
    @objc public var filterViewDoneButtonText: String = "DONE".localizedPoqString
    @objc public var filterViewCancelButtonText: String = "CANCEL".localizedPoqString
    
    @objc public var productListFiltersDoneButtonText: String = "DONE".localizedPoqString
    
    @objc public var filterSelectionClearAlertTitle: String = "CLEAR_FILTERS".localizedPoqString
    @objc public var filterSelectionClearAlertMessage: String = "CLEAR_CURRENT_MESSAGE".localizedPoqString
    @objc public var filterSelectionClearCancel: String = "CANCEL".localizedPoqString
    @objc public var filterSelectionClearConfirm: String = "CLEAR".localizedPoqString
    @objc public var filterResetDialogTitle: String = "CLEAR_SELECTED_FILTERS".localizedPoqString
    @objc public var filterResetCurrentSelectionTitle: String = "CLEAR_CURRENT_VIEW".localizedPoqString
    @objc public var filterResetAllSelectionTitle: String = "CLEAR_ALL".localizedPoqString
    
    @objc public var addToBagButtonText: String = "ADD_TO_BAG".localizedPoqString
    @objc public var addToBagConfirmationButtonText: String = "ADDED_TO_BAG".localizedPoqString
    @objc public var goToBagButtonText: String = "GO_TO_BAG".localizedPoqString
    @objc public var descriptionText: String  = "Description".localizedPoqString
    @objc public var brandedDescriptionText: String  = "DESCRIPTION".localizedPoqString
    @objc public var deliveryText: String  = "Delivery".localizedPoqString
    @objc public var brandedDeliveryText: String  = "DELIVERY".localizedPoqString
    @objc public var returnsText: String  = "Returns".localizedPoqString
    @objc public var brandedReturnsText: String  = "RETURNS".localizedPoqString
	@objc public var brandedSizeGuideText: String  = "Branded size guide".localizedPoqString
	@objc public var sizeGuideText: String  =  "Size guide".localizedPoqString
	@objc public var pdpSoldOutMessage: String = "PDP_Sold_Out".localizedPoqString
    
    @objc public var tinderFirstTimeLoadSkipButtonText: String = "ok, I got this".localizedPoqString
    
    // Wishlist
    @objc public var wishListCountMultipleText: String = "NUMBER_ITEMS".localizedPoqString
    @objc public var wishListCountSingleText: String = "NUMBER_ITEM".localizedPoqString
    @objc public var wishListNoItemsText: String = "WISH_NO_ITEMS".localizedPoqString
    @objc public var wishListNoItemsInstructionsText: String = "WISH_NO_ITEMS_INSTRUCTIONS".localizedPoqString
    
    @objc public var wishListAddToBagText: String = "ADD_TO_BAG".localizedPoqString
    @objc public var wishListClearAllText: String = "CLEAR_ALL".localizedPoqString
    @objc public var wishlistNavigationBarItemText: String = "EDIT".localizedPoqString
    
    // MARK: - Bag
    @objc public var bagSwipeToDeleteSuccessMessage: String = "BAG_SWIPE_DELETE_SUCCESS".localizedPoqString
    @objc public var bagSwipeToDeleteDefaultErrorMessage: String = "BAG_SWIPE_DELETE_FAIL".localizedPoqString
    @objc public var bagSwipeToDeleteNetworkErrorMessage: String = "BAG_SWIPE_DELETE_DEFAULT_FAIL".localizedPoqString
    @objc public var bagTotalText: String = "Total".localizedPoqString
    @objc public var bagRemoveItemsText: String = "BAG_REMOVE_ITEMS %@".localizedPoqString
    @objc public var bagNoItemsText: String = "BAG_NO_ITEMS".localizedPoqString
    @objc public var bagNoItemsInstructionsText: String = "BAG_NO_ITEMS_INSTRUCTIONS %@".localizedPoqString
    @objc public var bagOutOfStockMessage: String = "BAG_OUT_OF_STOCK".localizedPoqString
    @objc public var bagUnavailableItemMessage: String = "BAG_ITEM_UNAVAILABLE".localizedPoqString
    @objc public var bagProductInfoNotAvailableMessage: String = "BAG_ITEM_INFO_UNAVAILABLE".localizedPoqString
    
    // BAG: Hof only
    @objc public var bagCountSingleText: String = "NUMBER_ITEM".localizedPoqString
    @objc public var bagCountMultipleText: String = "NUMBER_ITEMS".localizedPoqString
    @objc public var bagNavigationBarItemText: String = "EDIT".localizedPoqString
    
    // MARK: - bag cell message
    @objc public var buyAndCollect: String = "BUY_COLLECT".localizedPoqString
    @objc public var ukAndIrelandDelivery: String = "HOME_DELIVERY".localizedPoqString
    @objc public var internationalDelivery: String = "INTERNATIONAL_DELIVERY".localizedPoqString
    
    @objc public var searchClearHistoryButtonText: String = "CLEAR_HISTORY".localizedPoqString
    @objc public var searchPlaceholderText: String = "SEARCH_KEYWORD".localizedPoqString
    @objc public var searchHistoryText: String = "YOUR_SEARCH_HISTORY".localizedPoqString
    @objc public var noSearchHistoryText: String = "NO_SEARCH_HISTORY".localizedPoqString
    @objc public var noSearchResultsText: String = "NO_SEARCH_RESULTS_FOUND".localizedPoqString
    @objc public var noSearchResultsFormat: String = "NO_SEARCH_RESULTS_FOUND_FORMAT".localizedPoqString
    @objc public var searchResultHeaderText: String = "SEARCH_RESULTS".localizedPoqString
    @objc public var searchTitleFormat = "Search: %@"
    @objc public var searchNoItemsInstructionsText: String = ""
    @objc public var searchHistoryInstructionsText: String = ""
    
    // MARK: - bag Pick Your Gift
    @objc public var bagPickYourGiftNavigationBarTitle: String = "PICK_YOUR_GIFT".localizedPoqString
    @objc public var bagPickYourGiftNotWantGiftText: String = "DO_NOT_WANT_FREE_GIFT".localizedPoqString
    @objc public var bagPickYourGiftSelectGiftText: String = "SELECT_GIFT".localizedPoqString
    @objc public var bagPickYourGiftNextButtonTitle: String = "NEXT".localizedPoqString
    @objc public var bagPickYourGiftAddToBagButtonTitle: String = "ADD_TO_BAG".localizedPoqString
    
    // MARK: - STORES
    @objc public var lengthUnit: String = "MILES".localizedPoqString
    @objc public var favoriteStoreText: String = "FAVOURITE_STORE".localizedPoqString
    @objc public var callStoreText: String = "CALL_THIS_STORE".localizedPoqString
    @objc public var getNumberForCallStore: String = "GET_NUMBER".localizedPoqString
    @objc public var directionStoreText: String = "STORE_DIRECTIONS".localizedPoqString
    @objc public var todaysOpeningHours: String = "OPEN_TODAY".localizedPoqString
    @objc public var storeSortNearbyText: String = "NEARBY".localizedPoqString
    @objc public var storeSortAToZText: String = "CITY".localizedPoqString
    @objc public var storeSortMapText: String = "MAP".localizedPoqString
    @objc public var availableAtStore: String = "AVAILABLE_AT_OUR_STORE".localizedPoqString
    @objc public var sizeAvailableAtStore: String = "SIZE_AVAILABLE_AT_STORE".localizedPoqString
    @objc public var unavailableAtStore: String = "UNAVAILABLE_AT_STORE".localizedPoqString
    @objc public var sizeUnavailableAtStore: String = "SIZE_UNAVAILABLE_STORE_SELECT_STORE".localizedPoqString
    @objc public var checkInStoreAvailability: String = "CHECK_IN_STORE_AVAILABILITY_OFF".localizedPoqString
    @objc public var storeInformationUnavailable: String = "IN_STORE_AVAILABILITY_OFF".localizedPoqString
    
    @objc public var storeOpeningHoursText: String = "OPENING_HOURS".localizedPoqString
    @objc public var storeOpeningHoursFormat: String = "%@ - %@"
    @objc public var mondayText: String = "MONDAY".localizedPoqString
    @objc public var tuesdayText: String = "TUESDAY".localizedPoqString
    @objc public var wednesdayText: String = "WEDNESDAY".localizedPoqString
    @objc public var thursdayText: String = "THURSDAY".localizedPoqString
    @objc public var fridayText: String = "FRIDAY".localizedPoqString
    @objc public var saturdayText: String = "SATURDAY".localizedPoqString
    @objc public var sundayText: String = "SUNDAY".localizedPoqString
    
    @objc public var storesByPostCodeNoResultsLabel: String = "SORRY_WE_CANT_FIND_ANY_MATCHING_STORES".localizedPoqString
    @objc public var storeDetailsNavigationBarTitle: String = "STORE_DETAILS".localizedPoqString
    @objc public var storeByPostCodeNavigationBarTitle: String = "FIND_A_STORE".localizedPoqString
    // MARK: - MY PROFILE Section headers
    // My profile section titles
    @objc public var myProfileRewardCardDetailTitle: String = "SHOW_AT_THE_TILL_POINTS".localizedPoqString
    @objc public var myProfileFavoriteStoreTitle: String = "MY_FAVOURITE_STORE".localizedPoqString
    @objc public var myProfileFavoriteSizeTitle: String = "SAVED_SIZES".localizedPoqString
    @objc public var myProfileHistoryTitle: String = "HISTORY".localizedPoqString
    @objc public var myProfileRecognitionActionButtonTitle: String = "DISCOVER_MORE_ABOUT_RECOGNITION".localizedPoqString
    @objc public var myProfileLoginActionButtonTitle: String = "UNLOCK_FEATURES".localizedPoqString
    @objc public var myProfileSignupActionButtonTitle: String = "IM_NEW".localizedPoqString
    @objc public var myProfileLogoutActionButtonTitle: String = "LOGOUT".localizedPoqString
    @objc public var myProfileBackToTopActionButtonTitle: String = "BACK_TO_TOP".localizedPoqString
    @objc public var myProfileWelcomeMessage: String = "USER_WELCOME_MESSAGE".localizedPoqString
    // My profile size links
    @objc public var myProfileSizeManLinkTitle: String = "MAN".localizedPoqString
    @objc public var myProfileSizeWomanLinkTitle: String = "WOMAN".localizedPoqString
    @objc public var myProfileSizeKidsLinkTitle: String = "KIDS".localizedPoqString
    
    // My profile other links
    @objc public var myProfileRecentlyViewLinkTitle: String = "RECENTLY_VIEWED_ITEMS".localizedPoqString
    @objc public var myProfileOrderHistoryLinkTitle: String = "YOUR_ORDER_HISTORY".localizedPoqString
    
    @objc public var welcomeText: String = "WELCOME".localizedPoqString
    @objc public var welcometoText: String = "WELCOME_TO_YOUR".localizedPoqString
    @objc public var companyNameText: String = "House of Fraser".localizedPoqString
    @objc public var birthdayPointsText: String = "BIRTHDAY_DOUBLE_POINTS".localizedPoqString
    @objc public var birthdayUpdatedText: String = "MANAGE_YOUR_DETAILS".localizedPoqString
    @objc public var keepScrollingText: String = "KEEP_SCROLLING_DOWN".localizedPoqString
    
    @objc public var myProfileCompanyTitle: String = "your account".localizedPoqString
    @objc public var myProfileLoyaltyCardTitle: String = "COLLECT_POINTS".localizedPoqString
    
    @objc public var editMyProfileSaveButtonText: String = "Save".localizedPoqString
    
    @objc public var otherFeaturesTitle: String = "OTHER_GREAT_FEATURES".localizedPoqString
    @objc public var myProfileAddFavouriteStoreTitle: String = "ADD_YOUR_FAVOURITE_STORE".localizedPoqString
    @objc public var myProfileFavouriteStoreStockAvailabilityTitle: String = "VIEW_STOCK_AVAILABILITY_OPENING_TIMES".localizedPoqString
    @objc public var myProfileStoreOpeningHoursTitle: String = ""
    @objc public var myProfileStockAvailabilityTitle: String = ""
    @objc public var myProfileRewardCardInfoTitle: String = "MAKE_MONEY_WHILE_YOU_SHOP".localizedPoqString
    @objc public var myProfileStoreSetFavoriteText: String = "SET_FAVOURITE".localizedPoqString
    @objc public var myProfileStoreSetAsFavoriteStoreTitle: String = "SET_AS_FAVORITE_STORE".localizedPoqString
    
    @objc public var myProfileStoreChangeFavoriteText: String = "CHANGE_FAVOURITE".localizedPoqString
    @objc public var myProfileRewardCardInfoDescription: String = "START_COLLECTING_POINTS".localizedPoqString
    @objc public var myProfileCollectPointsText: String = "COLLECT_RECOGNITION_POINTS".localizedPoqString
    @objc public var myProfileNoPointsText: String = "DATA_CORRECT_YESTERDAY".localizedPoqString
    @objc public var myProfileRewardDue: String = "REWARD_DUE_TO_EXPIRE_ON".localizedPoqString
    @objc public var myProfilePhysicalCardText: String = "GOT_REWARD_CARD".localizedPoqString
    @objc public var myProfileLinkCardText: String = "LINK_PLASTIC_REWARD_CARD".localizedPoqString
    @objc public var myProfileGoToShoppingText: String = "GO_SHOPPING_NOW".localizedPoqString
    
    @objc public var myProfileMastercardRecognitionText: String = "BE_YOU_NO_MATTER".localizedPoqString
    @objc public var myProfileMastercardRecognitionDescription: String = "ACCESS_TO_ALL_FEATURES".localizedPoqString
    @objc public var myProfileOrderHistoryNavigationTitleText: String = "Your order history".localizedPoqString
    
    // MARK: - My sizes
    // Personalised
    @objc public var myProfileMySizesMe: String = "MY_SIZES_MY_MEASUREMENTS".localizedPoqString
    @objc public var myProfileMySizesHis: String = "MY_SIZES_HIS_MEASUREMENTS".localizedPoqString
    @objc public var myProfileMySizesHer: String = "MY_SIZES_HER_MEASUREMENTS".localizedPoqString
    @objc public var myProfileMySizesLittleone: String = "MY_SIZES_LITTLE_ONE_MEASUREMENTS".localizedPoqString
    
    // MARK: - Generic
    @objc public var myProfileMySizesMan: String = "MY_SIZES_MANS_MEASUREMENTS".localizedPoqString
    @objc public var myProfileMySizesWoman: String = "MY_SIZES_WOMAN_MEASUREMENTS".localizedPoqString
    @objc public var myProfileMySizesKids: String = "MY_SIZES_KIDS_MEASUREMENTS".localizedPoqString
    
    // MARK: - SIGN UP
    @objc public var signupTitle: String = "IM_NEW".localizedPoqString
    @objc public var existingMastercardText: String = "MASTERCARD_OPTION".localizedPoqString
    @objc public var optOutTitle: String = "OPT_OUT_OPTION".localizedPoqString
    
    @objc public var firstNameText: String = "FIRSTNAME".localizedPoqString
    @objc public var lastNameText: String = "LASTNAME".localizedPoqString
    @objc public var emailText: String = "EMAIL".localizedPoqString
    @objc public var passwordText: String = "PASSWORD".localizedPoqString
    @objc public var invalidPasswordText: String = "ENTER_VALID_PASSWORD".localizedPoqString
    @objc public var privacyPolicy: String = "PRIVACY_POLICY".localizedPoqString
    
    @objc public var signinLandingPageTitle: String = "LANDING_TITLE".localizedPoqString
    @objc public var signinLandingPageSignInButtonTitle: String = "LANDING_SIGNIN".localizedPoqString
    @objc public var signinLandingPageRegisterButtonTitle: String = "LANDING_REGISTER".localizedPoqString
    
    // MARK: - SIGN IN
    @objc public var signinTitle: String = "SIGN_IN".localizedPoqString
    @objc public var signIntoTextWithNewline: String = "SIGN_INTO".localizedPoqString
    @objc public var signIntoTextWithoutNewline: String = "SIGN_IN_TO".localizedPoqString
    
    @objc public var loginBigTitle: String = "YOUR_ACCOUNT".localizedPoqString
    
    @objc public var loginNavigationTitle: String = "SIGN_IN".localizedPoqString
    @objc public var loginSubmitButtonTitle: String = "SIGN_IN".localizedPoqString
    @objc public var logoutButtonTitle: String = "LOGOUT".localizedPoqString
    
    // MARK: - Sign Up
    @objc public var signUpNavigationTitle: String = "IM_NEW".localizedPoqString
    @objc public var signUpFirstNameText: String = "FIRSTNAME".localizedPoqString
    @objc public var signUpLastNameText: String = "LASTNAME".localizedPoqString
    @objc public var signUpEmailText: String = "EMAIL_TEXT".localizedPoqString
    @objc public var signUpShowText: String = "SHOW".localizedPoqString
    @objc public var signUpHideText: String = "HIDE".localizedPoqString
    @objc public var signUpPasswordText: String = "PASSWORD_TEXT".localizedPoqString
    @objc public var signUpGenderText: String = "GENDER".localizedPoqString
    @objc public var signUpPromotionText: String = "SEND_ME_PROMOTIONS".localizedPoqString
    @objc public var signUpMasterCardText: String = "MASTERCARD_OPTION".localizedPoqString
    @objc public var signUpDataSharingText: String = "DATA_SHARING_OPTION".localizedPoqString
    @objc public var userNameAlreadyInUseText: String = "USERNAME_ALREADY_USE".localizedPoqString
    @objc public var signUpPhonePlaceHolderText: String = "PHONE_NUMBER".localizedPoqString
    
    // MARK: - EDIT MY PROFILE
    
    @objc public var editMyProfileTitle: String = "UPDATE_YOUR_DETAILS".localizedPoqString
    @objc public var editMyProfileBirthdayPointsText: String = "MANAGE_YOUR_DETAILS_BIRTHDAY".localizedPoqString
    @objc public var editMyProfileDOBText: String = "DOB".localizedPoqString
    @objc public var editMyProfileMangeButtonText: String = "MANAGE_MY_ADDRESS".localizedPoqString
    @objc public var editMyProfileRightTitleButtonText: String = "DONE".localizedPoqString
    @objc public var editMyProfileSaveButtonTitle: String = "Save".localizedPoqString
    @objc public var editMyAccountTitle: String = "MY_ACCOUNT".localizedPoqString
    @objc public var expressCheckoutDescription: String = "EXPRESS_CHECKOUT_DESCRIPTION".localizedPoqString
    
    // MARK: - ACCOUNT Password
    @objc public var changePasswordTitle: String = "CHANGE_PASSWORD".localizedPoqString
    @objc public var changePasswordSaveTitle: String = "SAVE".localizedPoqString
    
    @objc public var forgetPasswordTitle: String = "FORGET_PASSWORD".localizedPoqString
    @objc public var forgetPasswordSaveTitle: String = "SAVE".localizedPoqString
    
    // MARK: - Caroussel Product Items
    
    @objc public var productCarousselTitleText: String = "RECENTLY_VIEWED_ITEMS".localizedPoqString
    @objc public var productCarousselRightButtonText: String = "VIEW_ALL".localizedPoqString
    
    // MARK: - RECENTLY VIEWED ITEMS
    @objc public var recentlyViewedText: String = "NO_RECENTLY_VIEWED_ITEMS".localizedPoqString
    @objc public var recentlyViewedTitleText: String = "RECENTLY_VIEWED_ITEMS".localizedPoqString
    @objc public var clearRecentlyViewedTitleText: String = "CLEAR_RECENTLY_VIEWED_ITEMS".localizedPoqString
    @objc public var clearRecentlyViewedContentText: String = "CLEAR_CONFIRMATTION".localizedPoqString
    @objc public var clearOptionText: String = "CLEAR".localizedPoqString
    @objc public var viewAllRecentlyViewed: String = "VIEW_ALL".localizedPoqString
    @objc public var recentlyViewControllerNavigationTitle = "PLP_REVIEWED_PAGE_NAVIGATION_TITLE".localizedPoqString
    @objc public var recentlyViewControllerPromptAlertTitle = "DO_YOU_WANT_TO_CLEAR_VIEWED_PRODUCT_TITLE".localizedPoqString
  
    // MARK: - VISUAL SEARCH
    @objc public var visualSearchResultsViewControllerNavigationTitle = "VISUAL_SEARCH_RESULTS_NAVIGATION_TITLE".localizedPoqString
    @objc public var visualSearchNoResultsText = "VISUAL_SEARCH_NO_RESULTS_TEXT".localizedPoqString

    // MARK: - SCAN
    @objc public var scanNavigationTitle: String = "SCAN".localizedPoqString
    @objc public var scanManualEnterText: String = "ENTER_CODE_MANUALLY".localizedPoqString
    @objc public var scanManualEnterPlaceholder: String = "ENTER_THE_CODE_HERE".localizedPoqString
    @objc public var submitButtonText: String = "SUBMIT".localizedPoqString
    @objc public var alignBarcodeText: String = "ALIGN_BARCODE".localizedPoqString
    @objc public var barcodePositionText: String = "ENSURE_BARCODE".localizedPoqString
    @objc public var scanNoItemsText: String = "NO_RESULTS_FOUND".localizedPoqString
    @objc public var scanTryAgainText: String = "PLEASE_TRY_AGAIN".localizedPoqString
    @objc public var scanEnterCodeText: String = "Enter_code".localizedPoqString
    @objc public var scanCodeText: String = "Code".localizedPoqString
    @objc public var scanQRCodeDetectedTitle: String = "QR_Code_Detected".localizedPoqString
    
    // MARK: - FULL SCREEN BARCODE
    @objc public var fullScreenBarcodeNavigationTitle: String = "CUSTOMER_RECOGNITION_NUMBER".localizedPoqString
    
    // MARK: - STORE STOCK
    @objc public var selectStoreNavigationTitle: String = "IN_STORE_SELECT_STORE".localizedPoqString
    @objc public var productAvailabilityNavigationTitle: String = "IN_STORE_AVAILABILITY".localizedPoqString
    @objc public var storeAvailabilityOff: String = "IN_STORE_AVAILABILITY_OFF".localizedPoqString
    @objc public var productInStoreAvailabilityTitle: String = "IN_STORE_AVAILABILITY_TITLE".localizedPoqString
    @objc public var inStoreAvailabilityDescriptionText: String = "IN_STORE_AVAILABILITY_DESCRIPTION".localizedPoqString
    @objc public var inStoreStoreText: String = "IN_STORE_STORE".localizedPoqString
    @objc public var inStoreSelectStoreText: String = "IN_STORE_SELECT_STORE".localizedPoqString
    @objc public var inStoreSizeText: String = "IN_STORE_SIZE".localizedPoqString
    @objc public var inStoreSelectSizeText: String = "IN_STORE_SELECT_SIZE".localizedPoqString
    @objc public var pdpSelectSizeHeaderText: String = "SELECT_SIZE".localizedPoqString
    @objc public var pdpSelectSizeLowStockText: String = "LOW_STOCK".localizedPoqString
    @objc public var pdpSelectColorHeaderText = "SELECT_COLOR".localizedPoqString
    
    // MARK: - My sizes
    @objc public var mySizesMySizesNavigationTitle: String = "MY_SIZES_MY_MEASUREMENTS".localizedPoqString
    @objc public var mySizesHisSizesNavigationTitle: String = "MY_SIZES_HIS_MEASUREMENTS".localizedPoqString
    @objc public var mySizesHerSizesNavigationTitle: String = "MY_SIZES_HER_MEASUREMENTS".localizedPoqString
    @objc public var mySizesLittleOneSizesNavigationTitle: String = "MY_SIZES_LITTLE_ONE_MEASUREMENTS".localizedPoqString
    @objc public var mySizesManSizesNavigationTitle: String = "MY_SIZES_MANS_MEASUREMENTS".localizedPoqString
    @objc public var mySizesWomanSizesNavigationTitle: String = "MY_SIZES_WOMAN_MEASUREMENTS".localizedPoqString
    @objc public var mySizesKidsSizesNavigationTitle: String = "MY_SIZES_KIDS_MEASUREMENTS".localizedPoqString
    @objc public var mySizesBannerTitle: String = "MY_SIZES_ENTER_IN_YOUR_MEASUREMENTS".localizedPoqString
    @objc public var mySizesTopsTitle: String = "MY_SIZES_TOPS".localizedPoqString
    @objc public var mySizesBottomsTitle: String = "MY_SIZES_BOTTOMS".localizedPoqString
    @objc public var mySizesShoesTitle: String = "MY_SIZES_SHOES".localizedPoqString
    @objc public var mySizesBraTitle: String = "MY_SIZES_BRA".localizedPoqString
    @objc public var mySizesBraBackTitle: String = "MY_SIZES_BRA_BACK".localizedPoqString
    @objc public var mySizesBraCupTitle: String = "MY_SIZES_BRA_CUP".localizedPoqString
    @objc public var mySizesNoSizeSelected: String = "MY_SIZES_NO_SIZE_SELECTED".localizedPoqString
    
    // MARK: - Rewards
    @objc public var recognitionAccountText: String = "YOUR_RECOGNITION_DASHBOARD".localizedPoqString
    @objc public var excludesCardsText: String = "EXCLUDES_RECOGNITION_CARD".localizedPoqString
    @objc public var youHaveText: String = "YOU_HAVE".localizedPoqString
    @objc public var pointsText: String = "POINTS".localizedPoqString
    @objc public var yourRewardText: String = "YOUR_REWARD".localizedPoqString
    @objc public var toSpendText: String = "TO_SPEND".localizedPoqString
    
    // MARK: - Order detail
    @objc public var orderNaviTitle: String = "YOUR_ORDER_SUMMARY".localizedPoqString
    @objc public var orderNumberText: String = "ORDER_NUMBER".localizedPoqString
    @objc public var orderDateText: String = "ORDER_DATE".localizedPoqString
    @objc public var orderTotalText: String = "ORDER_TOTAL".localizedPoqString
    @objc public var orderVATText: String = "VAT".localizedPoqString
    @objc public var orderHistoryTitleText: String = "ORDER_HISTORY_TITLE".localizedPoqString
    @objc public var purchasedText: String = "PURCHASED".localizedPoqString
    @objc public var deliveryOptionText: String = "DELIVERY_OPTION".localizedPoqString
    @objc public var paymentMethodText: String = "PAYMENT_METHOD".localizedPoqString
    @objc public var cardAddressBillingPolicyText: String = "STRIPE_ZIP_CODE_POLICY".localizedPoqString
    @objc public var deliveredToText: String = "DELIVERED_TO".localizedPoqString
    @objc public var subtotalText: String = "SUB_TOTAL".localizedPoqString
    @objc public var postageText: String = "POST_PACKAGING".localizedPoqString
    @objc public var totalText: String = "Total".localizedPoqString
    @objc public var voucherTitleText: String = "Voucher".localizedPoqString
    @objc public var orderProductCodeTitle: String = "PRODUCT_CODE".localizedPoqString
    @objc public var orderGiftMessageText: String = "GIFT_MESSAGE".localizedPoqString
    @objc public var modifyOrderButtonText: String = "MODIFY_ORDER".localizedPoqString
    @objc public var orderDetailsSummaryTitle: String = "ORDER_DETAILS_SUMMARY".localizedPoqString
    @objc public var billingText: String = "PAYMENT_BILLING".localizedPoqString
    
    // MARK: - Order history
    @objc public var orderListNoItemsText: String = "ORDER_HISTORY_EMPTY".localizedPoqString
    @objc public var orderListSubNoItemsText: String = "CLICK_BELOW %@".localizedPoqString
    @objc public var orderStatusText: String = "ORDER_STATUS".localizedPoqString
    
    // MARK: - Lookbook
    @objc public var lookbookShopButtonTitle: String = "LOOKBOOK_SHOP_BUTTON".localizedPoqString
    @objc public var lookbookHideButtonTitle: String = "LOOKBOOK_HIDE_BUTTON".localizedPoqString
    
    // MARK: - COMMON
    @objc public var retryText: String = "PLEASE_TRY_AGAIN".localizedPoqString
    
    // MARK: - Error messages
    @objc public var connectionErrorTitleText: String = "CONNECTION_ERROR".localizedPoqString
    @objc public var connectionErrorText: String = "NO_NETWORK_CONNECTION_MSG".localizedPoqString
    
    // MARK: - Review
    @objc public var ratingsReviewNavigationTitle: String = "RATINGS_REVIEWS".localizedPoqString
    
    // MARK: - Voucher List
    @objc public var voucherListApplyToBagButtonTitle = "APPLY_TO_BAG".localizedPoqString
    @objc public var voucherListUseInStoreButtonTitle = "USE_IN_STORE".localizedPoqString
    @objc public var voucherListVouhcerAppliedToBagPopupTitle = "VOUCHER_APPLIED_TO_BAG".localizedPoqString
    @objc public var voucherExpiringSoonLabel = "EXPIRING_SOON".localizedPoqString
    @objc public var voucherDetailsVoucherCodeLabel = "VOUCHER_CODE".localizedPoqString
    @objc public var voucherDetailsScanInStoreShortLabel = "SCAN_IN_STORE".localizedPoqString
    @objc public var voucherDetailsScanInStoreLongLabel = "SCAN_THIS_VOUCHER_IN_STORE".localizedPoqString
    @objc public var voucherAppliedToYourBagLabel = "VOUCHER_APPLIED_TO_BAG".localizedPoqString
    
    // MARK: - Apply Voucher
    @objc public var applyVoucherTitle: String = "APPLY_VOUCHER_TITLE".localizedPoqString
    @objc public var applyVoucherTextFieldPlaceholder: String = "APPLY_VOUCHER_TEXTFIELD_PLACEHOLDER".localizedPoqString
    @objc public var applyVoucherButtonLabel: String = "APPLY_VOUCHER_BUTTON_LABEL".localizedPoqString
    @objc public var invalidVoucherCodeMessage: String = "INVALID_VOUCHER_CODE".localizedPoqString
    @objc public var applyVoucherSuccessMessage: String = "Successfully Redeemed."
    @objc public var removeVoucherAlertMessage: String = "REMOVE_VOUCHER_MESSAGE".localizedPoqString
    
    @objc public var voucherViewText: String = "VOUCHER_VIEW_TEXT".localizedPoqString
    @objc public var studentDiscountViewText: String = "STUDENT_DISCOUNT_VIEW_TEXT".localizedPoqString
    @objc public var voucherCodeDefaultText: String = "VOUCHER_CODE_DEFAULT_TEXT".localizedPoqString
    @objc public var studentDiscountDefaultText: String = "STUDEN_DISCOUNT_DEFAULT_TEXT".localizedPoqString
    
    // MARK: - Payment
    @objc public var checkoutPaymentCardTitle: String = ""
    @objc public var checkoutBillingAddressTitle: String = ""
    // MARK: - Order Summary
    @objc public var checkoutOrderSummaryPageTitle: String = "ORDER_SUMMARY".localizedPoqString
    @objc public var checkoutDeliveryOptionsPageTitle: String = "DELIVERY_OPTIONS".localizedPoqString
    @objc public var checkoutSelectPaymentMethodTitle: String = "SELECT_PAYMENT_METHOD".localizedPoqString
    @objc public var checkoutPaymentMethodsTitle: String = "Payment Methods".localizedPoqString
    @objc public var checkoutPlaceOrderText: String = "PLACE ORDER".localizedPoqString
    @objc public var checkoutPayWithCardText: String = "PAY WITH CARD".localizedPoqString
    
    @objc public var checkoutOrderDetailHeaderTitle: String = "CHECKOUT_BAG_ITEMS_HEADER_TITLE".localizedPoqString
    @objc public var checkoutStepsHeaderTitle: String = "CHECKOUT_STEPS_HEADER_TITLE".localizedPoqString
    
    @objc public var checkoutSelectedPaymentMethodFreeTitle: String = "Free".localizedPoqString
    @objc public var orderSummaryTermsAndConditionsLabelText: String = "By Placing an order you agree to our Terms & Conditions".localizedPoqString
    @objc public var orderSummaryTermsAndConditionsClickableText: String = "Terms & Conditions".localizedPoqString
    
    @objc public var checkoutPaymentOptionsSectionCardTitle: String = "MY CARDS".localizedPoqString
    
    // MARK: - Incomplete steps
    @objc public var checkoutSelectPaymentMessage: String = "CHECKOUT_SELECT_PAYMENT_METHOD".localizedPoqString
    @objc public var checkoutSelectDeliveryAddressMessage: String = "CHECKOUT_SELECT_DELIVERY_ADDRESS".localizedPoqString
    @objc public var checkoutSelectDeliveryMethodMessage: String = "CHECKOUT_SELECT_DELIVERY_METHOD".localizedPoqString
    
    // MARK: - Order summary pop up messages
    @objc public var orderSummaryPaymentMethodMessageUpdate: String = "PAYMENT_METHOD_UPDATE_MESSAGE".localizedPoqString
    @objc public var orderSummaryBillingAddressMessageUpdate: String = "BILLING_ADDRESS_UPDATE_MESSAGE".localizedPoqString
    @objc public var orderSummaryShippingAddressMessageUpdate: String = "SHIPPING_ADDRESS_UPDATE_MESSAGE".localizedPoqString
    @objc public var orderSummaryDeliveryMethodMessageUpdate: String = "DELIVERY_METHOD_UPDATE_MESSAGE".localizedPoqString
    
    // MARK: - Checkout Address
    @objc public var sameAsAddressLabelText: String = "USE_SAME_AS_BILLING_ADDRESS".localizedPoqString
    @objc public var stripeZipCodeCheckFailedText: String = "STRIPE_ZIP_CODE_VALIDATION_FAILED_TEXT".localizedPoqString
    @objc public var stripeCVVCheckFailedText: String = "STRIPE_CVV_CODE_VALIDATION_FAILED_TEXT".localizedPoqString
    @objc public var stripeInvalidCardNumberCheckFailedText: String = "STRIPE_INVALID_CARD_CODE_VALIDATION_FAILED_TEXT".localizedPoqString
    @objc public var stripeExpiryMonthCheckFailedText: String = "STRIPE_EXPIRY_MONTH_CODE_VALIDATION_FAILED_TEXT".localizedPoqString
    @objc public var stripeExpiryYearCheckFailedText: String = "STRIPE_EXPIRY_YEAR_CODE_VALIDATION_FAILED_TEXT".localizedPoqString
    @objc public var stripeInvalidCVCCheckFailedText: String = "STRIPE_INVALID_CVC_CODE_VALIDATION_FAILED_TEXT".localizedPoqString
    @objc public var stripeIncorrectNumberCheckFailedText: String = "STRIPE_INCORRECT+NUMBER_CODE_VALIDATION_FAILED_TEXT".localizedPoqString
    @objc public var stripeExpiredCardCheckFailedText: String = "STRIPE_EXPIRED_CARD_CHECKED_CODE_VALIDATION_FAILED_TEXT".localizedPoqString
    @objc public var stripeCardDeclinedCheckFailedText: String = "STRIPE_CARD_DECLINED_CODE_VALIDATION_FAILED_TEXT".localizedPoqString
    @objc public var stripeMissingCheckFailedText: String = "STRIPE_MISSING_CHECK_CODE_VALIDATION_FAILED_TEXT".localizedPoqString
    @objc public var stripeProcessingErrorCheckFailedText: String = "STRIPE_PROCESSING_ERROR_CODE_VALIDATION_FAILED_TEXT".localizedPoqString
    
    @objc public var checkoutError: String = "CHECKOUT_ERROR".localizedPoqString
    
    // MARK: - ADDRESS TYPES
    @objc public var addressTypeBilling: String = "Billing"
    @objc public var addressTypeDelivery: String = "Delivery"
    @objc public var addressTypeAddressBook: String = "Address Book"
    @objc public var addressTypeNewAddress: String = "New Address"
    // MARK: - ADDRESS MESSAGES
    @objc public var baseNoAddressMessage: String = "No saved addresses to view"
    @objc public var moreInforNoAddressMessage: String = ""
    @objc public var addressSelectCountry: String = "SELECT_COUNTRY_ALERT".localizedPoqString

    @objc public var orderConfirmationPageTitleText: String = "YAY".localizedPoqString
    @objc public var checkoutConfirmationOrderNumberFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var checkoutConfirmationOrderNumberTextColor = UIColor.white
    @objc public var setAsPrimaryBillingAddressText: String = "Set as primary billing address"
    @objc public var setAsPrimaryShippingAddressText: String = "Set as primary shipping address"
    @objc public var importButtonText: String = "CHOOSE_FROM_CONTACTS".localizedPoqString
    @objc public var checkoutAddressSaveButtonTitle: String = "SAVE".localizedPoqString
    @objc public var checkoutAddressDeleteButtonText: String = "DELETE".localizedPoqString
    @objc public var checkoutAddressDeleteAlertText: String = "DELETE_ADDRESS_MESSAGE".localizedPoqString
    @objc public var selectBillingAddressButtonTitle: String = "SELECT_BILLING_ADDRESS".localizedPoqString
    @objc public var noBillingAddressSelectedMessage: String = "NO_BILLING_ADDRESS".localizedPoqString
    @objc public var orderDateLabelText: String = "ORDER_DATE".localizedPoqString

    @objc public var primaryBillingAddressTitle: String = "PRIMARY_BILLING_ADDRESS".localizedPoqString
    @objc public var primaryDeliveryAddressTitle: String = "PRIMARY_DELIVERY_ADDRESS".localizedPoqString
    @objc public var billingAddressTitle: String = "BILLING_ADDRESS".localizedPoqString
    @objc public var deliveryAddressTitle: String = "DELIVERY_ADDRESS".localizedPoqString
    @objc public var billingAddressOrderStatusTitle: String = "BILLING_ADDRESS_OREDER_STATUS_TITLE".localizedPoqString
    @objc public var deliveryAddressOrderStatusTitle: String = "DELIVERY_ADDRESS_OREDER_STATUS_TITLE".localizedPoqString
    @objc public var selectBillingAddressTitle: String = "SELECT_BILLING_ADDRESS".localizedPoqString
    @objc public var selectDeliveryAddressTitle: String = "SELECT_DELIVERY_ADDRESS".localizedPoqString
    @objc public var newBillingAddressTitle: String = "NEW_BILLING_ADDRESS".localizedPoqString
    @objc public var newDeliveryAddressTitle: String = "NEW_DELIVERY_ADDRESS".localizedPoqString
    
    @objc public var firstNameTextCheckout: String = "FIRSTNAME_ADDRESS".localizedPoqString
    @objc public var lastNameTextCheckout: String = "LASTNAME_ADDRESS".localizedPoqString
    @objc public var emailTextCheckout: String = "EMAIL_ADDRESS".localizedPoqString
    @objc public var companyCheckout: String = "COMPANY".localizedPoqString
    @objc public var phoneTextCheckout: String = "PHONE".localizedPoqString
    @objc public var addressTextCheckout: String = "ADDRESS".localizedPoqString
    @objc public var address2TextCheckout: String = "ADDRESS2".localizedPoqString
    @objc public var cityTextCheckout: String = "TOWN_CITY".localizedPoqString
    @objc public var countyTextCheckout: String = "COUNTY".localizedPoqString
    @objc public var postCodeTextCheckout: String = "POST_CODE".localizedPoqString
    @objc public var countryTextCheckout: String = "COUNTRY".localizedPoqString
    @objc public var addressNameTextCheckout: String = "ADDRESS_NAME".localizedPoqString
    @objc public var stateTextCheckout: String = "STATE".localizedPoqString
    
    // MARK: - Validation
    @objc public var enterValidFirstName: String = "ENTER_VALID_FIRSTNAME".localizedPoqString
    @objc public var enterValidLastName: String = "ENTER_VALID_LASTNAME".localizedPoqString
    @objc public var enterValidTelephone: String = "ENTER_VALID_TELEPHONE".localizedPoqString
    @objc public var enterValidEmail: String = "ENTER_VALID_EMAIL".localizedPoqString
    @objc public var enterValidAddress: String = "ENTER_VALID_ADDRESS".localizedPoqString
    @objc public var enterValidCity: String = "ENTER_VALID_CITY".localizedPoqString
    @objc public var enterValidCountry: String = "ENTER_VALID_COUNTRY".localizedPoqString
    @objc public var enterValidPostCode: String = "ENTER_VALID_POSTCODE".localizedPoqString
    @objc public var enterValidAddressName: String = "ENTER_VALID_ADDRESS_NAME".localizedPoqString
    @objc public var enterValidState: String = "ENTER_VALID_STATE".localizedPoqString
    @objc public var enterValidPassword: String = "ENTER_PASSWORD".localizedPoqString
    
    // MARK: - Checkout Order Summary
    @objc public var checkoutOrderSummaryPaymentBillingTitle: String = "PAYMENT_BILLING".localizedPoqString
    @objc public var checkoutOrderSummaryTotal: String = "Total".localizedPoqString
    @objc public var checkoutOrderSummarySubTotal: String = "Subtotal".localizedPoqString
    @objc public var checkoutOrderSummaryDiscount: String = "DISCOUNT".localizedPoqString
    @objc public var checkoutOrderSummaryDeliveryOptions: String = "DELIVERY_OPTIONS".localizedPoqString
    @objc public var checkoutOrderSummarySelectDeliveryOptions: String = "SELECT_DELIVERY_OPTIONS".localizedPoqString
    @objc public var checkoutOrderSummaryNoDeliveryOption: String = "No delivery options available."
    @objc public var checkoutOrderSummarySelectAddressType: String = "SELECT_ADDRESS_TYPE".localizedPoqString
    @objc public var checkoutOrderSummaryBagItemFormat: String = "TITLE_SIZE_NUMBER".localizedPoqString
    @objc public var checkoutOrderSummaryPayTotalFormat: String = "Pay %@".localizedPoqString
    @objc public var orderConfirmationNoDeliveryAddressError: String = "Please select delivery address"
    
    // MARK: - Checkout Order Confirmation
    @objc public var orderConfirmationSendMessage: String = "your order confirmation has been sent to:"
    @objc public var orderConfirmationContinueShoppingText: String = "CONTINUE_SHOPPING".localizedPoqString
    @objc public var checkoutOrderConfirmationNumber: String = "ORDER_HARSH_NUMBER".localizedPoqString
    @objc public var orderConfirmationPageOrderIDTitleText: String = "ORDER_ID".localizedPoqString
    @objc public var orderConfirmationTitleCellText: String = "YAY".localizedPoqString
    @objc public var orderConfirmationTitleCellMessageFormat: String = "ORDER_CONFIRMATION_ENAIL_FORMAT".localizedPoqString
    @objc public var checkoutOrderConfirmationDiscount: String = "DISCOUNT".localizedPoqString
    @objc public var checkoutOrderConfirmationTotal: String = "Total".localizedPoqString
    @objc public var checkoutOrderConfirmationSubTotal: String = "Subtotal".localizedPoqString
    @objc public var orderConfirmationTotalPaidTitle: String = "Paid".localizedPoqString
    @objc public var orderConfirmationSummarySectionTitleText: String = "Summary".localizedPoqString
    
    // MARK: - Payment Method
    @objc public var createCardPaymentMethodTitle: String = "ADD_CARD_PAYMENT_METHOD_TITLE".localizedPoqString
    @objc public var createCardPaymentSaveButtonText: String = "ADD_PAYMENT_METHOD_SAVE".localizedPoqString
    @objc public var securePaymentHintInfoText: String = "ADD_PAYMENT_METHOD_SECURITY_HINT".localizedPoqString
    @objc public var myProfileAddressBookTitle: String = "ADDRESS_BOOK".localizedPoqString
    @objc public var viewAmendButtonText: String = "VIEW_AMEND_BUTTON".localizedPoqString
    @objc public var setPrimaryBillingAddressText: String = "SET_PRIMARY_BILLING_ADDRESS".localizedPoqString
    @objc public var setPrimaryShippingAddressText: String = "SET_PRIMARY_SHIPPING_ADDRESS".localizedPoqString
    @objc public var sameAsBillingAddressText: String = "SAME_AS_BILLING_ADDRESS".localizedPoqString
    
    // MARK: - EDIT ADDRESS
    @objc public var selectAddressText: String = "CHECKOUT_MANAGEADDRESS_SELECT_ADDRESS".localizedPoqString
    @objc public var newAddressTitle: String = "NEW_ADDRESS".localizedPoqString
    @objc public var editAddressTitle: String = "EDIT_ADDRESS".localizedPoqString
    @objc public var deletePopupMessage: String = "DELETE_ADDRESS_MESSAGE".localizedPoqString
    @objc public var myProfileAddressBookAddButtonTitle: String = "ADD".localizedPoqString
    
    // MARK: - Tinder
    @objc public var tinderSwipeLeftText = "nah".localizedPoqString
    @objc public var tinderSwipeRightText = "love".localizedPoqString
    
    // MARK: - COUNTRY SELETION
    @objc public var changeCountrySelectionFormat = "COUNTRY_SELECTION_CURRENT_COUNTRY_FORMAT".localizedPoqString
    @objc public var changeCountryViewTitle = "COUNTRY_SELECTION_TITLE".localizedPoqString
    @objc public var changeCountryMessageTitle = "COUNTRY_SELECTION_WARNING_TITLE".localizedPoqString

    @objc public var bagViewDoneButtonText = "DONE".localizedPoqString
    
    @objc public var orderStatusProcessingText: String = "ORDER_PROCESSING".localizedPoqString
    @objc public var orderStatusPickingText: String = "ORDER_PICKING".localizedPoqString
    @objc public var orderStatusPendingPaymentText: String = "ORDER_PENDING_PAYMENT".localizedPoqString
    @objc public var orderStatusFraudText: String = "ORDER_SUSPECTED_FRAUD".localizedPoqString
    @objc public var orderStatusPaymentReviewText: String = "ORDER_PAYMENT_REVIEW".localizedPoqString
    @objc public var orderStatusPendingText: String = "ORDER_PAYMENT_PENDING".localizedPoqString
    @objc public var orderStatusHoldedText: String = "ORDER_ON_HOLD".localizedPoqString
    @objc public var orderStatusRefundPendingText: String = "ORDER_REFUND_PENDING".localizedPoqString
    @objc public var orderStatusCompleteText: String = "ORDER_COMPLETE".localizedPoqString
    
    @objc public var orderStatusClosedText: String = "ORDER_CLOSED".localizedPoqString
    @objc public var orderStatusCanceledText: String = "ORDER_CANCELED".localizedPoqString
    @objc public var orderStatusCanceledPendingsText: String = "ORDER_CANCELED_PENDINGS".localizedPoqString
    @objc public var orderStatusPendingPayPalText: String = "ORDER_PENDING_PAYPAL".localizedPoqString
    
    @objc public var onboardingCompleteButtonTitle: String = "Get Started".localizedPoqString
    
    @objc public var giftOptionsTitle: String = "Gift Options".localizedPoqString
    @objc public var addAGiftMessageText: String = "Add a Free Gift Message".localizedPoqString
    @objc public var giftOptionsDoneButtonText: String = "Done".localizedPoqString
    
    // MARK: - VOUCHERS
    @objc public var vouchersCategoryTitle: String = "VOUCHERS_CATEGORY_TITLE".localizedPoqString
    @objc public var vouchersNotFoundText: String = "Vouchers_Not_Found".localizedPoqString
    @objc public var selectSizeButtonText: String = "Select Size".localizedPoqString
    @objc public var vouchersSectionTitleText: String = "Vouchers".localizedPoqString
    @objc public var offersSectionTitleText: String = "Offers".localizedPoqString
    @objc public var viewAllOffersText: String = "View all Offers".localizedPoqString
    @objc public var voucherDetailsTitle: String = "Voucher Details".localizedPoqString
    
    // MARK: - FORCE UPDATE
    @objc public var forceUpdateButtonText: String = "FORCE_UPDATE_MESSAGE".localizedPoqString
    @objc public var forceUpdateLabelText: String = "FORCE_UPDATE_LABEL_MESSAGE".localizedPoqString
    
    // MARK: - APP STORIES
    @objc public var appStoryNewStoryLabelText: String = "NEW_APP_STORY".localizedPoqString
    @objc public var appStoryInfoPdpGoToProductText: String = "GO_TO_PRODUCT".localizedPoqString
}
