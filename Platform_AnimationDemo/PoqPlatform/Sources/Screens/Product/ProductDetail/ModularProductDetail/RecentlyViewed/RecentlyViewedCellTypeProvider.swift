//
//  RecentlyViewedCellTypeProvider.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 4/10/17.
//
//

import Foundation

public struct RecentlyViewedCellTypeProvider: PoqProductDetailCellTypeProvider {
    
    public var service: PoqProductsCarouselService
    
    public var cellClass: UICollectionViewCell.Type {
        return PoqRecentlyViewedContentBlockCell.self
    }
    
    public init(service: PoqProductsCarouselService) {
        self.service = service
    }
}
