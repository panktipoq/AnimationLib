//
//  ProductListViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 21/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities

open class ProductListViewModel: BaseViewModel {
    
    /// Toolbar types for the PLP filter toolbar items.
    public enum ToolbarItemType: String, ToolbarContentItemType {
        case featured
        case newest
        case rating
        case price
        case seller
    }
    
    /// The content blocks pulled from the backend that makeup the sections of this pace.
    public var contentBlocks = [PoqPromotionBlock]()
    
    /// The products that are being listed in the PLP.
    public var products = [PoqProduct]()
    
    /// The range of the products fetched in the next page
    public var updatedRange: CountableRange<Int>?
    
    /// Object that gives the specifics of the chunk of data received from the backend. This object contains a reffrence to the products as well as the current pages being displayed and information about the filters used.
    open var filteredResult: PoqFilterResult?
    
    /// Current selected category id.
    open var currentCategoryId: Int?
    
    /// Current keyword used for searching products.
    open var currentKeyword: String?
    
    /// The filter settings used by the filteredResult.
    var filters: PoqFilter?
    
    /// Current active network tasks. We store these refrences to have control over the ongoing requests to backend.
    var currentNetworkTasks = Set<PoqNetworkTask<JSONResponseParser<PoqFilterResult>>>()
    
    /// The current loaded page.
    open var selectedPage: Int = 1
    
    /// The current selected sort field.
    open var selectedSortField = PoqFilterSortField.DEFAULT
    
    /// The current selected sort type.
    open var selectedSortType = PoqFilterSortType.DEFAULT
    
    /// The current external id. Set via external deeplink and should be transferred to API in every call.
    open var externalId: String = ""
    
    /// Search string used to search for products TODO: remove this we already use currentKeyword.
    var searchString: String?
    
    /// Total number of items in the PLP.
    var totalItemsCount: Int?
    
    /// The content of the toolbar for the filter options.
    var toolbarContent = [ToolbarContentItem]()
    
    /// Flag for showing activity indicator for only first load.
    var isLoadingFirstTime: Bool = true    
    
    /// Resets the filters to the default state.
    func resetFilters() {
        selectedSortField = PoqFilterSortField.DEFAULT
        selectedSortType = PoqFilterSortType.DEFAULT
    }
    
    // ______________________________________________________    
    // MARK: - Basic network tasks
    
    /// Load products by, without any sotring options. By default it is featured order.
    func cancelCurrentNetworkTaskIfExists() {
        for task in currentNetworkTasks {
            task.cancel()
        }
        currentNetworkTasks.removeAll()
    }
    
    /// Returns the list of products for a given category.
    ///
    /// - Parameters:
    ///   - categoyId: Given category of products.
    ///   - isRefresh: Flag that lets the server know to kill the cache or not.
    ///   - brandId: The brand id of the products in the query.
    /// - Returns: The network task that will obtain the products.
    @discardableResult
    func getProducts(_ categoyId: Int, isRefresh: Bool = false, brandId: String? = nil) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        
        self.currentCategoryId = categoyId
        
