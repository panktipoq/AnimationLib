//
//  ProductListViewController.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/20/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import AZDropdownMenu
import PoqModuling
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

public protocol InfiniteScrollable: AnyObject {
    
    /// Current page loading status
    var isLoading: Bool { get set }
    
    /// Business logic to decide the next page
    func loadNextPageIfNeeded() -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>?
}

public struct ProductListSortByValue {
    public static let Newest = AppLocalization.sharedInstance.plpNewestText
    public static let Featured = AppLocalization.sharedInstance.plpFeaturedText
    public static let PriceHighToLow = AppLocalization.sharedInstance.plpPriceDownText
    public static let PriceLowToHigh = AppLocalization.sharedInstance.plpPriceUpText
}

/**
  
 ProductListViewController is one of the main View Controllers in Poq applications which can normaly be found while navigating from a category or page view
 The view consists of a UICollectionView that contains a number of cells. These make up the rendering of the products in a infinite list fashion
 Its architecture is MVVM and its model is lazy loaded to conserve memory until the model is needed
 TODO: Future important change this screen will move to service/presenter approach as part of the platform modernisation.
 ## Usage Example: ##
 ````
 let viewController = ProductListViewController(nibName: "ProductListView", bundle: nil)
 ````
 */
open class ProductListViewController: PoqBaseViewController, ProductPeekPresenter, FilterViewControllerDelegate, ToolbarContentButtonItemDelegate, ProductListPresenter {
    
    /// Initializes the peekview delegate used for peek and pop.
    ///
    /// - Parameters:
    ///   - parentProductViewController: The view controller that will hold host the peek and pop view controller.
    ///   - collectionView: The collectionview that triggers the peek and pop.
    ///   - viewModel: The view model coresponding to the peek and pop view controller.
    /// - Returns: Delegate required to render the peek and pop view.
    open func peekViewDelegate(parentProductViewController: PoqBaseViewController, collectionView: UICollectionView, viewModel: PeekProductsProvider) -> ProductPeekViewDelegate? {
        return ProductPeekViewDelegate(parentProductViewController: parentProductViewController, collectionView: collectionView, viewModel: viewModel)
    }
    
    /// Array of product ids showing the promotion inside their cells.
    fileprivate var productsShowingPromos = [Int]()
    
    /// The items in the drop down menu of the PLP. This is one way of displaying the sorting options.
    var sortByDropDownMenu: AZDropdownMenu?

    /// Used for flagging a current loading phase - primarily used to circumvent empty pages issue.
    public var isLoading = false
    
    /// The instance of the button that opens the filter selection.
    open var filtersButton: UIBarButtonItem?
    
    /// The current brandId if the list belongs to a given brand.
    open var brandId: String?
    
    var collectionViewTag = 1
    // UI Outlets
    
    /// The collection view that renders the list of products.
    @IBOutlet public weak var collectionView: UICollectionView? {
        didSet {
            registerCollectionViewCells()
            collectionView?.backgroundColor = AppTheme.sharedInstance.plpCollectionViewBackgroundColor
            collectionView?.alwaysBounceVertical = true
            collectionView?.tag = collectionViewTag
        }
    }
    
    /// The products summary view.
    @IBOutlet var itemsSummaryView: UIView? {
        didSet {
            itemsSummaryView?.backgroundColor = AppTheme.sharedInstance.itemsSummaryViewBackgrounColor
        }
    }
    
    /// The label for no items in the PLP.
    @IBOutlet var noItemsLabel: UILabel? {
        didSet {
            noItemsLabel?.text = AppLocalization.sharedInstance.plpNoItemsText
            noItemsLabel?.font = AppTheme.sharedInstance.noItemsLabelFont
            noItemsLabel?.textColor = AppTheme.sharedInstance.noItemsLabelColor
        }
    }

    /// The container of the empty product PLP message.
    @IBOutlet weak var emptyView: UIView? {
        didSet {
            emptyView?.isHidden = true
        }
    }
    
    /// The retry button in case something went wrong or no products received.
    @IBOutlet weak var retryButton: RetryButton?
    
    /// The label that displays the number of items.
    @IBOutlet weak var itemCountLabel: UILabel!
    
    /// The label that displays the category of the current PLP.
    @IBOutlet weak var categoryLabel: UILabel! {
        didSet {
            categoryLabel.text = AppSettings.sharedInstance.plpCategoryNameLowercase ? selectedCategoryTitle.lowercased() : selectedCategoryTitle
        }
    }
    
