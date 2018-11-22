//
//  ProductGroupedListViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 26/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

/**
 
 ProductGroupedListViewController is a variant of the traditional PLP
 The view consists of a collection view that renders given products.
 The view renders like a traditional PLP the diffrence is that the products here are part of the same product bundle.
 Its architecture is MVVM and its model is lazy loaded to conserve memory until the model is needed.
 TODO: We need to migrate this to the new service presenter approach
 ## Usage Example: ##
 ````
 let viewController = ProductGroupedListViewController(nibName: "ProductGroupedListView", bundle: nil)
 ````
 */
open class ProductGroupedListViewController: PoqBaseViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, ProductListViewCellDelegate, UIGestureRecognizerDelegate {
    
    /// The ids of the products that are showing promo overlays.
    fileprivate var productsShowingPromos: Array<Int> = Array()

    /// The collection view that renders the list.
    @IBOutlet public weak var collectionView: UICollectionView!
    
    /// The identifier of the product cell.
    var cellIdentifier = "ProductListViewCell"
    
    /// The header of the collection view header.
    var headerIdentifier = "CollectionViewHeader"
    
    /// The left padding of the collection view. TODO: Unused - remove.
    var paddingLeft = 0.0
    
    /// The right padding of the collection view. TODO: Unused - remove.
    var paddingRight = 0.0
    
    /// The top padding of the collection view. TODO: Unused - remove.
    var paddingTop = 0.0
    
    /// The bottom padding of the collection view. TODO: Unused - remove.
    var paddingBottom = 0.0
    
    /// The width of the thumbnail of a product. TODO: Unused - remove.
    var productThumbnailWidth = 320.0
    
    /// The height of the thumbnail of a product. TODO: Unused - remove.
    var productThumbnailHeight = 380.0
    
    /// The initial height of the overlay. TODO: Unused - remove.
    var productThumbnailDescriptionAreaHeight = 60.0
    
    /// The height of the header containing gPLP information of the product.
    open var headerHeight = 100.0

    /// The column spacing inside the collection view.
    static let columnSpacing: CGFloat = 0.0
    
    /// The row spacing inside the collection view.
    static let rowSpacing: CGFloat = CGFloat(AppSettings.sharedInstance.plpGroupedProductCollectionViewRowSpacing)
    
    /// The view model that handles the generation of the gPLP cells.
    open var viewModel: ProductGroupedListViewModel?
    
    /// The grouped product that the products here belong to.
    open var groupedProduct: PoqProduct?
    
    /// The price in string of the grouped product. TODO: Ideally handle this as a formatted string TBD on the action.
    open var groupedProductPrice: String?
    
    /// Triggered when the view finished loading. Initializes the viewModel, registers the correct cells, sets up the navigation bar and fetches the data required to render the screen.
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        guard groupedProduct != nil else {
            Log.error("Attempt to open groupedProductViewController without providing the grouped product")
            return
        }
        
