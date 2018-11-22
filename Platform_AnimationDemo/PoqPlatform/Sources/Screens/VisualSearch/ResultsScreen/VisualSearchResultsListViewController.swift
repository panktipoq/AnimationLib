//
//  VisualSearchResultsListViewController.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 12/03/2018.
//

import Foundation
import PoqNetworking
import PoqAnalytics
import PoqUtilities

public typealias PoqVisualSearchImageAnalyticsData = (source: VisualSearchImageSource, crop: Bool)

open class VisualSearchResultsListViewController: PoqBaseViewController, VisualSearchResultsPresenter, UICollectionViewDataSource, UICollectionViewDelegate, ProductListViewCellDelegate {
    
    public static let visualSearchResultsCollectionViewAccessibilityId = "visualSearchResultsCollectionViewAccessibilityId"
    
    let visualSearchImage: UIImage
    @IBOutlet public weak var collectionView: UICollectionView?
    var peekViewDelegate: UIViewControllerPreviewingDelegate?
    let poqVisualSearchImageAnalyticsData: PoqVisualSearchImageAnalyticsData
    lazy public var viewModel: VisualSearchResultsService = VisualSearchResultsViewModel(presenter: self)
    /// View that is displayed when no products are available.
    open var productListNoSearchResultsView: ProductListNoSearchResultsView?
    /// This is the IBOutlet that will display what's inside productListNoSearchResultsView.
    @IBOutlet open weak var noSearchResultsView: UIView?
    
    public init(image: UIImage, imageAnalyticsData: PoqVisualSearchImageAnalyticsData) {
        visualSearchImage = image
        poqVisualSearchImageAnalyticsData = imageAnalyticsData
        super.init(nibName: VisualSearchResultsListViewController.XibName, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.accessibilityIdentifier = VisualSearchResultsListViewController.visualSearchResultsCollectionViewAccessibilityId
        collectionView?.isAccessibilityElement = true

        initNavigationBar()
        setCellRegistration()
        // Only fetch the products if we have a valid image and we don't have any products already.
        guard viewModel.products.count == 0 else {
            displayResults(for: viewModel.resultsMode)
            return
        }
        viewModel.fetchVisualSearchResults(forImage: visualSearchImage)
        PoqTrackerHelper.trackVisualSearchImageSubmission(forSource: poqVisualSearchImageAnalyticsData.source.rawValue)
        PoqTrackerV2.shared.visualSearchSubmit(forSource: poqVisualSearchImageAnalyticsData.source.rawValue, cropped: poqVisualSearchImageAnalyticsData.crop)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateVisibleCellsWishlistIcons()
    }
    
    // MARK: - VisualSearchResultsPresenter
    
    open func initNavigationBar() {
        // Set up navigation title
        navigationItem.titleView = nil
        setNavigationBarTitle(AppLocalization.sharedInstance.visualSearchResultsViewControllerNavigationTitle)
        // Set up the back button
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        
        // Enable edge swipe back
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    open func setNavigationBarTitle(_ title: String) {
        navigationItem.title = title
    }
    
    open func shouldShowNoSearchResultViews(_ show: Bool) {
        if productListNoSearchResultsView == nil {
            let productView = ProductListNoSearchResultsView(frame: noSearchResultsView.flatMap({ CGRect(origin: .zero, size: $0.frame.size) }) ?? .zero)
            noSearchResultsView?.addSubview(productView)
            productListNoSearchResultsView = productView
            productListNoSearchResultsView?.productPeekOwnerViewController = self
        }
        noSearchResultsView?.isHidden = !show
        productListNoSearchResultsView?.update(withString: AppLocalization.sharedInstance.visualSearchNoResultsText)
    }
    
    open func displayResults(for mode: ResultsMode) {
        guard let collectionViewFlowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            Log.error("Collection view flow layout is not found.")
            return
        }
        switch viewModel.resultsMode {
        case .singleCategory:
            peekViewDelegate = registerForPeekPreview(collectionView: collectionView, viewModel: viewModel)
            collectionViewFlowLayout.itemSize = ProductListViewCell.cellSize(PoqProduct(), cellInsets: UIEdgeInsets.zero)
        case .multipleCategory:
            collectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        case .noResults:
            shouldShowNoSearchResultViews(true)
        }
        if let title = viewModel.categoryTitle() {
            setNavigationBarTitle(title)
        }
        collectionView?.reloadData()
    }

    open func setCellRegistration() {
        collectionView?.registerPoqCells(cellClasses: [ProductListViewCell.self, PoqProductsCarouselCategoryCell.self])
    }
    
    // MARK: - ProductPeekPresenter
    
    open func peekViewDelegate(parentProductViewController: PoqBaseViewController, collectionView: UICollectionView, viewModel: PeekProductsProvider) -> ProductPeekViewDelegate? {
        return ProductPeekViewDelegate(parentProductViewController: parentProductViewController, collectionView: collectionView, viewModel: viewModel)
    }
    
    // MARK: - PoqPresenter
    
    open func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        displayResults(for: viewModel.resultsMode)
    }
    
    open func error(_ networkError: NSError?) {
        // This function will be triggered when there is an error in the network request
        shouldShowNoSearchResultViews(true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cell(for: viewModel.resultsMode, collectionView: collectionView, cellForItemAt: indexPath)
    }
    
    open func cell(for mode: ResultsMode, collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch mode {
        case .singleCategory:
            return singleCategoryCell(collectionView, cellForItemAt: indexPath)
        case .multipleCategory:
            return multipleCategoryCell(collectionView, cellForItemAt: indexPath)
        case .noResults:
            return UICollectionViewCell()
        }
    }
    
    open func multipleCategoryCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PoqProductsCarouselCategoryCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        cell.presenter = self
        cell.setup(with: viewModel.categories[indexPath.row])
        return cell
    }
    
    open func singleCategoryCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProductListViewCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        cell.delegate = self
        cell.updateView(viewModel.products[indexPath.row])
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Only recognise the tap when single category because the multicategory tap is recognised by the carousel
        if viewModel.resultsMode == .singleCategory,
             viewModel.products.count > 0 {
            let product = viewModel.products[indexPath.row]
            guard let productId = product.id else {
                return
            }
            NavigationHelper.sharedInstance.loadProduct(productId, externalId: product.externalID, topViewController: self, source: ViewProductSource.visualSearch.rawValue, productTitle: product.title)
        }
    }
    
    // MARK: - VisualSearchResultsPresenter
    
    open func viewAllProducts(for category: PoqVisualSearchItem) {
        let visualSearchResultsListViewController = VisualSearchResultsListViewController(image: visualSearchImage, imageAnalyticsData: poqVisualSearchImageAnalyticsData)
        visualSearchResultsListViewController.viewModel = VisualSearchResultsViewModel(poqVisualSearchItem: category)
        NavigationHelper.sharedInstance.openController(visualSearchResultsListViewController)
    }

    // MARK: - ProductListViewCellDelegate
    
    public func toggleExpandedProduct(_ product: PoqProduct) { /* Delegate required here but not used for now */ }
    
    public func getIsPromoExpanded(_ productId: Int) -> Bool {
        return false
    }
}
