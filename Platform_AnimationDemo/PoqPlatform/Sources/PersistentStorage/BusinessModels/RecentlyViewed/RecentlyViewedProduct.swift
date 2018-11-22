//
//  RecentlyViewedProduct.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 4/5/17.
//
//

import Foundation
import RealmSwift

public let maxNumberOfRecentlyViewedProducts: Int = 250
public let recentlyViewedProductsDidClearAll = "RecentlyViewedProductsDidClearAll"

public struct RecentlyViewedProduct {
    public var productId: Int = 0
    public var date: Date = Date()
    
    public init() {}
}
