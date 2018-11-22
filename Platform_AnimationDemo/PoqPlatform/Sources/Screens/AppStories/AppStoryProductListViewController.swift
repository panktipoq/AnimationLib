//
//  AppStoryProductListViewController.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 9/8/17.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

open class AppStoryProductListViewController: PoqBaseViewController, SheetContentViewController, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout, UIToolbarDelegate, PoqPresenter, ProductListPresenter {
    
    weak public var containerViewController: SheetContainerViewController? 
    
    @IBOutlet weak var toolBar: UIToolbar?
    @IBOutlet open weak var collectionView: UICollectionView?
    
    public let viewModel: AppStoryCardProductListViewModel
    public init(viewModel: AppStoryCardProductListViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: "AppStoryProductListView", bundle: nil)
        
        viewModel.presenter = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchProducts()
        toolBar?.items = createToolbarItems()
        toolBar?.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar?.isTranslucent = false
        
        collectionView?.registerPoqCells(cellClasses: [PoqProductsCarouselCell.self])
        
        // Add shadow to toolbar
        let shadowImage = UIImage.getImageWithColor(UIColor.black.colorWithAlpha(0.3), size: CGSize(width: 100, height: 1.0/UIScreen.main.scale))
        toolBar?.setShadowImage(shadowImage, forToolbarPosition: .any)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateVisibleCellsWishlistIcons()
    }
    
    @IBAction open func closeButtonAction(_ sender: UIButton?) {
        containerViewController?.dismiss(animated: true)
    }
    
    // MARK: - SheetContentViewController
    
    public var action: SheetContainerViewController.ActionButton? {
        return nil
    }
    
    /// Cycles through all of the visible cells in the collection view and updates the wishlist icon
    public func updateVisibleCellsWishlistIcons() {
        
        guard let visibleCells = collectionView?.visibleCells as? [PoqProductsCarouselCell] else {
            Log.error("No visible cells of type ProductListViewCell")
            return
        }
        
        for cell in visibleCells {
            cell.updateWishlistIconStatus()
        }
    }
    
    public func calculateSize(for maxSize: CGSize) -> CGSize {

        let ratio = CGFloat(AppSettings.sharedInstance.productsCarouselImageRatio)
        let cellWidth = maxSize.width/2
        let cellHeight = cellWidth/ratio + CGFloat(AppSettings.sharedInstance.productsCarouselTextAreaHeight)
        
        var areaHeight: CGFloat 
        if viewModel.storyCard.productIds.count < 3 {
            areaHeight = cellHeight
        } else if viewModel.storyCard.productIds.count < 5 {
            areaHeight = 2 * cellHeight
        } else {
            areaHeight = maxSize.height
        }
        
        areaHeight += 44 // Toolbar height
        
        if areaHeight > maxSize.height {
            areaHeight = maxSize.height
        }
        
        return CGSize(width: maxSize.width, height: areaHeight)
    }
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.products.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PoqProductsCarouselCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        cell.setup(using: viewModel.products[indexPath.row], showLikeButton: true)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let product = viewModel.products[indexPath.row]
        
        guard let externalProductId = product.externalID, let internalProductId = product.id else {
            
            Log.error("Product with nil external and internal ID's found. Cannot open PDP")
            return
        }
        
        let productId = PoqProductID(internalProductId: internalProductId, externalProductId: externalProductId)
        
        let viewController = AppStoryProductInfoViewController(with: AppStoryCardProductInfoViewModel(with: productId))
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ratio = CGFloat(AppSettings.sharedInstance.productsCarouselImageRatio)
        let cellWidth = collectionView.bounds.size.width/2
        let cellHeight = cellWidth/ratio + CGFloat(AppSettings.sharedInstance.productsCarouselTextAreaHeight)
        return CGSize(width: cellWidth, height: cellHeight )
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    // MARK: - PoqPresenter
    public func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        collectionView?.reloadData()
    }
    
    // MARK: - UIToolbarDelegate
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .top
    }
    
    // MARK: - Toolbar
    
    open func createToolbarItems() -> [UIBarButtonItem] {
        
        let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpaceItem.width = 0
        
        // Title item
        let titleLabel = UILabel()
        titleLabel.text = viewModel.storyCard.title
        titleLabel.font = AppTheme.sharedInstance.appStoryProductListTitleFont
        titleLabel.textColor = AppTheme.sharedInstance.appStoryProductListTitleTextColor
        titleLabel.sizeToFit()
        let titleItem = UIBarButtonItem(customView: titleLabel)
        
        let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let cancelButton = UIButton(type: .system)
        cancelButton.titleLabel?.font = AppTheme.sharedInstance.appStoryProductListCancelButtonFont
        cancelButton.setTitleColor(AppTheme.sharedInstance.appStoryProductListCancelButtonTextColor, for: .normal)
        cancelButton.setTitle("CANCEL".localizedPoqString, for: .normal)
        cancelButton.sizeToFit()
        cancelButton.addTarget(self, action: #selector(AppStoryProductListViewController.closeButtonAction(_:)), for: .touchUpInside)
        let cancelButtonItem = UIBarButtonItem(customView: cancelButton)

        return [fixedSpaceItem, titleItem, flexibleSpaceItem, cancelButtonItem]
    }
}
