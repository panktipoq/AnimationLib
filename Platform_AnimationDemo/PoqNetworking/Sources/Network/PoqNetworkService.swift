//
//  PoqNetworkService.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 06/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqUtilities

public final class PoqNetworkService {
    
    // Delegate for callback
    // FIXME: make it weak!
    public final var networkTaskDelegate: PoqNetworkTaskDelegate
    
    public init(networkTaskDelegate: PoqNetworkTaskDelegate) {
        self.networkTaskDelegate = networkTaskDelegate
    }
    
    @discardableResult
    public final func addToCart(cartItemPostBody: AddToCartBody) -> PoqNetworkTask<DecodableParser<AnyCodable?>> {
       
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postCartItems, httpMethod: .POST)
        let networkTask = PoqNetworkTask<DecodableParser<AnyCodable?>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiAddToCart)
        networkRequest.setBody(cartItemPostBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    /**
     Get Home banners
     */
    @discardableResult
    public final func getHomeBanners(_ isRefresh: Bool = false) -> PoqNetworkTask<JSONResponseParser<PoqHomeBanner>> {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.homeBanner, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqHomeBanner>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetHomeBanners)
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    /**
     Get main categories
     */
    public final func getMainCategories(_ isRefresh: Bool = false) {
        getSubCategories(0, isRefresh: isRefresh)
    }
    
    /**
     Get sub categories of a category
     
     - parameter categoryId: parent category id
     */
    public final func getSubCategories(_ categoryId: Int, isRefresh: Bool = false, brandName: String? = nil) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.categories, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqCategory>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetCategories, String(categoryId))
        
        if let brand = brandName {
            networkRequest.setQueryParam("brand", toValue: brand)
        }
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get all pages of a client
     */
    public final func getPages(_ pageId: Int, isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.pages, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqPage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetPages, String(pageId))
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get page details
     
     - parameter pageId: Page ID
     */
    public final func getPageDetails(_ pageId: Int, isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.pageDetails, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqPage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetPage, String(pageId))
        
        networkRequest.isRefresh = isRefresh

        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get HomeBanners, Pages, Stores and MySizes with User's selection
     - parameter isRefresh: if true - add query parameter which should invalidate API cache
     */
    public final func getSplash(isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.splash, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqSplash>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        // Country id for localization. Currently we always uses 3, othe languages depends on other app ids
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetSplashscreen, "3")
        networkRequest.setQueryParam("poqUserId", toValue: User.getUserId())
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get product details
     
     - parameter productId: Product's Poq ID
     - parameter externalId: Product's external ID coming from client (Demandware, Magento etc.)
     */
    @discardableResult
    public final func getProductDetails(_ poqUserId: String, productId: Int, externalId: String?, isRefresh: Bool = false) -> PoqNetworkTask<JSONResponseParser<PoqProduct>> {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.productDetails, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqProduct>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetProductDetails, String(productId))
        networkRequest.setQueryParam("externalId", toValue: externalId)
        networkRequest.setQueryParam("poqUserId", toValue: poqUserId)
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
        return networkTask
    }
    
    /**
     Get products by search query
     
     - parameter query: Query term
     */
    @discardableResult
    public final func getProductsByQuery(_ poqUserId: String, query: String, isRefresh: Bool = false) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.productsByQuery, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqFilterResult>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        if NetworkSettings.shared.productListFilterType == ProductListFiltersType.dynamic.rawValue {
            networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetDynamicFilteredProducts)
        } else {
            networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetFilteredProducts)
        }
        
        networkRequest.setQueryParam("keyword", toValue: query)
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    /**
     Get group of products by IDs
     
     - parameter relatedProductIds: Grouped product IDs
     */
    public final func getProductsByIds(relatedProductIds: [Int], isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.productsByIds, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqFilterResult>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        if NetworkSettings.shared.productListFilterType == ProductListFiltersType.dynamic.rawValue {
            networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetDynamicFilteredProducts)
        } else {
            networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetFilteredProducts)
        }
        
        networkRequest.setQueryParam("ids", toValues: relatedProductIds.sorted().map({ String($0) }))
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get group of products by External IDs
     
     - parameter relatedExternalProductIds: Grouped product External IDs
     */
    public final func getProductsByIds(relatedProductExternalIds: [String], isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.productsByExternalIds, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqProduct>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetDynamicFilteredProducts)

        networkRequest.setQueryParam("externalIds", toValues: relatedProductExternalIds.sorted())
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getProductsByBundleId( _ bundleId: String ) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.productsByBundle, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqFilterResult>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetBundleProducts, bundleId)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    @discardableResult
    public final func getProductsByCategory(withUserId poqUserId: String, categoryId: Int, externalId: String = "", isRefresh: Bool = false) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        return getProductsByCategory(poqUserId, categoryId: categoryId, externalId: externalId, brandId: "", isRefresh: isRefresh)
    }
    
    @discardableResult
    public final func getProductsByCategory(poqUserId: String, categoryId: Int, externalId: String = "", brandId: String = "", brandName: String? = nil, isRefresh: Bool = false, andFilters filter: PoqFilter? = nil, page: Int? = nil) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.productsByCategory, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqFilterResult>>(request: networkRequest, networkTaskDelegate: self.networkTaskDelegate)
        
        if NetworkSettings.shared.productListFilterType == ProductListFiltersType.dynamic.rawValue {
            networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetDynamicFilteredProducts)
        } else {
            networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetFilteredProducts)
        }
        
        networkRequest.setQueryParam("categoryId", toValue: String(categoryId))
        networkRequest.setQueryParam("externalId", toValue: externalId)
        
        networkRequest.setQueryParam("order", toValue: filter?.selectedSortField?.rawValue)
        networkRequest.setQueryParam("direction", toValue: filter?.selectedSortType?.rawValue)
        
        if !brandId.isNullOrEmpty() {
            networkRequest.setQueryParam("brand", toValue: brandId)
        }
        
        if let validBrandName = brandName, !validBrandName.isNullOrEmpty() {
            networkRequest.setQueryParam("brandName", toValue: validBrandName)
        }
        
        if let nextPage = page {
            networkRequest.setQueryParam("page", toValue: String(nextPage))
        }
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    /**
     Get products in a category
     
     - parameter categoryId: Selected Category ID
     */
    @discardableResult
    public final func getProductsByCategory(_ poqUserId: String, categoryId: Int, externalId: String = "", brandId: String = "", isRefresh: Bool = false) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.productsByCategory, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqFilterResult>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        if NetworkSettings.shared.productListFilterType == ProductListFiltersType.dynamic.rawValue {
            networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetDynamicFilteredProducts)
        } else {
            networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetFilteredProducts)
        }
        
        networkRequest.setQueryParam("categoryId", toValue: String(categoryId))
        networkRequest.setQueryParam("externalId", toValue: externalId)
        
        if !brandId.isEmpty {
            networkRequest.setQueryParam("brand", toValue: brandId)
        }
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    @discardableResult
    public final func getProductsByFilter(_ poqUserId: String, filter: PoqFilter, page: Int?, externalId: String = "", brandId: String = "", isRefresh: Bool = false) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        return getProductsByFilter(withUserId: poqUserId, filter: filter, page: page, externalId: externalId, brandId: brandId, isRefresh: isRefresh)
    }
    
    @discardableResult
    public final func getProductsByFilter(withUserId poqUserId: String, filter: PoqFilter, page: Int?, externalId: String = "", brandId: String = "", isRefresh: Bool = false, brandName: String = "") -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.productsByFilters, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqFilterResult>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        if NetworkSettings.shared.productListFilterType == ProductListFiltersType.dynamic.rawValue {
            networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetDynamicFilteredProducts)
        } else {
            networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetFilteredProducts)
        }
        
        networkRequest.setQueryParam("externalId", toValue: externalId)
        
        if !brandName.isNullOrEmpty() {
            networkRequest.setQueryParam("brandName", toValue: brandName)
        }
        
        if !brandId.isEmpty {
            networkRequest.setQueryParam("brand", toValue: brandId)
        }
        
        let filterQueryParameters = getQueryParameters(for: filter)
        for parameter in filterQueryParameters.keys {
            networkRequest.setQueryParam(parameter, toValues: filterQueryParameters[parameter])
        }
        
        networkRequest.isRefresh = isRefresh
        
        if let nextPage = page {
            networkRequest.setQueryParam("page", toValue: String(nextPage))
        }
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    /**
     Get lookbook images
     
     - parameter lookbookId: Lookbook ID
     */
    public final func getLookbookImages(_ lookbookId: Int, isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.lookbookImages, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqLookbookImage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetLookbookImages, String(lookbookId))
        
        networkRequest.isRefresh = isRefresh

        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get products in a lookbook image
     
     - parameter lookbookPictureId: Lookbook Picture ID
     */
    public final func getLookbookImageProducts(_ lookbookPictureId: Int, externalProductIds: [String], isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.lookbookImageProducts, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqProduct>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetLookbookImageProducts)
        
        networkRequest.setQueryParam("externalIds", toValues: externalProductIds)
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get products by scanning a barcode or manually entering it
     
     - parameter scanContent: Product code (ean, sku etc.) for a scan or manually entering
     */
    @discardableResult
    public final func getProductScan(_ poqUserId: String, scanContent: String, isRefresh: Bool = false) -> PoqNetworkTask<JSONResponseParser<PoqProduct>> {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.productsScan, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqProduct>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetProductScan, scanContent)
        networkRequest.setQueryParam("poqUserId", toValue: poqUserId)
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    /// Get categories with products that are visually similar
    ///
    /// - Parameter poqMultipartFormDataPost: This is a typealias tuple 
    public final func visuallySimilarProducts(poqMultipartFormDataPost: PoqMultipartFormDataPost) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.productsVisualSearch, httpMethod: .POST, bodyDataType: .multiPartForm)
        networkRequest.setMultipartFormData(poqMultipartFormDataPost)
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetProductsVisualSearch)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqVisualSearchResult>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getStoreDetail(_ storeId: Int, isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.storeDetail, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqStore>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetStoreDetail, String(storeId))
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get list of sizes with user's selections included
     
     - parameter poqUserId: Created at AppDelegate for a device. Each device is a user in Poq Platfrom
     */
    public final func getMySizes(_ poqUserId: String, isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getMySizes, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMySize>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetMysizes)
        networkRequest.setQueryParam("poqUserId", toValue: poqUserId)
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Post user's mysize selections to update its profile
     
     - parameter poqUserId: Created at AppDelegate for a device. Each device is a user in Poq Platfrom
     - parameter mySizes: Comma seperated list of mysizes value
     */
    public final func postMySizes(_ poqUserId: String, mySizes: String) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postMySizes, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostMysizes, poqUserId)
        networkRequest.setQueryParam("MySizeIDs", toValue: mySizes)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getStores(_ isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.stores, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqStore>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetStores)
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get product's store stock availability
     
     - parameter productId: Product's Poq ID
     - parameter productSizeId: Product Size's Poq ID
     - parameter lat: Latitude value of the user's current location
     - parameter lng: Longtitude value of the user's current location
     - parameter storeId: User's selected or preferred (set in another journey) store
     - parameter poqUserId: Created at AppDelegate for a device. Each device is a user in Poq Platfrom
     */
    public final func getStoreStock(_ productId: Int, productSizeId: Int, lat: Double, lng: Double, storeId: Int, poqUserId: String, isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.storeStock, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqStoreStock>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetStoreStock)
        networkRequest.setQueryParam("productID", toValue: String(productId))
        networkRequest.setQueryParam("productSizeID", toValue: String(productSizeId))
        networkRequest.setQueryParam("poqUserID", toValue: String(poqUserId))
        networkRequest.setQueryParam("lat", toValue: String(format: "%f", lat))
        networkRequest.setQueryParam("lng", toValue: String(format: "%f", lng))
        networkRequest.setQueryParam("storeId", toValue: String(storeId))
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Post order created by items in user's shopping bag
     
     - parameter order: Created by user's shopping bag
     */
    public final func postOder<OrderItemType>(_ order: PoqOrder<OrderItemType>) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.order, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostOrder)
        networkRequest.setBody(order)
        networkRequest.setQueryParam("poqUserID", toValue: User.getUserId())
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Post completed order created by items in user's shopping bag
     
     - parameter order: Created by user's shopping bag
     */
    public final func postCompletedOrder<OrderItemType>(_ order: PoqOrder<OrderItemType>) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.updateOrder, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        // Create new order if id is 0 - Used during native checkout's first step (click secure checkout button)
        // Otherwise do update:
        // Can be used for either native checkout or cart transfer
        // Cart transfer will update the order after parsing from webview
        // Native checkout should update in every step
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiUpdateOrder, String(order.id ?? 0))
        networkRequest.setBody(order)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Post user's selection of productSize to its whislist on Poq Platform
     
     - parameter productID:
     - parameter poqUserId: Created at AppDelegate for a device. Each device is a user in Poq Platfrom
     */
    public final func postWishList(_ poqUserId: String, productId: Int, externalId: String? = nil) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postWhishList, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostWishList, poqUserId)
        
        let newWishlistRequest = PoqShoppingListItemPostBody()
        newWishlistRequest.productId = String(productId)
        newWishlistRequest.externalId = externalId
        networkRequest.setBody(newWishlistRequest)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
 
    public static let DefaultWishlisPageSize: Int = 10
    
    public final func getWishList(_ poqUserId: String, storeId: String?, page: Int?, pageSize: Int = DefaultWishlisPageSize, isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getWhishList, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqProduct>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetWishList, poqUserId)
        networkRequest.setQueryParam("storeID", toValue: storeId)
        
        if let page = page {
            networkRequest.setQueryParam("page", toValue: String(page))
            networkRequest.setQueryParam("count", toValue: String(pageSize))
        }
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Delete user's selection of productSize to its whislist from Poq Platform
     
     - parameter storeId: User's selected or preferred (set in another journey) store
     - parameter poqUserId: Created at AppDelegate for a device. Each device is a user in Poq Platfrom
     */
    public final func deleteWishList(_ poqUserId: String, productId: Int) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.deleteWishList, httpMethod: .DELETE)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiDeleteWishList, poqUserId, String(productId))
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Delete an item from shopping list
     
     - parameter poqUserId: Created at AppDelegate for a device. Each device is a user in Poq Platfrom
     */
    public final func clearAllWishList(_ poqUserId: String) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.deleteAllWishList, httpMethod: .DELETE)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiDeleteAllWishList, poqUserId)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get user's selection of productSize to its whislist from Poq Platform
     
     - parameter storeId: User's selected or preferred (set in another journey) store
     - parameter poqUserId: Created at AppDelegate for a device. Each device is a user in Poq Platfrom
     */
    public final func getWishListProductIds(_ poqUserId: String, isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getWhishListProductIds, httpMethod: .GET)
        let networkTask = PoqNetworkTask<CountResponseParser>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetWishList_PRODUCT_IDS, poqUserId)
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get list of reviews for a product
     
     - parameter productId: User's selected or preferred (set in another journey) store
     */
    public final func getProductReviews(_ productId: Int, isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.productReviews, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqProductReview>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetReviews, String(productId))
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getBrands(_ isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.brands, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqCategory>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetBrands)
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get users bag items
     
     - parameter poqUserId: Created at AppDelegate for a device. Each device is a user in Poq Platfrom
     */
    @discardableResult
    public final func getUsersBagItems(_ poqUserId: String, isRefresh: Bool = false) -> PoqNetworkTask<JSONResponseParser<PoqBagItem>> {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getBag, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqBagItem>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetUsersBagItems, poqUserId)
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    /**
     Post users bag items
     
     - parameter poqUserId: Created at AppDelegate for a device. Each device is a user in Poq Platfrom
     */
    public final func postUsersBagItems(_ poqUserId: String, postBody: PoqBagItemPostBody) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postBag, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostBagItem, poqUserId)
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func updateUsersBagItems(_ poqUserId: String, postBody: PoqBagItemPostBody) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postBag, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiUpdateBagItem, poqUserId)
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Delete users bag item
     
     - parameter poqUserId: Created at AppDelegate for a device. Each device is a user in Poq Platform
     - parameter postBody: items to be deleted that must have quantity field equal to 0 to be removed from back end
     */
    public final func deleteUsersBagItem(_ poqUserId: String, postBody: PoqBagItemPostBody) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.deleteBagItem, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiUpdateBagItem, poqUserId)
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Delete users all bag items
     
     - parameter poqUserId: Created at AppDelegate for a device. Each device is a user in Poq Platfrom
     */
    public final func deleteUsersAllBagItems(_ poqUserId: String) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.deleteAllBag, httpMethod: .DELETE)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiDeleteAllBagItem, poqUserId)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func postAccount(_ postBody: PoqAccountPost, poqUserId: String) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postAccount, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqAccount>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostAccount, poqUserId)
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func postFacebookAccount(_ postBody: PoqFacebookAccountPost, poqUserId: String) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postFacebookAccount, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqAccount>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostFacebookAccount, poqUserId)
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func registerAccount(_ postBody: PoqAccountRegister, poqUserId: String) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.registerAccount, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqAccount>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiRegisterAccount, poqUserId)
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getAccount(_ isRefresh: Bool = false) {
        // TODO: check with API team, but looks wrong - get account must be get
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getAccount, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqAccount>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetAccount, User.getUserId())
        networkRequest.setBody(PoqAccountPost())
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func updateAccount(_ postBody: PoqAccountUpdate) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.updateAccount, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqAccount>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiUpdateAccount, User.getUserId())
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get Order list
     */
    @discardableResult
    public final func getOrders<OrderItemType, OrderType: PoqOrder<OrderItemType>>(_ isRefresh: Bool = false) -> PoqNetworkTask<JSONResponseParser<OrderType>> {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getOrderList, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<OrderType>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetOrderList, User.getUserId())
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    /**
     Get individual order summary
     */
    @discardableResult
    public final func getOrderSummary<OrderItemType, OrderType: PoqOrder<OrderItemType>>(_ orderKey: String, isRefresh: Bool = false) -> PoqNetworkTask<JSONResponseParser<OrderType>> {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getOrderSummary, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<OrderType>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetOrderSummary, orderKey)
        networkRequest.setQueryParam("poqUserId", toValue: User.getUserId())
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    /**
     Download a remote url as string
     */
    public final func downloadData(_ urlString: String, networkTaskType: PoqNetworkTaskTypeProvider) {
        let networkRequest = PoqNetworkRequest(networkTaskType: networkTaskType, httpMethod: .GET)
        let networkTask = PoqNetworkTask<DownloadDataParser>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setPath(format: urlString)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getBagItemsCount(isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getBagItemCount, httpMethod: .GET)
        let networkTask = PoqNetworkTask<CountResponseParser>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        networkRequest.isRefresh = isRefresh
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetBagItemCount, User.getUserId())
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getWishlistItemsCount() {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getWishListItemCount, httpMethod: .GET)
        let networkTask = PoqNetworkTask<CountResponseParser>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetWishlistItemCount, User.getUserId())
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getBag() {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getModularBag, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqBag>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetModularBag, User.getUserId())
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getBagWebView() {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getBagWebView, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqWebBag>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetWebViewBag, User.getUserId())
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func putBagWebView(bagItems: PoqWebBagItems) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.putBagWebView, httpMethod: .PUT)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqWebBag>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPutWebViewBag, User.getUserId())
        networkRequest.setBody(bagItems)

        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Get bag items for native checkout
     
     - parameter orderId: 0 creates a new order, otherwise send with value to get latest details
     */
    @discardableResult
    public final func getCheckoutDetails<CheckoutItemType: CheckoutItem>(_ orderId: Int?, isRefresh: Bool = false) -> PoqNetworkTask<JSONResponseParser<CheckoutItemType>> {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getCheckoutDetails, httpMethod: .GET)

        let networkTask = PoqNetworkTask<JSONResponseParser<CheckoutItemType>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetCheckoutDetail, User.getUserId(), String(orderId ?? 0))
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    public final func postCheckoutAddress(_ orderId: String, postAddress: PoqPostAddress) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postAddresses, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqDeliveryOption>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostAddresses, User.getUserId(), orderId)
        networkRequest.setBody(postAddress)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func saveAddressToOrder(_ orderId: String, postAddress: PoqPostAddress) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.saveAddressesToOrder, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiSaveAddressesToOrder, User.getUserId(), orderId)
        networkRequest.setBody(postAddress)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getCheckoutAddresses() {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getAddresses, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqAddress>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetAddresses, User.getUserId())
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func postDeliveryOption(_ postDeliveryOption: PoqDeliveryOption) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postDeliveryOption, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqPaymentOption>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostDeliveryOption, User.getUserId())
        networkRequest.setBody(postDeliveryOption)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func postPaymentOption(_ postPaymentOption: PoqPaymentOption) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postPaymentOption, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostPaymentOption, User.getUserId())
        networkRequest.setBody(postPaymentOption)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public typealias PlaceOrderResponse<OrderItemType: OrderItem> = JSONResponseParser<PoqPlaceOrderResponse<OrderItemType>>

    @discardableResult
    public final func postCheckoutOrder<CheckoutItemType: CheckoutItem, OrderItemType: OrderItem>(_ checkoutItem: CheckoutItemType) -> PoqNetworkTask<PlaceOrderResponse<OrderItemType>> {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postOrder, httpMethod: .POST)

        let networkTask = PoqNetworkTask<PlaceOrderResponse<OrderItemType>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostCheckoutOrder, User.getUserId())
        networkRequest.setBody(checkoutItem)
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    public final func getVouchers(forCategory categoryId: Int) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getVouchers, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqVoucherV2>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetVouchers, String(categoryId))
        
        NetworkRequestsQueue.addOperation(networkTask)
    }

    public final func getOffers() {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getOffers, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqOffer>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetOffers, User.getUserId())

        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getVoucherDetails(_ voucherId: Int) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getVoucherDetails, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqVoucherV2>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetVoucherDetails, String(voucherId))
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getVouchersDashboard() {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getVouchersDashboard, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqVouchersDashboard>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetVouchersDashboard, User.getUserId())
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Apply Voucher before payment on checkout
     */
    public final func postVoucher(_ postBody: PoqPostVoucher) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postVoucher, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostVoucher, User.getUserId())
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func deleteVoucher(_ orderId: Int) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.removeVoucher, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiRemoveVoucher, User.getUserId(), String(orderId))
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func postStudentVoucher(_ postBody: PoqStudentNumber) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.postStudentVoucher, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostStudentVoucher, User.getUserId())
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getUserAddresses(_ isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getUserAddresses, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqAddress>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetUserAddresses, User.getUserId())
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }

    public final func deleteUserAddress(_ addressId: Int) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.deleteUserAddress, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiDeleteUserAddress, User.getUserId(), String(addressId))
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func updateUserAddress(_ postBody: PoqAddress) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.updateUserAddress, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqDeliveryOption>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiUpdateUserAddress, User.getUserId())
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func saveUserAddress(_ postBody: PoqAddress) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.saveUserAddresses, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiSaveUserAddress, User.getUserId())
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getMyProfileBlocks(_ isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.blocks, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqBlock>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetBlocks, String(PoqBlockCategory.myProfile.rawValue))
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }

    public final func getTinderProducts(lastProductId: Int, count: Int = 50, isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.tinderProducts, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqProduct>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetTinderProducts)
        networkRequest.setQueryParam("lastProductId", toValue: String(lastProductId))
        networkRequest.setQueryParam("count", toValue: String(count))
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getTinderProductsInCategory(categoryId: Int, lastProductId: Int, count: Int = 50, isRefresh: Bool = false) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.tinderProductsInCategory, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqProduct>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetTinderProductsInCategory, String(categoryId))
        networkRequest.setQueryParam("lastProductId", toValue: String(lastProductId))
        networkRequest.setQueryParam("count", toValue: String(count))
        
        networkRequest.isRefresh = isRefresh
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func postTinderLike(productId: Int) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.tinderLike, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiPostTinderProductLike, User.getUserId())
        networkRequest.setQueryParam("productId", toValue: String(productId))
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    public final func getStoryDetail(_ storyId: Int) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getStoryDetail, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqStory>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetStoryDetail, String(storyId))
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Request onboarding from API
    */
    public final func getOnboarding() {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getOnboarding, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqOnboarding>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)

        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetOnboarding)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Send request to predictive search API
     - returns: Operation, which making request. Can be cancelled
     */
    @discardableResult
    public final func predictiveSerch(_ query: String) -> PoqOperation {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.getPredictiveSearch, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqSearchResponse>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiGetPredictiveSearch)
        networkRequest.setQueryParam("keyword", toValue: query)
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    @discardableResult
    public func checkoutStart() -> PoqOperation {
        
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.startCartTransfer, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<StartCartTransferResponse>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiCheckoutStart)
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    @discardableResult
    public func checkoutComplete(with postBody: CompleteCartTransferPostBody) -> PoqOperation {
        
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.completeCartTransfer, httpMethod: .POST)
        let networkTask = PoqNetworkTask<DecodableParser<AnyCodable>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiCheckoutComplete)
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
    
    /**
     Start cart transfer. Send api call to make all needed operation for web view checkout on API side
     In response we will get StartCartTransferResponse, which has all needed info
     */
    public final func startCartTransfer(with postBody: StartCartTransferPostBody) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.startCartTransfer, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<StartCartTransferResponse>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiStartCartTransfer)
        networkRequest.setQueryParam("poqUserId", toValue: User.getUserId())
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Start cart transfer. Send api call to make all needed operation for web view checkout on API side
     In response we will get StartCartTransferResponse, which has all needed info
     */
    public final func completeCartTransfer(with postBody: CompleteCartTransferPostBody) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.completeCartTransfer, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiCompleteCartTransfer)
        networkRequest.setQueryParam("poqUserId", toValue: User.getUserId())
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }

    /**
     Request products info by products ids
     */
    public final func getRecentlyViewedProducts(with postBody: PoqRecentlyViewedPostBody, excluding productId: Int?) {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.recentlyViewed, httpMethod: .POST)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqProduct>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiRecentlyViewed)
        networkRequest.setQueryParam("poqUserId", toValue: User.getUserId())
        
        if let productId = productId {
            networkRequest.setQueryParam("excludeProductId", toValue: String(productId))
        }
        
        networkRequest.setBody(postBody)
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Clear recentlyViewed Products server side
     */
    public final func clearRecentlyViewedProducts() {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.recentlyViewed, httpMethod: .DELETE)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqMessage>>(request: networkRequest, networkTaskDelegate: nil)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiRecentlyViewed)
        networkRequest.setQueryParam("poqUserId", toValue: User.getUserId())
        
        NetworkRequestsQueue.addOperation(networkTask)
    }
    
    /**
     Fetch existed stories from API
     */
    @discardableResult
    public final func getAppStories() -> PoqNetworkTask<JSONResponseParser<PoqAppStoryResponse>> {
        let networkRequest = PoqNetworkRequest(networkTaskType: PoqNetworkTaskType.appStories, httpMethod: .GET)
        let networkTask = PoqNetworkTask<JSONResponseParser<PoqAppStoryResponse>>(request: networkRequest, networkTaskDelegate: networkTaskDelegate)
        
        networkRequest.setAppIdPath(format: PoqNetworkTaskConfig.apiAppStories)
        networkRequest.setQueryParam("poqUserId", toValue: User.getUserId())
        
        NetworkRequestsQueue.addOperation(networkTask)
        
        return networkTask
    }
}

