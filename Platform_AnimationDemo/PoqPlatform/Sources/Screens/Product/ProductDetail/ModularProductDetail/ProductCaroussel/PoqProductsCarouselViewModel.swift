//
//  PoqProductsCarouselViewModel.swift
//  Poq.iOS.Platform
//
//  Created by Mohamed Arradi on 17/05/2017.
//
//

import Foundation
import PoqNetworking

public class PoqProductsCarouselViewModel: PoqProductsCarouselService {
    
    public var isLoading: Bool = false
    
    weak public var presenter: PoqProductsCarouselPresenter?
    public var contentBlocks = [PoqPromotionBlock]()
    public var products = [PoqProduct]()
    
    public init(viewedProduct productId: Int?) {
        
        fetchRecentlyViewedProducts(forCurrentlyViewed: productId)
        observeChangeProducts()
    }
    
    public init(products: [PoqProduct]) {
        self.products = products
        observeChangeProducts()
    }
    
    fileprivate func observeChangeProducts() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: recentlyViewedProductsDidClearAll), object: nil, queue: nil) {
            [weak self] (_) in
            
            DispatchQueue.main.async {
                
                self?.products = []
                
                self?.presenter?.updateProductCarousel()
            }
        }
    }
}