    /// The view that toggles the drop down with the sorting options.
    @IBOutlet weak var sortByView: UIView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(ProductListViewController.showDropdown))
            sortByView.addGestureRecognizer(gesture)
        }
    }

    /// The label of the sorting options
    @IBOutlet public weak var sortByLabel: UILabel? {
        didSet {
            sortByLabel?.font = AppTheme.sharedInstance.plpSortLabelFont
            sortByLabel?.textColor = AppTheme.sharedInstance.plpSortLabelTextColor
            
            let sortByValue = sortTypes.first ?? ProductListSortByValue.Newest
            if sortByValue == ProductListSortByValue.Newest {
                sortByLabel?.accessibilityIdentifier = AccessibilityLabels.sortNewest
            } else if sortByValue == ProductListSortByValue.Featured {
                sortByLabel?.accessibilityIdentifier = AccessibilityLabels.sortFeatured
            }
            sortByLabel?.text = String(format: AppLocalization.sharedInstance.plpSortByLabelText, sortByValue)
        }
    }
    
    /// The button that opens the filter screen
    @IBOutlet weak var filterButton: UIButton? {
        didSet {
            filterButton?.titleLabel?.font = AppTheme.sharedInstance.plpFilterLabelFont
            filterButton?.setTitleColor(AppTheme.sharedInstance.plpFilterLabelNormalTextColor, for: UIControlState())
            filterButton?.setTitleColor(AppTheme.sharedInstance.plpFilterLabelDisabledTextColor, for: .disabled)
            filterButton?.setTitle(AppLocalization.sharedInstance.plpFiltersButtonText, for: UIControlState())
            filterButton?.addTarget(self, action: #selector(ProductListViewController.filterButtonClicked(_:)), for: .touchUpInside)
        }
    }
    
    /// View that is displayed when no products are available.
    open var productListNoSearchResultsView: ProductListNoSearchResultsView?
    
    /// This is the IBOutlet that will display what's inside productListNoSearchResultsView.
    @IBOutlet open weak var noSearchResultsView: UIView?
    
    /// The carousel view that show the recently viewed products.
    @IBOutlet weak var recentlyViewedProductsView: PoqProductsCarouselView?
    
    /// The sort types available for the sorting drop down.
    open var sortTypes: [String] {
        return [ProductListSortByValue.Newest, ProductListSortByValue.PriceHighToLow, ProductListSortByValue.PriceLowToHigh]
    }
    
    /// A container that holds the sorting options as a toolbar. The way that they are being rendered can be changed via mighty bot setting plpSortFiltersOnToolBarEnable.
    @IBOutlet open weak var productInformationView: UIView?
    
    /// The toolbars that holds the sotring options. TODO: This is not a good name should be sorting options.
    open var filtersToolbar: UIToolbar?
    
    /// The refresh control of the collection view.
    var refreshControl: UIRefreshControl?
    
    /// The originating view controller name of this list.
    open var source: String?
    
    /// Not used but will leave here for now. TODO: Check and see if this is actually used.
    var searchResults: PoqFilterResult?
    
    /// The view model for the PLP viewcontroller
    open lazy var viewModel = ProductListViewModel(viewControllerDelegate: self)
    
    /// The selected category that was the selected in the previous screen.
    open var selectedCategoryId: Int = 0
    
    /// The title of the selected category. TODO: Make this a little neater. Maybe like a specific object for this to pass both id title and externalCategoryId.
    open var selectedCategoryTitle: String = ""
    
    /// The external id of the category that was selected in the previous screen.
    open var selectedExternalCategoryId: String = ""
    
    /// The search query that generated this PLP.
    open var searchQuery: String?

    /// The search type that generated this PLP
    open var searchType: String?
    
    /// An array of indexPaths for the products fetched in the next page
    private var updatedProductsIndexPaths: [IndexPath] {
        return generateUpdatedProductsIndexPaths()
    }
    
    /// The identifier of the footer view.
    var footerIdentifier = "CollectionViewFooter"
    
    /// The height of the footer TODO: this needs to be removed and height needs to be put in the xib TODO: Make this magic number go away in future versions.
    static let footerHeight = 40.0
    
    /// The spacing between the columns.
    static let columnSpacing: CGFloat = 0.0
    
    /// The spacing between the rows.
    static let rowSpacing = CGFloat(AppSettings.sharedInstance.plpCollectionViewRowSpacing)
    
    /// The height of the extension view that holds the toolbar with the sorting options.
    open var extensionViewHeight: CGFloat {
        if AppSettings.sharedInstance.plpSortFiltersOnToolBarEnable {
            return 71
        } else {
            return 44
        }
    }
    
    /// The current sort type
    public var selectedSortType = ProductListSortByValue.Newest
    
    /// Flag that says if this is the first load.
    var firstLoad: Bool = true
    
    /// The container of the toolbar sorting options.
    @IBOutlet open var extensionViewContainer: UIView?
    
    /// The constraint for the container height. TODO: Make this cleaner.
    @IBOutlet open var extensionViewContainerHeight: NSLayoutConstraint?
    
    /// The container for the drop down menu sorting options.
    public var dropdownContainerView: PassThroughContainerView?
    
    /// The delegate for the peek and pop functionality
    var peekViewDelegate: UIViewControllerPreviewingDelegate?
    
    /// Triggers the first page loading of the products. Assigns the category id and keyword.
    override open func viewDidLoad() {
        super.viewDidLoad()
        initViewController()
        
        if let item = filtersToolbar?.items?.compactMap({ $0 as? ToolbarContentButtonItem }).first {
            viewModel.currentCategoryId = selectedCategoryId
            viewModel.currentKeyword = searchQuery
            
            toolbarContentButtonItem(item, tappedForType: item.contentItem.type)
        } else {
            WishlistController.shared.fetchProductIds { _ in
                self.loadProducts(false)
            }
        }
        
        peekViewDelegate = registerForPeekPreview(collectionView: collectionView, viewModel: viewModel)
    }
    
    open func generateUpdatedProductsIndexPaths() -> [IndexPath] {

        var updatedProductsIndexPaths = [IndexPath]()
        
        if let updatedRange = viewModel.updatedRange {
            
            for row in updatedRange {
                updatedProductsIndexPaths.append(IndexPath(row: row, section: 0))
            }
        }
        return updatedProductsIndexPaths
    }
    
    /// On appearance update wishlist icon status of any visible cells
    ///
    /// - Parameter animated: Whether or not appearance is animated
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        updateVisibleCellsWishlistIcons()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // To avoid problems when user navigates back from View All Recently Viewed products
        // This is because RV View Controller sets to true.
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    /// On disappearance cancel any current page task.
    ///
    /// - Parameter animated: Whether or not disappearance is animated.
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.cancelCurrentNetworkTaskIfExists()
    }
    
    /// Sets up the current view controller and preffered sorting option. TODO: This should be renamed to Setup probably.
    open func initViewController() {
        // Do any additional setup after loading the view.
        initNavigationBar()
        
        recentlyViewedProductsView?.isHidden = true
        
        initToolBar()
        initExtensionView()
        initRefreshControl()
        
        sortByDropDownMenu = buildSortByDropDownMenu()
        dropdownContainerView = createDropDownMenuContainer()
    }
    
    /// Registers the collectionview cells required to generate the PLP.
    open func registerCollectionViewCells() {
        collectionView?.registerPoqCells(cellClasses: [ProductListViewCell.self])
        collectionView?.registerPoqCell(ProductListViewFooterCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter)
    }
    
    /// Builds the sort drop down menu
    ///
    /// - Returns: Returns the dropdown menu with the sorting options.
    fileprivate func buildSortByDropDownMenu() -> AZDropdownMenu {
        
        selectedSortType = sortTypes.first ?? ProductListSortByValue.Newest
        
        let menu = AZDropdownMenu(titles: sortTypes)
        menu.cellTapHandler = { (indexPath: IndexPath) in
            self.selectedSortType = self.sortTypes[indexPath.row]
            
            // Hide itself first
            self.sortByDropDownMenu?.hideMenu()
            // Then change the value
            self.changeSortValuevalue()
        }
        menu.itemFontName = AppTheme.sharedInstance.plpSortLabelFont.fontName
        menu.itemFontSize = AppTheme.sharedInstance.plpSortLabelFont.pointSize
        menu.itemHeight = Int(AppSettings.sharedInstance.plpSortingOptionsHeight)
        menu.menuSeparatorColor = AppTheme.sharedInstance.plpSortOptionsSeparatorColor
        return menu
    }
    
    /// Creates the container for the drop down meniu. TODO: We need to see if this is required or maybe we can remove in upcoming versions
    ///
    /// - Returns: The container for the drop down menu.
    func createDropDownMenuContainer() -> PassThroughContainerView? {
        guard let extensionContainer = extensionViewContainer else {
            return nil
        }
        
        let dropdownContainer = PassThroughContainerView()
        dropdownContainer.backgroundColor = .clear
        dropdownContainer.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(dropdownContainer, belowSubview: extensionContainer)
        
        dropdownContainer.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        dropdownContainer.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        dropdownContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true        
        dropdownContainer.topAnchor.constraint(equalTo: extensionContainer.bottomAnchor).isActive = true
        
        return dropdownContainer
    }
    
    /// Toggles the drop down menu. TODO: This needs to be renamed.
    @objc func showDropdown() {
        
        if sortByDropDownMenu?.isDescendant(of: view) == true {
            sortByDropDownMenu?.hideMenu()
        } else {
            
            sortByDropDownMenu?.showMenuFromView(dropdownContainerView ?? UIView())
        }
    }
    
    /// Triggers a new iteration of product loading.
    ///
    /// - Parameter isRefresh: Forces the backend to kill the cache and regenerate the data.
    func loadProducts(_ isRefresh: Bool) {
        viewModel.cancelCurrentNetworkTaskIfExists()
        if let query = searchQuery {
            if let task = viewModel.getProductsBySearch(query, isRefresh: isRefresh) {
                viewModel.currentNetworkTasks.insert(task)
            }
        } else {
            self.viewModel.externalId = self.selectedExternalCategoryId
            if let task = viewModel.getProducts(selectedCategoryId, isRefresh: isRefresh, brandId: brandId) {
                viewModel.currentNetworkTasks.insert(task)
            }
        }
    }
    
    /// Sets up the extension view. TODO: This needs to be renamed to SetupExtensionView.
    open func initExtensionView() {
        guard let extensionView = AppSettings.sharedInstance.plpSortFiltersOnToolBarEnable ? productInformationView : filtersToolbar else {
            extensionViewContainerHeight?.constant = 0
            return
        }
        
        extensionViewContainerHeight?.constant = extensionViewHeight
        
        extensionView.translatesAutoresizingMaskIntoConstraints = false
        extensionViewContainer?.addSubview(extensionView)
        
        let constraints = NSLayoutConstraint.constraintsForView(extensionView, withInsetsInContainer: .zero)
        extensionViewContainer?.addConstraints(constraints)
    }
    
    /// Sets up the tool bar. TODO: This needs to be renamed to SetupToolbar.
    open func initToolBar() {
        let filtersToolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: 44.0))
        filtersToolbar.barTintColor = AppTheme.sharedInstance.sortingOptionsBarBackgroundColor
        filtersToolbar.isHidden = true
        
        viewModel.setupToolbarContent()
        filtersToolbar.items = viewModel.toolbarContent.compactMap({ ToolbarContentButtonItem(for: $0, delegate: self) })
        
        guard let items = filtersToolbar.items else {
            return
        }
        
        var index = 0 // Add spacing between items.
        for element in items where element.action != nil {
            filtersToolbar.items?.insert(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), at: index)
            index += 2
        }
        filtersToolbar.items?.insert(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), at: index)
        
        // Add a SeparationLine at the bottom of the filtersToolbar
        if AppSettings.sharedInstance.isPLPFiltersToolbarEnableSeparator == true {
            let separationLine = UIView(frame: CGRect(x: 0.0, y: filtersToolbar.bounds.height - 1.0, width: UIScreen.main.bounds.width, height: 1.0))
            separationLine.backgroundColor = AppTheme.sharedInstance.plpFiltersToolbarSeparatorColor
            filtersToolbar.addSubview(separationLine)
        }
        
        self.filtersToolbar = filtersToolbar
        setSelected(items.first)
    }
    
    /// Sets up the navigation bar items and title. TODO: Needs to be renamed to SetupNavigationBar.
    open func initNavigationBar() {
        
        var navigationTitle = ""
        // Set navigation bar
        // Set title if it is a category or search result
        if !selectedCategoryTitle.isEmpty {
            
            // TODO: need to style them
            navigationTitle = selectedCategoryTitle
            
            // Log product list load
            let params = ["CategoryID": String(self.selectedCategoryId), "CategoryName": selectedCategoryTitle]
            PoqTrackerHelper.trackProductListLoad(PoqTrackerActionType.Category, label: navigationTitle, extraParams: params)
        }
        
        if let keyword = self.searchQuery {
            
            navigationTitle = keyword.descapeStr()
            
            // Log product list load
            PoqTrackerHelper.trackProductListLoad(PoqTrackerActionType.Search, label: navigationTitle)
        }
        
        // Set up the back button
        self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        
        filtersButton = NavigationBarHelper.createButtonItem(withTitle: AppLocalization.sharedInstance.plpFiltersButtonText, target: self, action: #selector(ProductListViewController.filtersButtonClicked))
        
        if !AppSettings.sharedInstance.plpSortFiltersOnToolBarEnable {
            navigationItem.titleView = NavigationBarHelper.setupTitleView(navigationTitle)
        }
    }
    
    /// Sets up the no search result view. TODO: rename the method.
    open func initNoSearchResultViews() {
        // Make sure that the productListNoSearchResultsView view is initialised and added to the noSearchResultsView
        if productListNoSearchResultsView == nil {
            let productView = ProductListNoSearchResultsView(frame: CGRect(x: 0, y: 0, width: (noSearchResultsView?.frame.size.width ?? 0), height: (noSearchResultsView?.frame.size.height ?? 0)))
            noSearchResultsView?.addSubview(productView)
            productListNoSearchResultsView = productView
        }
    }
    
    /// Sets up the refresh control. TODO: rename the method.
    func initRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl?.addTarget(self, action: #selector(ProductListViewController.startRefresh(_:)), for: UIControlEvents.valueChanged)
        guard let validRefreshControl = refreshControl else {
            return
        }
        collectionView?.addSubview(validRefreshControl)
    }
    
    /// Updates the refresh control.
    func updateRefreshControl() {
        if refreshControl?.superview != nil {
            refreshControl?.removeFromSuperview()
            initRefreshControl()
        }
    }
    
    /// Starts the refresh process when pull to refresh is triggered.
    ///
    /// - Parameter refreshControl: the refresh control that triggers the action.
    @objc func startRefresh(_ refreshControl: UIRefreshControl) {
        
        viewModel.isLoadingFirstTime = true
        loadProducts(true)
        refreshControl.endRefreshing()
    }
    
    /// Overridden to implement specific functionality on start.
    ///
    /// - Parameter networkTaskType: The type of the request that was triggered.
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        refreshControl?.isHidden = true
    }
    
    /// Overridden to implement specific functionality on completion.
    ///
    /// - Parameter networkTaskType: The type of the request that was triggered. Reloads the collection view to accomodate for the potential data changes coming from the backend. Also updates the summary view. Works as a workaround for the paging issue, trying to fetch at least 5 products.
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        updateRefreshControl()
        
        if networkTaskType == PoqNetworkTaskType.productsByCategory ||
            networkTaskType == PoqNetworkTaskType.productsByFilters ||
            networkTaskType == PoqNetworkTaskType.productsByBundle ||
            networkTaskType == PoqNetworkTaskType.productsByQuery {
            
            // Check filters to reload data
            if self.viewModel.filteredResult?.filter != nil {
                
                // Update delegate status
                isLoading = false
                
                if !updatedProductsIndexPaths.isEmpty {
                    
                    // If the footer is shown. We need to invalidate layout before inserting more items.
                    if let supplementaryViews = collectionView?.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionFooter),
                        !supplementaryViews.isEmpty {
                        
                        collectionView?.collectionViewLayout.invalidateLayout()
                    }
                    // We insert items here instead of reloading the collectionView as reloading causes the cells to reload and images to flicker.
                    collectionView?.performBatchUpdates({
                        collectionView?.insertItems(at: updatedProductsIndexPaths)
                    }, completion: nil)
                }
                
                if let itemsNumber = viewModel.totalItemsCount, self.itemCountLabel != nil {
                    let format = itemsNumber == 1 ? "NUMBER_ITEM".localizedPoqString : "NUMBER_ITEMS".localizedPoqString
                    itemCountLabel.text = String(format: format, itemsNumber)
                    if !firstLoad {
                        sortByLabel?.text = selectedSortType
                    }
                }
                filtersToolbar?.isHidden = AppSettings.sharedInstance.plpSortFiltersOnToolBarEnable
            }
            
            // Load more data if there is < 5 items on New Arrival categories
            if self.viewModel.products.count < 5 {
                loadNextPageIfNeeded()
            }
        }
        
        // Here we need to check the searchType and searchQuery are not nil here before tracking event
        // These values are only set when we're instantiating the PLP from search
        // And it is only in this case that we want to do this tracking call
        // If these values aren't set it means that the PLP wasn't opened from search
        // So we don't want to track viewsearchresults event
        
        if let type = searchType, let query = searchQuery, let itemsNumber = viewModel.totalItemsCount {
            let searchResult = itemsNumber > 0 ? ActionResultType.successful : ActionResultType.unsuccessful
            PoqTrackerV2.shared.viewSearchResults(keyword: query, type: type, result: searchResult.rawValue)
            /// Reset search type to nil so it will only be tracked on first load
            searchType = nil
        }
        
        updateFilterButtonState()
        
        // Rest of the nil value check should be handled by filter controller
        if !viewModel.hideNoItemsLabel() {
            showNoResultsView(true)
        } else {
            
            if let isNoSearchResultsViewHidden = noSearchResultsView?.isHidden, !isNoSearchResultsViewHidden {
                showNoResultsView(false)
                
            } else if let isEmptyViewHidden = emptyView?.isHidden, !isEmptyViewHidden {
                showNoResultsView(false)
            }
        }
        
        refreshControl?.isHidden = self.viewModel.hideNoItemsLabel()
    }
    
    /// Overridden to implement specific functionality on completion. Updates the refresh control. Show a alerviewcontroller with the error message.
    ///
    /// - Parameters:
    ///   - networkTaskType: The task type that fails.
    ///   - error: The error message.
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
    
        updateRefreshControl()
    
        // Show alert message
        let title = "ERROR".localizedPoqString
        let message = "UNABLE_TO_CONNECT".localizedPoqString
        let actionTitle = "OK".localizedPoqString
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: .default))
        self.alertController = alertController
        
        present(alertController, animated: true)
        
        stopFooterAnimation()
        isLoading = false
        navigationItem.rightBarButtonItem?.isEnabled = AppSettings.sharedInstance.plpSortFiltersOnToolBarEnable ? false : true
    }
    
    /// Stops the animation of the footer
    func stopFooterAnimation() {
        
        if let supplementaryViews = collectionView?.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionFooter),
            !supplementaryViews.isEmpty,
            let footerView = supplementaryViews[0] as? ProductListViewFooterCell {
            footerView.stopAnimating()
        }
    }
    
    /// Makes the UI operations specific to the selected sorting option.
    ///
    /// - Parameter selectedButton: The selected button.
    open func setSelected(_ selectedButton: UIBarButtonItem?) {
        let buttons = filtersToolbar?.items?.compactMap({ $0 as? ToolbarContentButtonItem })
        buttons?.forEach({ $0.tintColor = AppTheme.sharedInstance.sortingOptionTextColor })
        
        selectedButton?.tintColor = AppTheme.sharedInstance.sortingOptionSelectedTextColor
        
        let states: [UIControlState] = [.normal, .highlighted]
        let normalAttributes = [NSAttributedStringKey.font: AppTheme.sharedInstance.sortingButtonNormalFont]
        let pressedAttributes = [NSAttributedStringKey.font: AppTheme.sharedInstance.sortingButtonPressedFont]
        
        for state: UIControlState in states {
            buttons?.forEach({ $0.setTitleTextAttributes(normalAttributes, for: state) })
            selectedButton?.setTitleTextAttributes(pressedAttributes, for: state)
        }
        
        // BEGIN: iOS 11 bug fix
        if AppTheme.sharedInstance.sortingButtonNormalFont != AppTheme.sharedInstance.sortingButtonPressedFont {
            let thirdEn = "\u{2004}"            // Space character width of one third en
            let sixthEn = "\u{2006}\u{2006}"    // Two space characters width of one sixth en (one third total)
            
            var isSixth = false
            if let firstTitle = buttons?.first?.title {
                isSixth = firstTitle.contains(sixthEn)
            }
            
            let charToUse = isSixth ? thirdEn : sixthEn
            
            buttons?.forEach({
                guard let text = $0.title?.trimmingCharacters(in: .whitespaces) else {
                    return
                }
                
                if $0 == buttons?.first {
                    $0.title = String(format: "%@%@", text, charToUse)
                } else if $0 == buttons?.last {
                    $0.title = String(format: "%@%@", charToUse, text)
                } else {
                    $0.title = String(format: "%@%@%@", charToUse, text, charToUse)
                }
            })
        }
        // END: iOS 11 bug fix
    }
    
    /// Triggered when the filter view controller has been dismissed. This is to reload the table and also start loading the filtered PLP.
    ///
    /// - Parameter filters: The filters that were selected in the filter screen.
    public func filtersModalDidDismiss(filters: PoqFilter) {
        
        // Load new data
        resetTable()
        viewModel.cancelCurrentNetworkTaskIfExists()
        if let task = viewModel.getProductsByFilters(filters, brandId: brandId) {
            viewModel.currentNetworkTasks.insert(task)
        }
    }
    
    /// Updates the filter button state.
    func updateFilterButtonState() {
        
        var isEnabled = false
        var isHidden = false
        
        defer {
            updateFilterButton(isEnabled: isEnabled, isHidden: isHidden)
        }
        
        guard !AppSettings.sharedInstance.isPLPFiltersButtonHidden else {
            isHidden = true
            return
        }
        
        guard viewModel.products.count > 0 else {
            return
        }
        
        if NetworkSettings.shared.productListFilterType == ProductListFiltersType.static.rawValue {
            if let filters = viewModel.filteredResult?.filter {
                isEnabled = !(filters.brands?.count == 0 &&
                    filters.colours?.count == 0 &&
                    filters.prices?.count == 0 &&
                    filters.sizes?.count == 0 &&
                    filters.styles?.count == 0)
            }
        } else {
            let filterRefinementsCount = viewModel.filteredResult?.filter?.refinements?.count ?? 0
            
            isEnabled = filterRefinementsCount > 0
        }
    }
    
    /// Required to update the UI of the filter button.
    ///
    /// - Parameters:
    ///   - isEnabled: Is the filter button enabled.
    ///   - isHidden: Is the filter button hidden.
    private func updateFilterButton(isEnabled: Bool, isHidden: Bool) {
        
        if AppSettings.sharedInstance.plpSortFiltersOnToolBarEnable {
            filterButton?.isEnabled = isEnabled
            filterButton?.isHidden = isHidden
        } else {
            if isEnabled && !isHidden {
                navigationItem.setRightBarButton(filtersButton, animated: true)
                navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                navigationItem.setRightBarButton(nil, animated: true)
            }
        }
    }

    /// Opens the filters viewcontroller.
    @objc func filtersButtonClicked() {
        Log.verbose("Filters clicked")
        addFilterList()
    }
    
    /// Uses the navigation helper to show the filter view controller.
    open func addFilterList() {
        NavigationHelper.sharedInstance.showFilter(self, filterData: viewModel.filteredResult?.filter, isModal: true)
    }
    
    /// Clears the expanded products that show the promos text in their respective cells.
    func clearExpandedProducts() {
        self.productsShowingPromos.removeAll()
    }

    /// Sorts the list by feature.
    open func featureSort() {
        // Load new data
        resetTable()
        clearExpandedProducts()
        viewModel.resetFilters()

        selectedSortType = ProductListSortByValue.Featured
        
        viewModel.cancelCurrentNetworkTaskIfExists()
        if let searchProductQuery = searchQuery {
            if let task = viewModel.getProductsBySearch(searchProductQuery, isRefresh: true) {
                viewModel.currentNetworkTasks.insert(task)
            }
        } else {
            self.viewModel.externalId = self.selectedExternalCategoryId
            if let task = viewModel.getProducts(selectedCategoryId, isRefresh: true, brandId: brandId) {
                viewModel.currentNetworkTasks.insert(task)
            }
        }
        // Log sort action
        let params = ["Order by": viewModel.selectedSortType.rawValue]
        PoqTrackerHelper.trackApplySort(PoqTrackerLabelType.Featured, extraParams: params)
    }
    
    /// Sorts the list by new items.
    open func newItemsSort() {
        // Load new data
        resetTable()
        clearExpandedProducts()
        viewModel.resetFilters()
        
        selectedSortType = ProductListSortByValue.Newest
        
        viewModel.cancelCurrentNetworkTaskIfExists()
        if let task = viewModel.sortProductsByDate() {
            viewModel.currentNetworkTasks.insert(task)
        }

        // Log sort action
        let params = ["PoqUserID": User.getUserId(), "Order by": self.viewModel.selectedSortType.rawValue]
        PoqTrackerHelper.trackApplySort(PoqTrackerLabelType.Newest, extraParams: params)
    }
    
    /// Sorts the list by price .
    ///
    /// - Parameter sortType: With the sort type asc/desc.
    open func priceSort(_ sortType: PoqFilterSortType) {
        // Log sort action
        resetTable()
        clearExpandedProducts()
        viewModel.resetFilters()
        
        selectedSortType = (sortType == .ASC) ? ProductListSortByValue.PriceLowToHigh : ProductListSortByValue.PriceHighToLow
        
        viewModel.cancelCurrentNetworkTaskIfExists()
        if let task = viewModel.sortProductsByPrice(sortType) {
            viewModel.currentNetworkTasks.insert(task)
        }
        
        let params = ["Order by": viewModel.selectedSortType.rawValue]
        PoqTrackerHelper.trackApplySort(PoqTrackerLabelType.Price, extraParams: params)
    }
    
    /// Sorts the list by seller.
    ///
    /// - Parameter sortType: With the sort type asc/desc.
    open func sellerSort(_ sortType: PoqFilterSortType) {
        resetTable()
        self.clearExpandedProducts()
        viewModel.cancelCurrentNetworkTaskIfExists()
        if let task = viewModel.sortProductsBySeller(sortType) {
            viewModel.currentNetworkTasks.insert(task)
        }

        let params = ["Order by": viewModel.selectedSortType.rawValue]
        PoqTrackerHelper.trackApplySort(PoqTrackerLabelType.Seller, extraParams: params)
    }
    
    /// Resets the collectionview cell to the initial state.
    open func resetTable() {
        
        // Clear table view
        viewModel.products = []
        collectionView?.reloadData()
        collectionView?.contentOffset = CGPoint.zero
        
        // Show centralised big activity indicator
        viewModel.isLoadingFirstTime = true
        
        updateFilterButtonState()
    }
    
    /// Triggered when the back button has been clicked.
    open override func backButtonClicked() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    /// Shows/hides the no results view.
    ///
    /// - Parameter show: Wether to show the no results view or not.
    fileprivate func showNoResultsView(_ show: Bool) {
        
        if !show {
            
            emptyView?.isHidden = true
            noSearchResultsView?.isHidden = true
            recentlyViewedProductsView?.isHidden = true
            return
        }
        
        // If there is no results, we have 2 options: no search result, or empty filters result
        let isFiltersApplied: Bool = viewModel.filteredResult?.filter?.isFiltersApplied ?? false
        
        if let query = searchQuery, !isFiltersApplied {
            // Make sure that we init the no result views
            initNoSearchResultViews()
            noSearchResultsView?.isHidden = false
            recentlyViewedProductsView?.isHidden = false
            productListNoSearchResultsView?.update(withQuery: query)
            productListNoSearchResultsView?.productPeekOwnerViewController = self
            filtersToolbar?.isHidden = true
        } else {
            emptyView?.isHidden = false
        }
    }
    
    // MARK: - ToolbarContentButtonItemDelegate
    
    open func toolbarContentButtonItem(_ item: ToolbarContentButtonItem, tappedForType type: ToolbarContentItemType) {
        guard let contentType = type as? ProductListViewModel.ToolbarItemType else {
            return
        }
        
        switch contentType {
        case .featured:
            featuredButtonClick(item)
        case .newest:
            newestButtonClick(item)
        case .price:
            priceButtonClick(item)
        case .rating:
            ratingButtonClick(item)
        case .seller:
            sellerButtonClick(item)
        }
    }
    
    /// Filters the product by featured.
    ///
    /// - Parameter sender: The object that sends the action to sort.
    public func featuredButtonClick(_ sender: AnyObject) {
        
        // Any loading from firt page should not show loading indicator
        viewModel.isLoadingFirstTime = true
        clearExpandedProducts()
        // Set selected
        Log.verbose("Sort Featured")
        setSelected(sender as? UIBarButtonItem)
        featureSort()
    }
    
    /// Filters the product by newest.
    ///
    /// - Parameter sender: The object that sends the action to sort.
    public func newestButtonClick(_ sender: AnyObject) {
        
        // Set selected
        Log.verbose("Sort Newest")
        setSelected(sender as? UIBarButtonItem)
        newItemsSort()
    }
    
    /// Filters the product by price.
    ///
    /// - Parameter sender: The object that sends the action to sort.
    public func priceButtonClick(_ sender: AnyObject) {
        
        Log.verbose("Sort Price")
        
        let selectedButton = sender as? UIBarButtonItem
        
        if viewModel.selectedSortType == PoqFilterSortType.DESC {
            selectedButton?.title = AppLocalization.sharedInstance.plpPriceUpText
            priceSort(PoqFilterSortType.ASC)
        } else {
            selectedButton?.title = AppLocalization.sharedInstance.plpPriceDownText
            priceSort(PoqFilterSortType.DESC)
        }
        
        setSelected(selectedButton)
    }
    
    /// Filters the product by rating.
    ///
    /// - Parameter sender: The object that sends the action to sort.
    public func ratingButtonClick(_ sender: AnyObject) {
        
        Log.verbose("Sort Rating")
        setSelected(sender as? UIBarButtonItem)
        
        // Only show ratings in desc
        resetTable()
        viewModel.resetFilters()
        viewModel.cancelCurrentNetworkTaskIfExists()
        if let task = viewModel.sortProductsByRating(PoqFilterSortType.DESC) {
            viewModel.currentNetworkTasks.insert(task)
        }
        
        // Log sort action
        let params: [String: String] = ["Order by": viewModel.selectedSortType.rawValue]
        PoqTrackerHelper.trackApplySort(PoqTrackerLabelType.Rating, extraParams: params)
    }
    
    /// Filters the product by seller.
    ///
    /// - Parameter sender: The object that sends the action to sort.
    public func sellerButtonClick(_ sender: AnyObject) {
        
        Log.verbose("Sort Seller")
        setSelected(sender as? UIBarButtonItem)
        sellerSort(PoqFilterSortType.DESC)
    }
}

