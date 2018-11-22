//
//  PoqApiConfig.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 06/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqUtilities

public class PoqNetworkTaskConfig {

    /// AppId, apiEndpoint and app/client specific configs must be initially set in AppDelegate via PLIST
    public static var appId = ""
    public static var poqApi = ""
    
    public static var currencyCode: String?
    
    /// Version of MB settings which should be used
    public static var settingsVersion: String?
    
    public static let apiGetHomeBanners = "/banners/%"
    public static let apiGetCategories = "/categories/%/%"
    public static let apiGetProductDetails = "/products/detail/%/%"
    public static let apiGetProductScan = "/products/scan/%/%"
    public static let apiGetProductsVisualSearch = "/visually_similar_products/by_image_upload/%"
    public static let apiGetPages = "/pages/%/%"
    public static let apiGetPage = "/pages/%/%"
    public static let apiGetFilteredProducts = "/products/filter/%"
    public static let apiGetBundleProducts = "/products/bundle/%/%"
    public static let apiGetDynamicFilteredProducts = "/products/filterV2/%"
    public static let apiGetLookbookImages = "/lookbooks/%/%"
    public static let apiGetLookbookImageProducts = "/products/by_external_ids/%"
    public static let apiGetStores = "/stores/%"
    public static let apiGetStoreDetail = "/stores/%/%"
    public static let apiGetStoreStock = "/stores/stock/%"
    public static let apiPostOrder = "/order/%"
    public static let apiUpdateOrder = "/order/update/%/%"
    public static let apiGetMysizes = "/mysizes/%"
    public static let apiPostMysizes = "/mysizes/%/%/setMySizes"
    public static let apiGetReviews = "/productreviews/%/%"
    public static let apiGetSplashscreen = "/splash/ios/%/%"
    public static let apiGetBrands = "/categories/%/brands"
    public static let apiGetUsersBagItems = "/BagItems/%/%"
    public static let apiPostBagItem = "/BagItems/%/%"
    public static let apiUpdateBagItem = "/BagItems/Update/%/%"
    public static let apiDeleteBagItem = "/BagItems/%/%/%"
    public static let apiDeleteAllBagItem = "/BagItems/%/%"
    public static let apiPostWishList = "/wishlist/%/%"
    public static let apiGetWishList = "/wishlist/%/%"
    public static let apiGetWishList_PRODUCT_IDS = "/wishlist/productIds/%/%"
    public static let apiDeleteWishList = "/wishlist/%/%/%"
    public static let apiDeleteAllWishList = "/wishlist/%/%"
    public static let apiRegisterAccount = "/account/register/%/%"
    public static let apiPostAccount = "/account/login/%/%"
    public static let apiPostFacebookAccount = "/account/facebookLogin/%/%"
    public static let apiGetAccount = "/account/details/%/%"
    public static let apiUpdateAccount = "/account/update/%/%"
    public static let apiGetOrderSummary = "/order/%/%"
    public static let apiGetOrderList = "/orders/%/%"
    public static let apiGetWishlistItemCount = "/wishlist/count/%/%"
    public static let apiGetBagItemCount = "/bagitems/count/%/%"
    public static let apiGetVouchers = "/apps/%/vouchers/category/%"
    public static let apiGetOffers = "/apps/%/offers"
    public static let apiGetVoucherDetails = "/apps/%/vouchers/detail/%"
    public static let apiPostVoucher = "/checkout/applyvoucher/%/%"
    public static let apiPostStudentVoucher = "/checkout/ApplyStudentDiscount/%/%"
    public static let apiGetCheckoutDetail = "/checkout/details/%/%/%"
    public static let apiSaveAddressesToOrder = "/checkout/SaveAddressToOrder/%/%/%"
    public static let apiPostAddresses = "/checkout/PostAddresses/%/%/%"
    public static let apiGetAddresses = "/checkout/addresses/%/%"
    public static let apiPostDeliveryOption = "/checkout/postdeliveryoption/%/%"
    public static let apiPostPaymentOption = "/checkout/postpaymentoption/%/%"
    public static let apiPostCheckoutOrder = "/checkout/postorder/%/%"
    public static let apiRemoveVoucher = "/checkout/removevoucher/%/%/%"
    public static let apiSaveUserAddress = "/account/SaveAddress/%/%"
    public static let apiGetUserAddresses = "/Account/Addresses/%/%"
    public static let apiDeleteUserAddress = "/Account/DeleteAddress/%/%/%"
    public static let apiUpdateUserAddress = "/Account/SaveAddress/%/%"
    public static let apiGetBlocks = "/ContentBlocks/%/%"
    public static let apiGetTinderProducts = "/Tinder/Products/%"
    public static let apiGetTinderProductsInCategory = "/Tinder/ProductsInCategory/%/%"
    public static let apiPostTinderProductLike = "/Tinder/Like/%/%"
    public static let apiGetStoryDetail = "/stories/%/%"
    public static let apiRefreshToken = "/account/token/%"
    public static let apiGetOnboarding = "/onboarding/%"
    public static let apiGetModularBag = "/checkout/apps/%/users/%/bag"
    public static let apiGetWebViewBag = "/bag/bagurl/%/%"
    public static let apiPutWebViewBag = "/bag/items/%/%"
    public static let apiGetVouchersDashboard = "/apps/%/vouchers/dashboard"
    public static let apiGetPredictiveSearch = "/search/apps/%/predictions"
    public static let apiStartCartTransfer = "/CartTransfer/apps/%/Begin"
    public static let apiCompleteCartTransfer = "/CartTransfer/apps/%/Complete"
    public static let apiRecentlyViewed = "/recommendations/apps/%/products/_recently_viewed"
    public static let apiAppStories = "/appstories/apps/%/home"
    public static let apiProductsByExternalIds = "/products/by_external_ids/%"
    public static let apiAddToCart = "/cart/items"
    
    // MARK: - CartTransfer v3
    public static let apiCheckoutStart = "/checkout/start"
    public static let apiCheckoutComplete = "/checkout/complete"
    
    // MARK: - STRIPE
    
    public static let stripeApiGetCustomer = "/stripe/apps/%/customers/%"
    public static let stripeApiCreateCustomer = "/stripe/apps/%/customers"
    public static let stripeApiDeleteUpdateCustomerSource = "/stripe/apps/%/customers/%/sources/%"
    public static let stripeApiAddCustomerSource = "/stripe/apps/%/customers/%/sources"
    
    // MARK: - Braintree
    
    public static let braintreeApiGenerateToken = "/braintree/token/%"
    public static let braintreeApiGenerateNonce = "/braintree/nonce/%/%"
    public static let braintreeApiGetCustomer = "/braintree/customers/%/%"
    public static let braintreeApiCreateCustomer = "/braintree/customers/%"
    public static let braintreeApiUpdateCustomer = "/braintree/customers/%/%"
    public static let braintreeApiDeletePaymentSource = "/braintree/customers/%/%"

}
