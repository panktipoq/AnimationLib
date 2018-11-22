//
//  PoqCarousselProductService.swift
//  Poq.iOS.Platform
//
//  Created by Mohamed Arradi on 15/05/2017.
//
//

import Foundation
import PoqNetworking

public protocol PoqProductsCarouselService: PoqNetworkTaskDelegate, PeekProductsProvider {
    
    var presenter: PoqProductsCarouselPresenter? { get set }
    
    var products: [PoqProduct] { get set }
    
    var isLoading: Bool { get set }
    
    func fetchRecentlyViewedProducts(forCurrentlyViewed productId: Int?)
}

extension PoqProductsCarouselService {
    
    // MARK: - NetworkCarousselConfiguration
    
    public func fetchRecentlyViewedProducts(forCurrentlyViewed productId: Int? = nil) {
   
        isLoading = true
        PoqDataStore.store?.getAll() {
            [weak self]
            (recentlyViewedProducts: [RecentlyViewedProduct]) in
            guard let selfStrong = self, recentlyViewedProducts.count > 0 else {                
                self?.isLoading = false
                self?.presenter?.update(state: .completed, networkTaskType: PoqNetworkTaskType.recentlyViewed)
                return
            }
            
            let postBody = PoqRecentlyViewedPostBody(recentlyViewedProducts: recentlyViewedProducts)
            
            PoqNetworkService(networkTaskDelegate: selfStrong).getRecentlyViewedProducts(with: postBody, excluding: productId)
        }
    }
    
    func clearRecentlyViewedProducts() {
        
        PoqDataStore.store?.deleteAll(forObjectType: RecentlyViewedProduct(), completion: { (error) in
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: recentlyViewedProductsDidClearAll), object: nil)
            }
        })
        
        products.removeAll()
        
        PoqNetworkService(networkTaskDelegate: self).clearRecentlyViewedProducts()
        
        presenter?.updateProductCarousel()
        
    }

    // MARK: - Network Task Callbacks
    
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        presenter?.update(state: .loading, networkTaskType: networkTaskType)
    }
    
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        isLoading = false
        if let productsResult = result as? [PoqProduct] {
            
            products = productsResult
        }
        
        presenter?.update(state: .completed, networkTaskType: networkTaskType)
    }
    
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        isLoading = false
        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
    }
    
}
