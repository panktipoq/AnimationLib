//
//  RecentlyViewedProductListViewController.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 5/2/17.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

open class RecentlyViewedProductListViewController: PoqBaseViewController, PoqProductsCarouselPresenter, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ProductListViewCellDelegate, ProductPeekPresenter, ProductListPresenter {

    public func peekViewDelegate(parentProductViewController: PoqBaseViewController, collectionView: UICollectionView, viewModel: PeekProductsProvider) -> ProductPeekViewDelegate? {
        return ProductPeekViewDelegate(parentProductViewController: parentProductViewController, collectionView: collectionView, viewModel: viewModel)
    }

    @IBOutlet public weak var collectionView: UICollectionView?

    @IBOutlet var noProductsView: UIView? {
        didSet {
            noProductsView?.isHidden = true
        }
    }

    @IBOutlet var noProductsLabel: UILabel? {
        didSet {
            noProductsLabel?.text = AppLocalization.sharedInstance.recentlyViewedText
            noProductsLabel?.font = AppTheme.sharedInstance.noItemsLabelFont
            noProductsLabel?.textColor = AppTheme.sharedInstance.noItemsLabelColor
        }
    }

    public var viewModel: PoqProductsCarouselService?

    fileprivate var refreshControl: UIRefreshControl = UIRefreshControl()

    var peekViewDelegate: UIViewControllerPreviewingDelegate?

    open override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()

        refreshControl.addTarget(self, action: #selector(reloadViewedProducts), for: .valueChanged)

        collectionView?.refreshControl = refreshControl
        collectionView?.registerPoqCells(cellClasses: [ProductListViewCell.self])

        if viewModel == nil {
            viewModel = PoqProductsCarouselViewModel(viewedProduct: nil)
        }

        viewModel?.presenter = self

        peekViewDelegate = registerForPeekPreview(collectionView: collectionView, viewModel: viewModel)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateVisibleCellsWishlistIcons()
    }

    func initNavigationBar() {

        // Set up navigation title
        navigationItem.titleView = nil
        navigationItem.title = AppLocalization.sharedInstance.recentlyViewControllerNavigationTitle

        // Set up the back button
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)

        // Enable edge swipe back
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        // Create clear bar button
        navigationItem.rightBarButtonItem = NavigationBarHelper.createButtonItem(withTitle: AppLocalization.sharedInstance.clearOptionText, target: self, action: #selector(promptClearAll))
    }

    // MARK: - IBAction

    @objc func reloadViewedProducts() {

        viewModel?.fetchRecentlyViewedProducts(forCurrentlyViewed: nil)
    }

    @IBAction fileprivate func promptClearAll() {

        guard let products = viewModel?.products, products.count > 0 else {
            return
        }

        let confirmAlertController = UIAlertController.init(title: "", message: AppLocalization.sharedInstance.recentlyViewControllerPromptAlertTitle, preferredStyle: UIAlertControllerStyle.alert)

        confirmAlertController.addAction(UIAlertAction.init(title: "NO".localizedPoqString, style: UIAlertActionStyle.default, handler: nil))

        confirmAlertController.addAction(UIAlertAction.init(title: "YES".localizedPoqString, style: UIAlertActionStyle.default, handler: { [weak self] (alertaction: UIAlertAction) in
            self?.viewModel?.clearRecentlyViewedProducts()
            self?.updateUI()
        }))

        present(confirmAlertController, animated: true)
    }

    // MARK: - PoqPresenter
    public func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {

        collectionView?.reloadData()

        refreshControl.endRefreshing()

        updateUI()
    }

    func updateUI() {

        let show: Bool = viewModel?.products.count == 0

        navigationItem.rightBarButtonItem?.isEnabled = !show
        noProductsView?.isHidden = !show
    }

    // MARK: - UICollectionViewDataSource

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return viewModel?.products.count ?? 0
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProductListViewCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)

        if let product = viewModel?.products[indexPath.row] {
            cell.updateView(product)

            // Assign delegate only on cell which have a product
            cell.delegate = self
        }

        return cell
    }

    // MARK: - UICollectionViewDelegate

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let product = viewModel?.products[indexPath.row], let productId = product.id else {
            return
        }

        NavigationHelper.sharedInstance.loadProduct(productId, externalId: product.externalID, topViewController: self, source: ViewProductSource.recentlyViewedPLP.rawValue, productTitle: product.title)
    }
    // MARK: - UICollectionViewDelegateFlowLayout

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let product = viewModel?.products[indexPath.row] else {
            return CGSize.zero
        }

        return ProductListViewCell.cellSize(product, cellInsets: UIEdgeInsets.zero)
    }

    public func toggleExpandedProduct(_ product: PoqProduct) { /* Delegate required here but not used for now */ }

    public func getIsPromoExpanded(_ productId: Int) -> Bool {
        return false
    }
}