extension ProductListViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Handles the collection view flow layout.
extension ProductListViewController: UICollectionViewDelegateFlowLayout {
    
    /// Handles thee size of the product cell.
    ///
    /// - Parameters:
    ///   - collectionView: Collectionview used.
    ///   - collectionViewLayout: Collectionviewlayout used.
    ///   - indexPath: Spacing for the indexpath.
    /// - Returns: The size of the product cell.
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let products: [PoqProduct] = viewModel.products
        guard indexPath.row < products.count else {
            return CGSize.zero
        }
        
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let cellInset = flowLayout?.sectionInset ?? UIEdgeInsets.zero
        return ProductListViewCell.cellSize(products[indexPath.row], cellInsets: cellInset)
    }
    
    /// Handles the spacing of the PLP section.
    ///
    /// - Parameters:
    ///   - collectionView: Collectionview used.
    ///   - collectionViewLayout: Collectionviewlayout used.
    ///   - section: Spacing for the section.
    /// - Returns: Section spacing value.
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return CGFloat(ProductListViewController.rowSpacing)
    }
    
    /// Handles spacing in between the items inside the sections.
    ///
    /// - Parameters:
    ///   - collectionView: Collectionview used.
    ///   - collectionViewLayout: Collectionviewlayout used.
    ///   - section: Section of the items that will receive the spacing in between the products.
    /// - Returns: Columns spacing value.
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return CGFloat(ProductListViewController.columnSpacing)
    }
    
    /// Generates the footer view only
    ///
    /// - Parameters:
    ///   - collectionView: Collectionview used.
    ///   - kind: Always the footer. Generating the header points to an issue.
    ///   - indexPath: Indexpath of the footer view.
    /// - Returns: Reffrence to the footer view.
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if viewModel.isLoadingFirstTime || viewModel.products.isEmpty {
            // Table is empty - we don't won't load second page while we loading first one
            let view = UICollectionReusableView()
            view.backgroundColor = UIColor.clear
            return view
        }
        
        let footer: ProductListViewFooterCell = collectionView.dequeueReusablePoqSupplementaryViewOfKind(UICollectionElementKindSectionFooter, forIndexPath: indexPath)
        footer.startAnimating()
        return footer
    }
    
    /// Return the size of the footerview 
    ///
    /// - Parameters:
    ///   - collectionView: Collectionview used.
    ///   - collectionViewLayout: Collectionviewlayout used.
    ///   - section: That uses this size for the footerview.
    /// - Returns: The size of the footer view.
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if viewModel.shouldLoadMoreProducts() && !viewModel.isLoadingFirstTime && !viewModel.products.isEmpty {
            Log.verbose("show footer")
            // Get screen width
            let bounds: CGRect = UIScreen.main.bounds
            let width: CGFloat = bounds.size.width
            let height = CGFloat(ProductListViewController.footerHeight)
            return CGSize(width: width, height: height)
        } else {
            Log.verbose("hide footer")
            return CGSize(width: 0, height: 0)
        }
    }
}

