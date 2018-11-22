//
//  PoqRecentlyViewedPostBodyExtension.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 4/5/17.
//
//

import Foundation
import PoqNetworking

public extension PoqRecentlyViewedPostBody {
    
    init(recentlyViewedProducts: [RecentlyViewedProduct]) {
        
        var postProducts = [PoqRecentlyViewedPostBodyProduct]()
        
        for product in recentlyViewedProducts {
            let viewedProduct = PoqRecentlyViewedPostBodyProduct(recentlyViewedProduct: product)
            
            postProducts.append(viewedProduct)
        }
        
        self.recentlyViewedProducts = postProducts
    }
}

public extension PoqRecentlyViewedPostBodyProduct {
    
    init(recentlyViewedProduct: RecentlyViewedProduct) {
        productId = recentlyViewedProduct.productId
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        lastViewed = dateFormatter.string(from: recentlyViewedProduct.date)
    }
}
