//
//  BrandedProductListViewController.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 20/06/2016.
//
//

import Foundation
import PoqNetworking
import PoqAnalytics
import UIKit

final class BrandedProductListViewController: ProductListViewController {
    
    final override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(BrandedCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: BrandedHeaderReuseIdentifier)
                
        collectionView?.registerPoqCells(cellClasses: [BrandedProductListViewCell.self])
        
        filtersButton = nil
        
        navigationItem.setRightBarButton(nil, animated: true)
    }
    
    final override func initExtensionView() {
        
        extensionViewContainerHeight?.constant = 0
    }
    
    final override func initToolBar() {
    }
    
    final override func initNavigationBar() {

        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        navigationItem.titleView = NavigationBarHelper.setupTruncatedTitleView(selectedCategoryTitle.uppercased(), titleFont: AppTheme.sharedInstance.brandedPageTitleFont)
    }
    
    final override func loadProducts(_ isRefresh: Bool) {
        viewModel.externalId = selectedExternalCategoryId
        viewModel.getProducts(selectedCategoryId, isRefresh: isRefresh)
    }

// MARK: - UICollectionView Delegates
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return BrandedHeaderView.calculateSize(poqNavigationController?.brandStory?.findBrandedHeader())
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }

        let view: UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BrandedHeaderReuseIdentifier, for: indexPath)
        
        if let brandedHeader: BrandedCollectionHeaderView = view as? BrandedCollectionHeaderView {
            brandedHeader.headerBlock = poqNavigationController?.brandStory?.findBrandedHeader()
        }
        
        return view
    }
    
    // Set cell size
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let products: [PoqProduct] = viewModel.products
        guard indexPath.row < products.count else {
            return CGSize.zero
        }
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let cellInsets = flowLayout?.sectionInset ?? UIEdgeInsets.zero
        return BrandedProductListViewCell.cellSize(products[indexPath.row], cellInsets: cellInsets)
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let products: [PoqProduct] = viewModel.products
        guard indexPath.row < products.count else {
            return UICollectionViewCell()
        }

        let cell: BrandedProductListViewCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.updateView(products[indexPath.item])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let products = viewModel.products
        
        guard indexPath.row < products.count else {
            return
        }
        
        let product = products[indexPath.row]
        
        guard product.relatedProductIDs != nil else {
            if let productID = product.id {
                NavigationHelper.sharedInstance.loadProduct(productID, externalId: product.externalID, source: ViewProductSource.brandedPLP.rawValue, productTitle: product.title)
            }
            
            return
        }
        
        NavigationHelper.sharedInstance.loadGroupedProduct(with: product)
    }

}

// MARK: UICollectionViewDelegateFlowLayout
extension BrandedProductListViewController {
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard section == 0 else {
            return 0
        }
        // TODO: this constant 5 - must be pard of app settings
        return 5
    }
}