// MARK: - Handles the data source and the delegate for the collection view
extension ProductListViewController: UICollectionViewDataSource {
    
    /// Returns the number of items in the given section
    ///
    /// - Parameters:
    ///   - collectionView: The collection view that renders the PLP.
    ///   - section: The given section.
    /// - Returns: Number of items in the given section.
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Log.verbose("self.viewModel!.products.count: \(self.viewModel.products.count)")
        return self.viewModel.products.count
    }
    
    /// Generates the product cell
    ///
    /// - Parameters:
    ///   - collectionView: The collection view that renders the PLP.
    ///   - indexPath: The indexpath for the product cell.
    /// - Returns: The product cell.
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let products: [PoqProduct] = viewModel.products
        guard indexPath.row < products.count else {
            return UICollectionViewCell()
        }
        
        let cell: ProductListViewCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.delegate=self
        cell.colorChangeDelegate = self
        cell.updateView(products[indexPath.item])
        cell.accessibilityIdentifier = AccessibilityLabels.productList
        
        // Preload next page if it's getting near the end of current page so the scrolling could feel more smooth
        if indexPath.item >= self.viewModel.products.count - 5 {
            loadNextPageIfNeeded()
        }
        
        return cell
    }
    
    /// The number of sections the PLP has.
    ///
    /// - Parameter CollectionView: the collection view for the PLP.
    /// - Returns: The number of sections for the PLP.
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /// Triggered when a product is selected. Tracks the action and loads the product detail accordingly.
    ///
    /// - Parameters:
    ///   - collectionView: The collection that renders the PLP.
    ///   - indexPath: The indexpath of the product.
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var product = viewModel.products[indexPath.row]
        
        // If Color swatch selection is enabled and the user has picked a color swatch then update with the selectedColor Product Id
        if let selectedColorProductId = product.selectedColorProductID, AppSettings.sharedInstance.isPlpColorSwatchesEnabled {
            product = product.getColourProduct(selectedColorProductId)
        }
        
        if let bundleId = product.bundleId, !bundleId.isEmpty {
            NavigationHelper.sharedInstance.loadBundledProduct(using: product)
        } else {
            
            guard let externalRelatedProductIds = product.relatedExternalProductIDs, externalRelatedProductIds.count > 0 else {
                if let productId = product.id {
                    
                    var source: PoqTrackingSource? = nil
                    
                    if let searchQuery = searchQuery {
                        source = PoqTrackingSource.search(searchQuery)
                    } else {
                        source = PoqTrackingSource.category(selectedCategoryTitle)
                    }
                    
                    NavigationHelper.sharedInstance.loadProduct(productId, externalId: product.externalID, sourceTracking: source, source: ViewProductSource.plp.rawValue, productTitle: product.title)
                }
                return
            }
            
            NavigationHelper.sharedInstance.loadGroupedProduct(with: product)
        }
    }
}

