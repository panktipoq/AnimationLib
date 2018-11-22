//
//  TinderViewModel.swift
//  Poq.iOS
//
//  Created by Jun Seki on 21/01/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import Haneke
import Koloda
import PoqNetworking
import PoqUtilities
import PoqAnalytics

// Used for the sort below where both sides are optional.. id > id
private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    case (_?, nil):
        return true
    default:
        return false
    }
}

open class TinderViewModel: BaseViewModel {
    
    fileprivate enum ProductFeedType {
        
        case allProducts
        case productsInCategory
    }
    
    fileprivate let isFirstTimeLoadKey: String = "TinderIsFirstTimeLoadKey"
    fileprivate let lastProductIDForProductsInCategoryKey: String = "TinderLastProductIDForProductsInCategoryKey"
    fileprivate let lastProductIDForAllProductsKey: String = "TinderLastProductIDForAllProductsKey"
    
    fileprivate var productFeedType: ProductFeedType = ProductFeedType.productsInCategory
    
    fileprivate var count: Int = 0
    fileprivate var categoryId: Int = 0
    
    // TODO: Create a network call to warm up cache
    fileprivate var remainingCardTresholdForFetch = 5
    
    open var productFeed: [PoqProduct] = []
    
    open var cardImageURLByIndex = [Int: String]()
    
    // MARK: - Init
    // ________________________
    
    // Used for avoiding optional checks in viewController
    override init() {
        
        super.init()
    }
    
    override init(viewControllerDelegate: PoqBaseViewController) {
        
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network tasks
    open func getProductsInCategory() {
        
        let lastProductId = getLastProductId(lastProductIDForProductsInCategoryKey)
        getProductFeed(lastProductId: lastProductId, isRefresh: true)
    }
    
    open func getNextSetOfProducts(isRefresh: Bool = false) {
        
        // Because the products in feed is randomized order,
        // we need to get the biggest in the current deck to load more (oldest to newest)
        // Newer products have always bigger IDs
        let lastProductId = getBiggestProductIdInFeed()
        getProductFeed(lastProductId: lastProductId, isRefresh: isRefresh)
    }
    
    fileprivate func getProductFeed(lastProductId: Int, isRefresh: Bool = false) {
        
        switch productFeedType {
            
        case .allProducts:
            PoqNetworkService(networkTaskDelegate: self).getTinderProducts(lastProductId: lastProductId, count: count, isRefresh: isRefresh)
            
        case .productsInCategory:
            PoqNetworkService(networkTaskDelegate: self).getTinderProductsInCategory(categoryId: categoryId, lastProductId: lastProductId, count: count, isRefresh: isRefresh)
        }
    }
    
    open func sendLikeForIndex(_ index: Int) {
        
        guard index < productFeed.count else {
            
            return
        }
        
        WishlistController.shared.add(product: productFeed[index])
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
    Callback before start of the async network task
    */
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        // Don't show spinner for like operation
        if networkTaskType != PoqNetworkTaskType.tinderLike {
            
            super.networkTaskWillStart(networkTaskType)
            viewControllerDelegate?.networkTaskWillStart(networkTaskType)
        }
    }
    
    /**
    Callback after async network task is completed
    */
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        super.networkTaskDidComplete(networkTaskType, result:[])
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.tinderProducts, PoqNetworkTaskType.tinderProductsInCategory:
            processProducts(result)
            
        case PoqNetworkTaskType.tinderLike:
            processLikeResult(result)
            
        default:
            Log.warning("undefined networkTaskType")
        }
        
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        super.networkTaskDidFail(networkTaskType, error: error)
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
}

// MARK: - Tinder operations
// __________________________

extension TinderViewModel {
    
    // TODO: Unit test
    fileprivate func processProducts(_ result: [Any]?) {
        
        guard let networkResult = result as? [PoqProduct], networkResult.count > 0 else {
            
            Log.verbose("⚠️ no results found for the new product feed")
            Log.verbose("👉 Redirecting to get products from all products")
            // Instead of showing a blank screen
            // user is redirected to see some more products
            // To avoid showing user the same product again
            // Get refreshed data (a new random order)
            productFeedType = .allProducts
            getNextSetOfProducts(isRefresh:true)
            
            sendTrackingSwitchProductFeedType()
            sendTrackingEndOfDeck()
            
            return
        }
        
        productFeed = networkResult
    }
    