        initializeViewModel()
        initViewController()
        initNavigationBar()
        getData()
    }
    
    /// Initializes the view model that handles the data in this viewcontroller.
    func initializeViewModel() {
        self.viewModel = ProductGroupedListViewModel(viewControllerDelegate: self)
    }
    
    /// Starts the network request that fetches the gPLP data.
    func getData() {
        
        guard let relatedExternalProductIds = groupedProduct?.relatedExternalProductIDs, !relatedExternalProductIds.isEmpty else {
            
            Log.info("No relatedExternalProductIds to fetch grouped products. Trying with relatedProductIds")
            
            guard let relatedProductIds = groupedProduct?.relatedProductIDs else {
                Log.error("No relatedProductIds to fetch grouped products")
                return
            }
            
            // Init view model and load first page of products in selected category
                viewModel?.getProducts(withIDs: relatedProductIds)
            return
        }
        
        viewModel?.getProducts(withIDs: relatedExternalProductIds)
        
    }
    
    /// Sets up the cell registration for the view controller and the collection view background color.
    open func initViewController() {
        
        // Init viewcollection
        // Register viewcell
        
        collectionView?.registerPoqCells(cellClasses: [ProductListViewCell.self])
        
        // Register header

        collectionView?.registerPoqCell(ProductGroupedListViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        
        // Set collection background
        collectionView?.backgroundColor = AppTheme.sharedInstance.plpGroupedProductCollectionViewBackgroundColor
    }
    
    /// Sets up the navigation bar.
    open func initNavigationBar() {
        
        var navigationTitle = ""
        // Set navigation bar
        
        if AppSettings.sharedInstance.showFixedParentProductTitleOnGPLP == true {
            
            navigationTitle = AppLocalization.sharedInstance.groupedPLPParentProductTitle
            
        } else if let groupedProductBrand = groupedProduct?.brand, !groupedProductBrand.isEmpty {

           navigationTitle = groupedProductBrand

        } else if let groupedProductTitle = groupedProduct?.title {
            
            navigationTitle = groupedProductTitle
        }
        
        self.navigationItem.titleView = NavigationBarHelper.setupTitleView(navigationTitle)
        
        // Log product list load
        let params = ["CategoryName:" : groupedProduct?.brand ?? ""]
        PoqTrackerHelper.trackGroupProductListLoad(navigationTitle, extraParams: params)
        
        //set up the back button
        self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        self.navigationItem.rightBarButtonItem = nil
        
        //enabel edge swipe back
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled=true
        
    }
    
    /// Triggered when the view has appeared. TODO: To be removed.
    ///
    /// - Parameter animated: Wether or not the appearance was animate.
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    /// Triggered when a network request has started
    ///
    /// - Parameter networkTaskType: The type of network requet that started. 
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        // Stub
    }
    
    /// Called when a network request is completed
    ///
    /// - Parameters:
    ///   - networkTaskType: The network task type that completed
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if networkTaskType == PoqNetworkTaskType.productsByIds || networkTaskType == PoqNetworkTaskType.productsByBundle || networkTaskType == PoqNetworkTaskType.productsByExternalIds {
        
            if let prices = viewModel!.filteredResult?.filter?.prices {
                
                if prices.count > 0 {
                    
                    let fromPrice = Double(prices[0])
                    let toPrice = Double(prices[1])
                    groupedProductPrice = String(format: "From \(CurrencyProvider.shared.currency.symbol)%.2f to \(CurrencyProvider.shared.currency.symbol)%.2f", fromPrice, toPrice)
                }
            }
            
            if let groupedProductUnwrapped = groupedProduct, let relatedProducts = viewModel?.products {
                PoqTracker.sharedInstance.trackGroupedProducts(forParent: groupedProductUnwrapped, products: relatedProducts)
            }
            
            self.collectionView.reloadData()
        
        }
    }
    
    /// Triggered when a network task has failed.
    ///
    /// - Parameters:
    ///   - networkTaskType: The type of network task that failed.
    ///   - error: The error that resulted from the failure.
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
    }
    
    /// Returns the number of items in a given collection view section.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view in discussion.
    ///   - section: The section for which the number of items needs to be returned.
    /// - Returns: The number of items in a gPLP collection view section.
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel!.products.count
    }
    
    /// Returns the cell for the collection view 
    ///
    /// - Parameters:
    ///   - collectionView: The collection view in discussion.
    ///   - indexPath: The indexpath of the.
    /// - Returns: The collection view.
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: ProductListViewCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.delegate = self
        // Use a random background color for UI pixel debugging
        cell.updateView(self.viewModel!.products[indexPath.item])
        return cell
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /// The size of the cell at a given path.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view in discussion.
    ///   - collectionViewLayout: The flow layout assigned to the collection view.
    ///   - indexPath: The indexpath of the requested cell.
    /// - Returns: The size of the requested cell at indexpath.
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let products: [PoqProduct] = viewModel?.products, indexPath.row < products.count else {
            return CGSize.zero
        }
        
        var insets = UIEdgeInsets()
        if let collectionViewLayoutFlow = collectionViewLayout as? UICollectionViewFlowLayout {
            insets = collectionViewLayoutFlow.sectionInset
        }
        return ProductListViewCell.cellSize(products[indexPath.row], cellInsets: insets)
    }
    
    /// The insets assigned to a given collection view cell.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view in discussion.
    ///   - collectionViewLayout: The flow layout of the given collection view.
    ///   - section: The section 
    /// - Returns: The edge insets of the collection view
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        var insets = UIEdgeInsets()
        if let collectionViewLayoutFlow = collectionViewLayout as? UICollectionViewFlowLayout {
            insets = collectionViewLayoutFlow.sectionInset
        }
        return insets
    }
    
    /// Returns the minimum spacing 
    ///
    /// - Parameters:
    ///   - collectionView: The collection view in discussion.
    ///   - collectionViewLayout: The flow layout assigned to the collection view.
    ///   - section: The section of the collection view 
    /// - Returns: TODO: Gabriel Sabiescu documentation
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return ProductGroupedListViewController.rowSpacing
        
    }
    
    /// TODO: Gabriel Sabiescu documentation
    ///
    /// - Parameters:
    ///   - collectionView: The collection view in discussion.
    ///   - collectionViewLayout: The view layout assigned to the collection view.
    ///   - section: The section of the collection view for which the spacing is requested.
    /// - Returns: The the space between to items inside the given section 
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return ProductGroupedListViewController.columnSpacing
    }
    
    /// TODO: Gabriel Sabiescu documentation
    ///
    /// - Parameters:
    ///   - collectionView: The collection view in discussion.
    ///   - kind: TODO: Gabriel Sabiescu documentation
    ///   - indexPath: TODO: Gabriel Sabiescu documentation
    /// - Returns: TODO: Gabriel Sabiescu documentation
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header: ProductGroupedListViewHeader = collectionView.dequeueReusablePoqSupplementaryViewOfKind(UICollectionElementKindSectionHeader, forIndexPath: indexPath)
        
        guard let groupedProductUnwrapped = groupedProduct else {
            Log.error("No groupedProduct to setup header with")
            return header
        }
        guard let groupedProductTitle = groupedProduct?.title else {
            Log.error("Not Product title in product. Cannot setup Header View")
            return header
        }
        
        let priceString = LabelStyleHelper.createPriceLabelText(groupedProductUnwrapped.priceRange, specialPriceRange: groupedProductUnwrapped.specialPriceRange, price: groupedProductUnwrapped.price, specialPrice: groupedProductUnwrapped.specialPrice)
        
        let specialPriceString = LabelStyleHelper.createSpecialPriceLabelText(groupedProductUnwrapped.priceRange, specialPriceRange: groupedProductUnwrapped.specialPriceRange, price: groupedProductUnwrapped.price, specialPrice: groupedProductUnwrapped.specialPrice, isClearance: groupedProductUnwrapped.isClearance)
        
        header.setupView(groupedProductUnwrapped.brand ?? "", productTitleString: groupedProductTitle, productRating: Float(groupedProductUnwrapped.rating ?? 0.0), productPriceString: priceString, productSpecialPriceString: specialPriceString, productImageUrLString: groupedProductUnwrapped.thumbnailUrl)
        
        return header
    }
    
    /// TODO: Gabriel Sabiescu documentation
    ///
    /// - Parameters:
    ///   - collectionView: The collection view in discussion.
    ///   - collectionViewLayout: The flow layout associated with the collectionview.
    ///   - section: TODO: Gabriel Sabiescu documentation
    /// - Returns: TODO: Gabriel Sabiescu documentation
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        if AppSettings.sharedInstance.isGroupedPLPShowingHeader == true {
            
            // Get screen width
            let bounds: CGRect = UIScreen.main.bounds
            width = bounds.size.width
            height = CGFloat(ProductGroupedListViewHeader.height)
        }

        return CGSize(width: width, height: height)
    }

    /// TODO: Gabriel Sabiescu documentation
    ///
    /// - Parameters:
    ///   - collectionView: The collection view in discussion.
    ///   - indexPath: TODO: Gabriel Sabiescu documentation
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let product: PoqProduct = viewModel?.products[indexPath.row] else {
            return
        }
        
        NavigationHelper.sharedInstance.loadProduct(product.id!, externalId: product.externalID, source: ViewProductSource.groupedPLP.rawValue, productTitle: product.title)
    }
    
    /// TODO: Gabriel Sabiescu documentation
    ///
    /// - Parameter productId: TODO: Gabriel Sabiescu documentation
    /// - Returns: TODO: Gabriel Sabiescu documentation
    open func getIsPromoExpanded(_ productId: Int) -> Bool {
        
        return productsShowingPromos.index(of: productId) != nil
    }
    
    /// TODO: Gabriel Sabiescu documentation
    ///
    /// - Parameter product: TODO: Gabriel Sabiescu documentation
    open func toggleExpandedProduct(_ product: PoqProduct) {
        
        if let productId = product.id {
            
            guard let promoExpandedIndex = productsShowingPromos.index(of: productId) else {
                productsShowingPromos.append( productId )
                return
            }
            
            productsShowingPromos.remove(at: promoExpandedIndex)
        }
    }
}