// MARK: - Product cell specific methods.
extension ProductListViewController: ProductListViewCellDelegate {
    
    /// Checks if the current cell has the promo box expanded.
    ///
    /// - Parameter productId: the product's id.
    /// - Returns: if the product has the promo box expanded.
    public func getIsPromoExpanded(_ productId: Int) -> Bool {
        
        return self.productsShowingPromos.index(of: productId) != nil
    }
    
    /// Toggles the promotion banner on a given product.
    ///
    /// - Parameter product: The product that needs to toggle the promotion view.
    public func toggleExpandedProduct( _ product: PoqProduct ) {
        if let productId = product.id {
            guard let promoExpandedIndex = self.productsShowingPromos.index(of: productId) else {
                self.productsShowingPromos.append( productId )
                return
            }
            self.productsShowingPromos.remove( at: promoExpandedIndex )
        }
    }
}

// MARK: - Handles product loading failure
extension ProductListViewController {
    
    /// Reltries loading the product in case something goes wrong.
    ///
    /// - Parameter sender: The object that requested this action.
    @IBAction public func retryButtonClicked(_ sender: Any?) {
        viewModel.filteredResult?.filter = nil
        changeSortValuevalue()
    }
}

// MARK: - Handles the PLP contiunous loading functionality
extension ProductListViewController: InfiniteScrollable {
    