    // TODO: Unit test
    fileprivate func processLikeResult(_ result: [Any]?) {
        
        guard let networkResult = result as? [PoqMessage], networkResult.count > 0 else {
            
            return
        }
        
        // TODO: Process status code and message, send as analytics event
        // TODO: Increase badge count for wishlist?
        // TODO: Update local wishlist items with productID?
        Log.verbose("networkResult[0].statusCode = \(String(describing: networkResult[0].statusCode))")
    }
    
    open func cardViewForIndex(_ koloda: KolodaView, index: UInt) -> UIView {
        
        guard Int(index) < productFeed.count else {
            
            return emptyCardView()
        }
        
        guard let validPictureURL = productFeed[Int(index)].pictureURL, let validRemotePictureURL = URL(string: validPictureURL) else {
            
            return emptyCardView()
        }
        
        let imageView = PoqAsyncImageView(frame: koloda.frame)
        
        imageView.getImageFromURL(validRemotePictureURL, isAnimated:false)
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.backgroundColor = UIColor.white.cgColor
        imageView.clipsToBounds = true
        
        saveImageURLForIndex(index:Int(index), urlPath:validPictureURL)
        
        return imageView
    }
    
    fileprivate func saveImageURLForIndex(index: Int, urlPath: String) {
        
        cardImageURLByIndex[Int(index)] = urlPath
    }
    
    open func removeImageFromCacheForIndex(_ index: Int) {
        
        guard let imageURL = cardImageURLByIndex[index] else {
            
            Log.warning("Couldn't find image url for \(index)")
            return
        }
        
        let cache = Shared.imageCache
        
        cache.remove(key: imageURL)
        
    }
    
    fileprivate func emptyCardView() -> UIView {
        
        // TODO: Ask for a design
        return UIImageView(image: UIImage(named: "smile-done"))
    }
    
    open func updateCardDetailsForIndex(titleLabel: UILabel, priceLabel: UILabel, index: UInt) {
        
        guard index < UInt(productFeed.count) else {
            
            return
        }
        
        // TODO: Update label texts with attributed style using cloud theme
        // TODO: Unit test
        let product = productFeed[Int(index)]
        
        titleLabel.text = product.title
        priceLabel.attributedText = LabelStyleHelper.initPriceLabel(product.price, specialPrice:product.specialPrice, priceFormat:AppSettings.sharedInstance.tinderPriceFormat)
        priceLabel.font = UIFont(name: priceLabel.font.fontName, size: CGFloat(AppSettings.sharedInstance.tinderPriceFontSize))
    }
    
    // TODO: Unit test
    open func updateLastProductIDForIndex(_ index: Int) {
        
        guard index < productFeed.count else {
            
            return
        }
        
        guard let productID = productFeed[index].id else {
            
            return
        }
        
        switch productFeedType {
            
        case .allProducts:
            saveLastProductIdForAllProducts(productID)
            
        case .productsInCategory:
            saveLastProductId(productID)
        }
    }
    
    open func openProductDetailForIndex(_ index: Int) {
        
        guard index < productFeed.count else {
            
            return
        }
        
        let product = productFeed[index]
        
        guard let productId = product.id else {
            
            return
        }
        
        NavigationHelper.sharedInstance.loadProduct(productId, externalId: product.externalID, source: ViewProductSource.swipe2Hype.rawValue, productTitle: product.title)
        sendTrackingOpenPDP(productId)
    }
    
}

// MARK: - First time load operations
// _________________________________

extension TinderViewModel {
    
    open func setupCloudParameters() {
        
        count = Int(AppSettings.sharedInstance.tinderNumberOfProductsToFetch)
        
        if let categoryIdValue = Int(AppSettings.sharedInstance.tinderProductCategoryID) {
            
            categoryId = categoryIdValue
        }
    }
    
