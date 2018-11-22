//
//  ProductPeekPresenter.swift
//  Poq.iOS.Platform
//
//  Created by Rachel McGreevy on 08/06/2017.
//
//

import Foundation
import PoqNetworking
import UIKit

public protocol PeekProductsProvider {
    var products: [PoqProduct] { get }
    var contentBlocks: [PoqPromotionBlock] { get }
}

extension ProductListViewModel: PeekProductsProvider {
    
}

public protocol ProductPeekPresenter {
    var viewControllerForProductPeek: UIViewController? { get }
    func peekViewDelegate(parentProductViewController: PoqBaseViewController, collectionView: UICollectionView, viewModel: PeekProductsProvider) -> ProductPeekViewDelegate?
}

extension ProductPeekPresenter {
    
    public func registerForPeekPreview(collectionView: UICollectionView?, viewModel: PeekProductsProvider?) -> UIViewControllerPreviewingDelegate? {
        let isForceTouchCapabilityAvailable = viewControllerForProductPeek?.traitCollection.forceTouchCapability == .available
        guard let viewController = viewControllerForProductPeek as? PoqBaseViewController, let collectionView = collectionView, let viewModel = viewModel, let peekViewDelegate = peekViewDelegate(parentProductViewController: viewController, collectionView: collectionView, viewModel: viewModel), isForceTouchCapabilityAvailable else {
            return nil
        }
        viewController.registerForPreviewing(with: peekViewDelegate, sourceView: collectionView)
        return peekViewDelegate
    }
    
    public func peekViewDelegate(parentProductViewController: PoqBaseViewController, collectionView: UICollectionView, viewModel: PeekProductsProvider) -> ProductPeekViewDelegate? {
        return ProductPeekViewDelegate(parentProductViewController: parentProductViewController, collectionView: collectionView, viewModel: viewModel)
    }
}

extension ProductPeekPresenter where Self: UIViewController {
    public var viewControllerForProductPeek: UIViewController? {
        return self
    }

}