extension PoqNetworkService {
    
    public func getQueryParameters(for filter: PoqFilter) -> [String: [String]] {
        var queryParameters = [String: [String]]()
        
        if let keywordUnwrapped = filter.keyword, !keywordUnwrapped.isEmpty {
            queryParameters["keyword"] = [keywordUnwrapped]
        } else if let categoryIdUnwrapped = filter.categoryId {
            queryParameters["categoryId"] = [categoryIdUnwrapped]
        }

        if NetworkSettings.shared.productListFilterType == ProductListFiltersType.static.rawValue {
            queryParameters["brands"] = filter.selectedBrands?.sorted()
            queryParameters["categories"] = filter.selectedCategories?.sorted()
            queryParameters["colors"] = filter.selectedColors?.sorted()
            queryParameters["colorValues"] = filter.selectedColorValues?.sorted()
            queryParameters["sizes"] = filter.selectedSizes?.sorted()
            queryParameters["sizeValues"] = filter.selectedSizeValues?.sorted()
            queryParameters["styles"] = filter.selectedStyles?.sorted()
        } else {
            
            if let selectedRefinements = filter.selectedRefinements {
                for refinement in selectedRefinements {
                    guard let refinementId = refinement.id, let selectedValueIds = refinement.values?.compactMap({ $0.id }) else {
                        continue
                    }
                    
                    queryParameters[refinementId] = selectedValueIds.sorted()
                }
            }
        }
        
        if let maxPrice = filter.selectedMaxPrice, maxPrice > 0 {
            queryParameters["max"] = [String(maxPrice)]
        }
        
        if let minPrice = filter.selectedMinPrice, minPrice > 0 {
            queryParameters["min"] = [String(minPrice)]
        }
        
        if let selectedSortFieldUnwrapped = filter.selectedSortField {
            queryParameters["order"] = [selectedSortFieldUnwrapped.rawValue]
        }
        
        if let selectedSortTypeUnwrapped = filter.selectedSortType {
            queryParameters["direction"] = [selectedSortTypeUnwrapped.rawValue]
        }
        
        return queryParameters
    }
}