        // Easiest way to always update filtered plp with pull down to refresh
        return getProductsByFilter(isRefresh, withBrandId: brandId)
    }
    
    /// Returns the list of products for a given search string.
    ///
    /// - Parameters:
    ///   - searchString: The provided search string.
    ///   - isRefresh: Flag that lets the server know to kill the cache or not.
    /// - Returns: The network task that will obtain the products.
    @discardableResult
    func getProductsBySearch(_ searchString: String, isRefresh: Bool = false) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        
        if isRefresh {
            selectedPage = 1
        }
        self.currentKeyword = searchString
        return getProductsByFilter(isRefresh)
    }
    
    /// Returns a list of products by using a filter setup.
    ///
    /// - Parameters:
    ///   - filter: The filter setup provided .
    ///   - brandId: The brand id of the products to be returned.
    /// - Returns: The network task that will obtain the products.
    @discardableResult
    func getProductsByFilters(_ filter: PoqFilter, brandId: String? = nil) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        
        // Update selected filters
        filteredResult?.filter = filter
        
        // Reset to first page
        selectedPage = 1
        
        return getProductsByFilter(false, withBrandId: brandId )
    }
    
    /// Check wheter another page exists for infinite scrolling.
    ///
    /// - Returns: If the PLP should load more products in the list.
    func shouldLoadMoreProducts() -> Bool {
        
        if let currentPage = filteredResult?.paging?.currentPage,
            let totalPages = filteredResult?.paging?.totalPages, currentPage < Int(totalPages) {
            
            return true
        } else {
            
            return false
        }
    }
    
    /// Load the next page for filtered results.
    ///
    /// - Parameter brandId: Loads more products to the page based on a given brandId.
    /// - Returns: The network task that will obtain the products.
    @discardableResult
    func loadMoreProducts(_ brandId: String? = nil ) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        
        // Demand next page
        selectedPage += 1
        
        return getProductsByFilter(false, withBrandId: brandId)
    }
    
    /// Sort current filtered results by date.
    ///
    /// - Parameter brandId: Sorts the products in the list by date.
    /// - Returns: The network task that will retrieve the sorted products.
    @discardableResult
    func sortProductsByDate(_ brandId: String? = nil ) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        
        // Set sort field
        self.selectedSortField = PoqFilterSortField.DATE
        self.selectedSortType = PoqFilterSortType.DEFAULT
        
        // Reset to first page
        selectedPage = 1
        
        return getProductsByFilter(false, withBrandId: brandId)
    }
    
    /// Sort current filtered results by price.
    ///
    /// - Parameters:
    ///   - sortType: Toggle the sorting as asc or desc.
    ///   - brandId: The brand id of the products to be retrieved.
    /// - Returns: The network task that will retrieve the sorted products.
    @discardableResult
    func sortProductsByPrice(_ sortType: PoqFilterSortType, brandId: String? = nil) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        
        // Set type and field
        self.selectedSortField = PoqFilterSortField.PRICE
        self.selectedSortType = sortType
        
        // Reset to first page
        selectedPage = 1
        
        return getProductsByFilter(false, withBrandId: brandId)
    }
    
    /// Sort current filtered results by rating.
    ///
    /// - Parameters:
    ///   - sortType: Wether the sorting is asc or descending.
    ///   - brandId: The brand id of the sorted products.
    /// - Returns: The network task that returns the sorted products by rating.
    @discardableResult
    func sortProductsByRating(_ sortType: PoqFilterSortType, brandId: String? = nil) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        
        // Set type and field
        self.selectedSortField = PoqFilterSortField.RATING
        self.selectedSortType = sortType
        
        // Reset to first page
        selectedPage = 1
        
        return getProductsByFilter(false, withBrandId: brandId)
    }
    
    /// Sort current filtered results by seller
    ///
    /// - Parameters:
    ///   - sortType: Wether the sorting is asc or descending.
    ///   - brandId: The brand id of the sorted products.
    /// - Returns: The network task that returns the sorted products by seller.
    @discardableResult
    func sortProductsBySeller(_ sortType: PoqFilterSortType, brandId: String? = nil) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        
        // Set type and field
        self.selectedSortField = PoqFilterSortField.SELLER
        self.selectedSortType = sortType
        
        // Reset to first page
        selectedPage = 1
        
        return getProductsByFilter(false, withBrandId: brandId)
    }
    
    /// Queries the products by filter.
    ///
    /// - Parameters:
    ///   - isRefresh: Wether or not the server needs to kill the cache and return fresh data.
    ///   - brandId: The brand id of the filters.
    /// - Returns: The network task that returns the products.
    @discardableResult
    open func getProductsByFilter(_ isRefresh: Bool = false, withBrandId brandId: String? = nil ) -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        
        guard let filter =  filteredResult?.filter else {
            // Usually it will be first call - since we don't have filter object, which we should get from server
            let userId: String = User.getUserId()
            let categoryId: Int = self.currentCategoryId ?? 0
            
            if let validBrandId = brandId {
                return PoqNetworkService(networkTaskDelegate: self).getProductsByCategory(userId, categoryId: categoryId, externalId: externalId, brandId: validBrandId)
            } else {
                
                let filter = PoqFilter()
                
                // Set sorting params
                filter.selectedSortType = selectedSortType
                filter.selectedSortField = selectedSortField
                selectedPage = 1
                
                // Set searching params
                if let categoryId = currentCategoryId {
                    filter.categoryId = "\(categoryId)"
                }
                
                if let keyword = currentKeyword {
                    filter.keyword = keyword
                }
                
                if let productListViewController = viewControllerDelegate as? ProductListViewController {
                    productListViewController.resetTable()
                }
                
                return PoqNetworkService(networkTaskDelegate: self).getProductsByFilter(withUserId: User.getUserId(), filter: filter, page: selectedPage, externalId: externalId)
            }
        }
        // Set sorting params
        
        filter.selectedSortType = selectedSortType
        filter.selectedSortField = selectedSortField
        
        // Set searching params
        if let categoryId = self.currentCategoryId {
            filter.categoryId = "\(categoryId)"
        }
        
        if let keyword = self.currentKeyword {
            filter.keyword = keyword
        }
        
        if isRefresh {
            filter.isRefreshed = isRefresh
            selectedPage = 1
        }
        
        if selectedPage == 1 {
            // We load first page - so remove all products from screen
            if let productListViewController: ProductListViewController = viewControllerDelegate as? ProductListViewController {
                productListViewController.resetTable()
            }
        }

        if let validBrandId = brandId {
            return PoqNetworkService(networkTaskDelegate: self).getProductsByFilter(User.getUserId(), filter: filter, page: selectedPage, externalId: externalId, brandId: validBrandId)
        } else {
            return PoqNetworkService(networkTaskDelegate: self).getProductsByFilter(withUserId: User.getUserId(), filter: filter, page: selectedPage, externalId: externalId)
        }
    }
    
    /// Checks to see if the PLP should render a promotion banner.
    ///
    /// - Returns: Wether or not to render the promotion banner.
    public func hasPromotionBanner() -> Bool {
        guard let firstBlock = contentBlocks.first else {
            return false
        }
        
        return firstBlock.type == .promotionBanner
    }

    /// Returns wether or not to hide the no items label depending on the number of products in the list.
    ///
    /// - Returns: Wether or not to hide the no items label.
    func hideNoItemsLabel() -> Bool {
        return self.products.count != 0
    }
    
    /// Callback before start of the async network task.
    ///
    /// - Parameter networkTaskType: The network task type that completed.
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if self.isLoadingFirstTime {
        
            // Call super to show activity indicator
            super.networkTaskWillStart(networkTaskType)
            
            self.isLoadingFirstTime = false
        }
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /// Callback after async network task is completed.
    ///
    /// - Parameters:
    ///   - networkTaskType: The network task type that completed.
    ///   - result: The result of the request.
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Call super to hide activity indicator
        // Send empty result list for avoind memory issues
        super.networkTaskDidComplete(networkTaskType, result: [])
        
        // PLP filtered products
        if result != nil {
            
            if networkTaskType == PoqNetworkTaskType.productsByCategory || networkTaskType == PoqNetworkTaskType.productsByFilters || networkTaskType == PoqNetworkTaskType.productsByQuery {
                if let result = result as? [PoqFilterResult] {
                    filteredResult = result[0]
                }
                
                if let filteredResult = filteredResult, let paging = filteredResult.paging {
                    totalItemsCount = paging.totalResults
                }
                if let filteredResult = filteredResult, let filteredProducts = filteredResult.products {
                    
                    if selectedPage < 2 {
                        
                        // Pulldown to refresh might have been called
                        // To avoid duplicate products, we need to refresh the list
                        products.removeAll()
                        contentBlocks.removeAll()
                    }
                    
                    if filteredProducts.count != 0 {
                        
                        updatedRange = products.count..<(products.count + filteredProducts.count)
                        products.append(contentsOf: filteredProducts)
                    } else {
                        
                        updatedRange = nil
                    }
                    
                    if let validContentBlocks = filteredResult.contentBlocks, validContentBlocks.count > 0 {
                        contentBlocks.append(contentsOf: validContentBlocks)
                    }

                    Log.verbose("filteredProducts.count : \(filteredProducts.count)")
                    // Send back network request result to view controller
                    viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
                } else {
                   
                    // Send back network request result to view controller
                    viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: nil)
                }
            } else {
                // Other type
                // Send back network request result to view controller
                viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
            }
        } else {
            // Send back network request result to view controller
            viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: nil)
        }
    }
    
    /// Callback when task fails due to lack of internet etc.
    ///
    /// - Parameters:
    ///   - networkTaskType: The type of task that failed.
    ///   - error: The error acompanying the failure.
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
    
    /// Sets up the content of the toolbar in the PLP. The buttons that allow for sorting in the list.
    func setupToolbarContent() {
        let featured = ToolbarContentItem(
            type: ToolbarItemType.featured,
            isAvailable: AppSettings.sharedInstance.plpFeaturedSortingOptionAvailable,
            title: AppLocalization.sharedInstance.plpFeaturedText,
            position: AppSettings.sharedInstance.plpFeaturedSortingOptionPosition
        )
        
        let newest = ToolbarContentItem(
            type: ToolbarItemType.newest,
            isAvailable: AppSettings.sharedInstance.plpNewestSortingOptionAvailable,
            title: AppLocalization.sharedInstance.plpNewestText,
            position: AppSettings.sharedInstance.plpNewestSortingOptionPosition
        )
        
        let rating = ToolbarContentItem(
            type: ToolbarItemType.rating,
            isAvailable: AppSettings.sharedInstance.plpRatingSortingOptionAvailable,
            title: AppLocalization.sharedInstance.plpRatingText,
            position: AppSettings.sharedInstance.plpRatingSortingOptionPosition
        )
        
        let price = ToolbarContentItem(
            type: ToolbarItemType.price,
            isAvailable: AppSettings.sharedInstance.plpPriceSortingOptionAvailable,
            title: AppLocalization.sharedInstance.plpPriceDownText,
            position: AppSettings.sharedInstance.plpPriceSortingOptionPosition
        )
        
        let seller = ToolbarContentItem(
            type: ToolbarItemType.seller,
            isAvailable: AppSettings.sharedInstance.plpSellerSortingOptionAvailable,
            title: AppLocalization.sharedInstance.plpSellerText,
            position: AppSettings.sharedInstance.plpSellerSortingOptionPosition
        )
        
        toolbarContent = [featured, newest, rating, price, seller]
            .filter({ $0.isAvailable && !$0.title.isEmpty })
            .sorted(by: { (lhs: ToolbarContentItem, rhs: ToolbarContentItem) in
                return lhs.position < rhs.position
            })
    }
}