    open func isFirstTimeLoad() -> Bool {
        
        guard let isFirstTimeLoad = UserDefaults.standard.value(forKey: isFirstTimeLoadKey) as? Bool else {
            
            // Key not found, user is expected to see landing image
            return true
        }
        
        return isFirstTimeLoad
    }
    
    open func setFirstTimeLoad() {
        
        // Set isFirstTimeLoadKey false so the user should never see the landing image
        let userDefaults = UserDefaults.standard
        userDefaults.set(false, forKey: isFirstTimeLoadKey)
        userDefaults.synchronize()
    }
    
    open func loadFirstTimeImage(_ imageView: PoqAsyncImageView, firstTimeLoadImageURL: String) {
        
        // Sometimes image urls could include invalid characters due to realtime API Integrations
        // In this case, the images would come from 3rd party 
        // Otherwise, our MBImageProcessor is expected to create valid URLs always!
        guard let validImageURL = URL(string: firstTimeLoadImageURL) else {
            
            return
        }
        
        imageView.getImageFromURL(validImageURL, isAnimated: true)
    }
    
    fileprivate func saveLastProductId(_ productID: Int) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(productID, forKey: lastProductIDForProductsInCategoryKey)
        userDefaults.synchronize()
    }
    
    fileprivate func saveLastProductIdForAllProducts(_ productID: Int) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(productID, forKey: lastProductIDForAllProductsKey)
        userDefaults.synchronize()
    }
    
    fileprivate func getLastProductId(_ key: String) -> Int {
        
        guard let lastProductIdValue = UserDefaults.standard.value(forKey: key) as? Int else {
            
            return 0
        }
        
        return lastProductIdValue
    }
    
    fileprivate func getBiggestProductIdInFeed() -> Int {
        
        guard let biggestProductIdInFeed = productFeed.sorted(by: { $0.id > $1.id }).first?.id else {
            
            switch productFeedType {
                
            case .productsInCategory:
                return getLastProductId(lastProductIDForProductsInCategoryKey)
                
            case .allProducts:
                return getLastProductId(lastProductIDForAllProductsKey)
            }
        }
        
        return biggestProductIdInFeed
    }
}

// MARK: - Tracking
// ________________

extension TinderViewModel {
    
    open func sendTrackingSwipeToLike() {
        
        PoqTrackerHelper.trackSwipeToHype(PoqTrackerActionType.ActionLike, label: PoqTrackerLabelType.ValueSwipe)
    }
    
    open func sendTrackingTapToLike() {
        
        PoqTrackerHelper.trackSwipeToHype(PoqTrackerActionType.ActionLike, label: PoqTrackerLabelType.ValueTap)
    }
    
    open func sendTrackingSwipeToDislike() {
        
        PoqTrackerHelper.trackSwipeToHype(PoqTrackerActionType.ActionDislike, label: PoqTrackerLabelType.ValueSwipe)
    }
    
    open func sendTrackingTapToDislike() {
        
        PoqTrackerHelper.trackSwipeToHype(PoqTrackerActionType.ActionDislike, label: PoqTrackerLabelType.ValueTap)
    }
    
    open func sendTrackingEndOfDeck() {
        
        switch productFeedType {
            
        case .allProducts:
            sendTrackingEndOfProducts()
            
        case .productsInCategory:
            sendTrackingEndOfProductsInCategory()
        }
    }
    
    open func sendTrackingEndOfProductsInCategory() {
        
        PoqTrackerHelper.trackSwipeToHype(PoqTrackerActionType.ActionEndOfDeckInCategory, label: String(categoryId))
    }
    
    open func sendTrackingEndOfProducts() {
        
        // This event should be very rare!
        PoqTrackerHelper.trackSwipeToHype(PoqTrackerActionType.ActionEndOfDeckInProducts, label: String(getLastProductId(lastProductIDForAllProductsKey)))
    }
    
    open func sendTrackingSwitchProductFeedType() {
        
        PoqTrackerHelper.trackSwipeToHype(PoqTrackerActionType.ActionSwitchToAllProductsFeed, label: String(categoryId))
    }
    
    open func sendTrackingOpenPDP(_ productID: Int) {
        
        PoqTrackerHelper.trackSwipeToHype(PoqTrackerActionType.ActionOpenPDP, label: String(productID))
    }
}
