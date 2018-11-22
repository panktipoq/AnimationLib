//
//  ProductListPresenter.swift
//  PoqPlatform
//
//  Created by Rachel McGreevy on 1/15/18.
//

import PoqUtilities

public protocol ProductListPresenter {
    var collectionView: UICollectionView? { get set }
    func updateVisibleCellsWishlistIcons()
}

extension ProductListPresenter {
    /// Cycles through all of the visible cells in the collection view and updates the wishlist icon
    public func updateVisibleCellsWishlistIcons() {
        
        guard let visibleCells = collectionView?.visibleCells as? [ProductListViewCell] else {
            Log.error("No visible cells of type ProductListViewCell")
            return
        }
        
        for cell in visibleCells {
            cell.updateWishlistIconStatus(cell.product?.id)
        }
    }
    
}
