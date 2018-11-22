//
//  PoqCatalogueTrackable.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 09/11/2017.
//

import Foundation

public protocol PoqCatalogueTrackable {
    func viewProduct(productId: Int, productTitle: String, source: String)
    func viewProductList(categoryId: Int, categoryTitle: String, parentCategoryId: Int)
    func viewSearchResults(keyword: String, type: String, result: String)
    func addToBag(quantity: Int, productId: Int, productTitle: String, productPrice: Double, currency: String)
    func addToWishlist(quantity: Int, productTitle: String, productId: Int, productPrice: Double, currency: String)
    func share(productId: Int, productTitle: String)
    func barcodeScan(type: String, result: String, ean: String, productId: Int, productTitle: String)
    func sortProducts(type: String)
    func filterProducts(type: String, colors: String, categories: String, sizes: String, brands: String, styles: String, minPrice: Int, maxPrice: Int)
    func peekAndPop(action: String, productId: Int, productTitle: String)
    func fullScreenImageView(productId: Int, productTitle: String)
    func readReviews(productId: Int, numberOfReviews: Int)
    func videoPlay(productId: Int, productTitle: String)
    func visualSearchSubmit(forSource: String, cropped: Bool)
    func visualSearchResults(forResult: String, numberOfCategories: Int)
}

extension PoqCatalogueTrackable where Self: PoqAdvancedTrackable {
    
    public func viewProduct(productId: Int, productTitle: String, source: String) {
        let productInfo: [String: Any] = [TrackingInfo.productId: productId, TrackingInfo.productTitle: productTitle, TrackingInfo.source: source]
        logEvent(TrackingEvents.Catalogue.viewProduct, params: productInfo)
    }
    
    public func viewProductList(categoryId: Int, categoryTitle: String, parentCategoryId: Int) {
        let categoryInfo: [String: Any] = [TrackingInfo.categoryId: categoryId, TrackingInfo.categoryTitle: categoryTitle, TrackingInfo.parentCategoryId: parentCategoryId]
        logEvent(TrackingEvents.Catalogue.viewProductList, params: categoryInfo)
    }
    
    public func viewSearchResults(keyword: String, type: String, result: String) {
        let searchInfo: [String: Any] = [TrackingInfo.keyword: keyword, TrackingInfo.type: type, TrackingInfo.result: result]
        logEvent(TrackingEvents.Catalogue.viewSearchResults, params: searchInfo)
    }
    
    public func addToBag(quantity: Int, productId: Int, productTitle: String, productPrice: Double, currency: String) {
        let productInfo: [String: Any] = [TrackingInfo.quantity: quantity, TrackingInfo.productId: productId, TrackingInfo.productTitle: productTitle, TrackingInfo.price: productPrice, TrackingInfo.currency: currency]
        logEvent(TrackingEvents.Catalogue.addToBag, params: productInfo)
    }
    
    public func addToWishlist(quantity: Int, productTitle: String, productId: Int, productPrice: Double, currency: String) {
        let productInfo: [String: Any] = [TrackingInfo.quantity: quantity, TrackingInfo.productTitle: productTitle, TrackingInfo.productId: productId, TrackingInfo.price: productPrice, TrackingInfo.currency: currency]
        logEvent(TrackingEvents.Catalogue.addToWishlist, params: productInfo)
    }
    
    public func share(productId: Int, productTitle: String) {
        let productInfo: [String: Any] = [TrackingInfo.productId: productId, TrackingInfo.productTitle: productTitle]
        logEvent(TrackingEvents.Catalogue.share, params: productInfo)
    }
    
    public func barcodeScan(type: String, result: String, ean: String, productId: Int, productTitle: String) {
        let productInfo: [String: Any] = [TrackingInfo.type: type, TrackingInfo.result: result, TrackingInfo.ean: ean, "item_id": productId, "item_name": productTitle]
        logEvent(TrackingEvents.Catalogue.barcodeScan, params: productInfo)
    }
    
    public func sortProducts(type: String) {
        let sortInfo: [String: Any] = [TrackingInfo.type: type]
        logEvent(TrackingEvents.Catalogue.sortProducts, params: sortInfo)
    }
    
    public func filterProducts(type: String, colors: String, categories: String, sizes: String, brands: String, styles: String, minPrice: Int, maxPrice: Int) {
        let filterInfo: [String: Any] = [TrackingInfo.type: type, TrackingInfo.colors: colors, TrackingInfo.categories: categories, TrackingInfo.sizes: sizes, TrackingInfo.brands: brands, TrackingInfo.styles: styles, TrackingInfo.minPrice: minPrice, TrackingInfo.maxPrice: maxPrice]
        logEvent(TrackingEvents.Catalogue.filterProducts, params: filterInfo)
    }
    
    public func peekAndPop(action: String, productId: Int, productTitle: String) {
        let peekInfo: [String: Any] = [TrackingInfo.action: action, TrackingInfo.productId: productId, TrackingInfo.productTitle: productTitle]
        logEvent(TrackingEvents.Catalogue.peekAndPop, params: peekInfo)
    }
    
    public func fullScreenImageView(productId: Int, productTitle: String) {
        let productInfo: [String: Any] = [TrackingInfo.productId: productId, TrackingInfo.productTitle: productTitle]
        logEvent(TrackingEvents.Catalogue.fullScreenImageView, params: productInfo)
    }
    
    public func readReviews(productId: Int, numberOfReviews: Int) {
        let reviewInfo: [String: Any] = [TrackingInfo.productId: productId, TrackingInfo.reviewCount: numberOfReviews]
        logEvent(TrackingEvents.Catalogue.readReviews, params: reviewInfo)
    }
    
    public func videoPlay(productId: Int, productTitle: String) {
        let productInfo: [String: Any] = [TrackingInfo.productId: productId, TrackingInfo.productTitle: productTitle]
        logEvent(TrackingEvents.Catalogue.videoPlay, params: productInfo)
    }
    
    public func visualSearchSubmit(forSource: String, cropped: Bool) {
        let visualSearchSubmitInfo: [String: Any] = [TrackingInfo.source: forSource, TrackingInfo.crop: cropped]
        logEvent(TrackingEvents.Catalogue.visualSearchSubmit, params: visualSearchSubmitInfo)
    }
    
    public func visualSearchResults(forResult: String, numberOfCategories: Int) {
        let visualSearchResultsInfo: [String: Any] = [TrackingInfo.result: forResult, TrackingInfo.categories: numberOfCategories]
        logEvent(TrackingEvents.Catalogue.visualSearchResults, params: visualSearchResultsInfo)
    }
}