    /// Loads the next page if the screen is in the correct state.
    ///
    /// - Returns: Returns the task that loads the next page.
    @discardableResult public func loadNextPageIfNeeded() -> PoqNetworkTask<JSONResponseParser<PoqFilterResult>>? {
        guard viewModel.shouldLoadMoreProducts() && isLoading == false else {
            return nil
        }
        
        // Update delegate status
        isLoading = true
        
        // Call view model for the rest of data
        guard let task = viewModel.loadMoreProducts() else {
            return nil
        }
        
        // Insert into viewModel's current tasks
        viewModel.currentNetworkTasks.insert(task)
        
        return task
    }
}

// MARK: - Screen specific actions - TODO: This either needs to be split up into multiple protocols or moved in the main implementation
extension ProductListViewController {
    
    /// Action when the filter button is clicked.
    ///
    /// - Parameter sender: The object that requested this action.
    @objc func filterButtonClicked(_ sender: AnyObject) {
        addFilterList()
    }
    
    /// Triggered when the sorting option changed.
    func changeSortValuevalue() {
        firstLoad = false
        
        switch selectedSortType {
        case ProductListSortByValue.Newest:
            newItemsSort()
        case ProductListSortByValue.Featured:
            featureSort()
        case ProductListSortByValue.PriceHighToLow:
            priceSort(PoqFilterSortType.DESC)
        case ProductListSortByValue.PriceLowToHigh:
            priceSort(PoqFilterSortType.ASC)
        default:
            break
        }
    }
}

// MARK: - Handles the changing of the color.
extension ProductListViewController: ProductColorsDelegate {
    /// Triggered when the color of a product is changed. TODO: Check wether this has actual implementation in the PLP.
    ///
    /// - Parameters:
    ///   - selectedColor: The selected color.
    ///   - productId: The id of the product.
    ///   - externalId: The external id of the product.
    ///   - selectedColorProductId: We use the colors as separate product ids this is the id of that color's product.
    public func colorSelected(_ selectedColor: String, productId: Int, externalId: String, selectedColorProductId: Int?) {
        if let selectedProductIndex = viewModel.products.index(where: { $0.id == productId }), let selectedColorProductIdUnwrapped = selectedColorProductId {
            viewModel.products[selectedProductIndex].selectedColorProductID = selectedColorProductIdUnwrapped
        }
    }
}
