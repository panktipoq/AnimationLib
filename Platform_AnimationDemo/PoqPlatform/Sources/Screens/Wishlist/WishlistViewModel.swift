//
//  WishlistViewModel.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/28/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics

/// Provides the data flow for the wishlist. TODO: This screen has a number of problems when rendering we need to bring it up to the newest architecture.
open class WishlistViewModel: BaseViewModel {
    
    // MARK: - Initializers
    /// The products that will be listed as wishlist items.
    open var wishListItems: [PoqProduct]
    /// Message being kept from a backend response.
    open var message: PoqMessage
    
    /// The current selected product.
    open var selectedProduct: PoqProduct?
    
    /// Flag if first time load or not.
    open var firstTimeItemsLoad: Bool = true
    
    /// Number of items per page of wishlist.
    var numberOfItemsFromLastRequest: Int = 0
    
    /// Flag that determines the wishlist is loading or not.
    open var loadingWishlistItems: Bool = false
    
    /// MB number of items per page of wishlist TODO: This needs to be refactored.
    public static var DefaultWishlistPageSize = Int(AppSettings.sharedInstance.wishListPageSize)

    override public init() {
        
        self.wishListItems = []
        self.message = PoqMessage()
        super.init()
    }
    
    /// Initializes the viewModel of the wishlist.
    ///
    /// - Parameter viewControllerDelegate: The delegate of the wishlist view model. TODO: This controller needs to be converted to a presenter.
    override public init(viewControllerDelegate: PoqBaseViewController) {
        
        self.wishListItems = []
        self.message = PoqMessage()
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    // ______________________________________________________
    // MARK: - Basic network tasks
    // Reload products from first one.
    /// Fetches the wishlist item.
    ///
    /// - Parameter isRefresh: Wether or not to kill cache on backend and fetch the newly generated data.
    open func getWishList(_ isRefresh: Bool = false) {

        firstTimeItemsLoad = true

        var page: Int? = nil
        if AppSettings.sharedInstance.wishlistUsesPaginationApi {

            page = wishListItems.count/WishlistViewModel.DefaultWishlistPageSize + 1
        }
      
        PoqNetworkService(networkTaskDelegate: self).getWishList(User.getUserId(),
            storeId: String(StoreHelper.getFavoriteStoreId()),
            page: page,
            pageSize: WishlistViewModel.DefaultWishlistPageSize,
            isRefresh: isRefresh)
        loadingWishlistItems = true
    }
    
    /// Triggers load of next page.
    open func loadNextPage() {

        guard AppSettings.sharedInstance.wishlistUsesPaginationApi && !loadingWishlistItems else {
            return
        }
        
        let page: Int = wishListItems.count/WishlistViewModel.DefaultWishlistPageSize + 1
        PoqNetworkService(networkTaskDelegate: self).getWishList(User.getUserId(),
            storeId: String(StoreHelper.getFavoriteStoreId()),
            page: page,
            pageSize: WishlistViewModel.DefaultWishlistPageSize)
        loadingWishlistItems = true
    }
    
    /// Removes a wishlist item.
    ///
    /// - Parameters:
    ///   - item: The product that needs to be removed.
    ///   - completion: Called when the removal is completed.
    open func removeWishlistItem(_ item: PoqProduct, completion: ((_ removed: Bool) -> Void)?) {
        guard let index = wishListItems.index(where: { $0 === item }) else {
            completion?(false)
            return
        }

        guard let itemId = item.id else {
            Log.error("Invalid item id to delete wishlist item.")
            completion?(false)
            return
        }

        wishListItems.remove(at: index)
        WishlistController.shared.remove(productId: itemId)
        completion?(true)
    }
    
    /// Removes all the wishlist items.
    open func removeAllWishlistItems() {
        
        WishlistController.shared.remove()
        self.wishListItems = []
    }
    
    /// Gets the number of items in the wishlist.
    ///
    /// - Returns: The number of items in the wishlist.
    func getItemsCount() -> Int {
        return self.wishListItems.count
    }
    
    /// Returns wether the wishlist has items or not.
    ///
    /// - Returns: Wether the wishlist has items or not.
    open func hasWishListItems() -> Bool {
        
        return self.wishListItems.count != 0
    }
    
    /**
    Keep selected product and send request to get detail.
    */
    /// Retrieves the details of a single product. TODO: Rename this to getSelectedProduct or something more relevant.
    ///
    /// - Parameter product: The product that is about to be refetched from the backend.
    open func updateSelectedProduct (_ product: PoqProduct) {
        
        guard let productId: Int = product.id, let externalId: String = product.externalID else {
            Log.error("missed product id or external id")
            return
        }
        
        selectedProduct = product

        PoqNetworkService(networkTaskDelegate: self).getProductDetails(User.getUserId(), productId: productId, externalId: externalId)
    }
    
    //. TODO: why do we pass productSizeID if product.selectedSizeID must be set at the same time?
    /// Adds to bag a product with a given productSizeId.
    ///
    /// - Parameters:
    ///   - product: The product that is added to the bag.
    func addToBag(_ product: PoqProduct) {
        
        guard let selectedSizeId = product.selectedSizeID else {
            assertionFailure("No selectedSizeID to add to bag")
            return
        }
        
        BagHelper.addToBag(delegate: self, selectedSizeId: selectedSizeId, in: product)
    }
    
    // MARK: - Pagination
    /// Returns wether or not the screen needs to load more products.
    ///
    /// - Returns: Wether or not the screen needs to load more products.
    func shouldLoadMoreProducts() -> Bool {
       
        guard AppSettings.sharedInstance.wishlistUsesPaginationApi else {
            return false
        }
        
        return numberOfItemsFromLastRequest == WishlistViewModel.DefaultWishlistPageSize
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
    Callback before start of the async network task.
    */
    /// Triggered when the network task will start.
    ///
    /// - Parameter networkTaskType: The task type that will start.
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /**
    Callback after async network task is completed
    */
    /// Called when a network task has completed
    ///
    /// - Parameters:
    ///   - networkTaskType: The type of network task that completed.
    ///   - result: The mapped response of the request.
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Call super to hide activity indicator
        super.networkTaskDidComplete(networkTaskType, result: [])
        
        if let existedResults = result {
            
            if networkTaskType == PoqNetworkTaskType.getWhishList {
                loadingWishlistItems = false
                
                if firstTimeItemsLoad {
                    wishListItems = (existedResults as? [PoqProduct]) ?? []
                    
                } else if networkTaskType == PoqNetworkTaskType.deleteWishList {

                    // Do nothing if user delete too fast. networking request return should not update to the new lists
                    // E.g. if i delete 100->80 , after networking completes, it jumps back to 90.
                    // TODO: need some discussion
                } else {
                    
                    // We should avoid duplication here
                    // Duplication is a result of loading more page, from odd count of items. For example - we load 10, remove 1.
                    // New we load more, when we have 9 items, for us this is fisrt page
                    // We have to make this n*n, can't see better way
                    let products = existedResults as? [PoqProduct]
                    products?.forEach({ product in
                        let found = wishListItems.contains(where: { $0.id == product.id })
                        
                        if found == false {
                            wishListItems.append(product)
                        }
                    })
                }
                
                firstTimeItemsLoad = false
                numberOfItemsFromLastRequest = existedResults.count
                
                WishlistController.shared.fetchProductIds()
            } else if networkTaskType == PoqNetworkTaskType.postBag {
                guard let validResult = result else {
                    return
                }
                if let firstMessage = validResult.first as? PoqMessage {
                    message = firstMessage
                    if BagHelper.isStatusCodeOK(message.statusCode) {
                        BagHelper.incrementBagBy(1)
                    }
                }
            } else if networkTaskType == PoqNetworkTaskType.postCartItems {
            
                BagHelper.incrementBagBy(1)
            
            } else if networkTaskType == PoqNetworkTaskType.productDetails {
                
                if let updatedProduct: PoqProduct = result?.first as? PoqProduct {
                    selectedProduct = updatedProduct
                }
            } else if networkTaskType == PoqNetworkTaskType.deleteAllWishList {
                PoqTrackerV2.shared.clearWishlist()
            }
        }
        
        // Send back network request result to view controller
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    /// Called when a network request fails.
    ///
    /// - Parameters:
    ///   - networkTaskType: The type of task that failed.
    ///   - error: The error associated with the failure.
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        if networkTaskType == PoqNetworkTaskType.getWhishList {
            loadingWishlistItems = false
        }
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
}
