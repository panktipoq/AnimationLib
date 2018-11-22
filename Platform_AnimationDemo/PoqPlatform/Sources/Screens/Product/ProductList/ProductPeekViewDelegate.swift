//
//  ProductPeekViewDelegate.swift
//  Poq.iOS.Platform
//
//  Created by Rachel McGreevy on 05/06/2017.
//
//

import Foundation
import PoqUtilities
import PoqAnalytics
import UIKit

open class ProductPeekViewDelegate: NSObject, UIViewControllerPreviewingDelegate {
    
    public var parentProductViewController: PoqBaseViewController
    public var collectionView: UICollectionView
    public var viewModel: PeekProductsProvider
    
    public init(parentProductViewController: PoqBaseViewController, collectionView: UICollectionView, viewModel: PeekProductsProvider) {
        self.parentProductViewController = parentProductViewController
        self.collectionView = collectionView
        self.viewModel = viewModel
    }
    
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return nil }
        guard let cellAttributes = collectionView.layoutAttributesForItem(at: indexPath) else { return nil }
        let cell = collectionView.cellForItem(at: indexPath) as? ProductListViewCell
        
        let peekViewController = ProductListViewPeek(nibName: "ProductListViewPeek", bundle: nil)
        peekViewController.product = viewModel.products[indexPath.row]
        peekViewController.parentProductListViewController = parentProductViewController
        peekViewController.parentProductCellViewLikeButton = cell?.likeButton
        previewingContext.sourceRect = cellAttributes.frame
        
        return peekViewController
    }
    
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        let peekViewController = viewControllerToCommit as? ProductListViewPeek
        
        guard let product = peekViewController?.product else {
            Log.error("No product to navigate to PDP with")
            return
        }
        
        if let title = product.title, let id = product.id {
            PoqTrackerHelper.trackPeekLoadPDP(title, skuLabel: String(describing: id))
            PoqTrackerV2.shared.peekAndPop(action: PeekAndPopAction.details.rawValue, productId: id, productTitle: title)
        }
        
        guard let relatedProductIds = product.relatedProductIDs, relatedProductIds.count > 0 else {
            if let productId = product.id {
                NavigationHelper.sharedInstance.loadProduct(productId, externalId: product.externalID, source: ViewProductSource.peekForceTouch.rawValue, productTitle: product.title)
            }
            return
        }
        
        if let bundleId = product.bundleId, !bundleId.isEmpty {
            NavigationHelper.sharedInstance.loadBundledProduct(using: product)
        } else {
            NavigationHelper.sharedInstance.loadGroupedProduct(with: product)
        }
    }
}
