//
//  WishlistViewController.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/20/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqModuling
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

/**
 
 WishlistViewController is one of the main View Controllers in Poq applications which can normaly be found when tapping the tab bar.
 The view consists of a UITableView that contains a number of cells. These make up the listing of products in the wishlist
 Its architecture is MVVM and its model is lazy loaded to conserve memory until the model is needed.
 ## Usage Example: ##
 ````
 let viewController = WishlistViewController(nibName: "WishlistView", bundle: nil).
 ````
 */

open class WishlistViewController: PoqBaseViewController, WishlistCellDelegate, PoqProductSizeSelectionPresenter, SizeSelectionDelegate, UITableViewDataSource, UITableViewDelegate {
    
    /// The name of the screen that will be tracked in analytics.
    override open var screenName: String {
        return "WishList Screen"
    }
    
    /// The toolbar view that appears on top of the wishlist.
    @IBOutlet public weak var toolbarView: UIView?
    /// The label that displays the number of items in wishlist.
    @IBOutlet public weak var countLabel: UILabel?
    /// The button that clears all the items in the wishlist.
    @IBOutlet public weak var clearAllButton: UIButton?
    /// The separation line at the bottom of the toolbar.
    @IBOutlet public weak var separationLine: UIView?
    
    /// The UITableView that will render the wishlist items.
    @IBOutlet open weak var wishlistTable: UITableView! {
        didSet {
            wishlistTable?.allowsMultipleSelectionDuringEditing = false
            wishlistTable?.allowsSelectionDuringEditing = false
            
            wishlistTable?.backgroundView = nil
            wishlistTable?.backgroundColor = UIColor.clear
            wishlistTable?.alpha = 0
        }
    }
    
    /// The height of the items summary box.
    @IBOutlet open weak var itemsSummaryHeight: NSLayoutConstraint? {
        didSet {
            // Hide it first, then slide up after bag items > 0
            
            itemsSummaryHeight?.constant = 0
        }
    }
    
    /// Default value excluding voucher height.
    let originalItemsSummaryPanelHeight: CGFloat = 30.0
    
    /// The height of the product cell.
    open var productCellHeight: CGFloat = 180.0
    
    /// Flag for showing size selection box when product is added to bag.
    var shouldShowSizesSection = true
    
    /// The content items in the wishlist.
    var content:[(identifier: String, height: Int)] = []
    
    /// The transition delegate that handles the animation for size selection box.
    public var sizeSelectionTransitioningDelegate: UIViewControllerTransitioningDelegate?
    
    /// The delegate that handles size selection.
    public var sizeSelectionDelegate: SizeSelectionDelegate? {
        return self
    }
    
    /// The view model of the wishlist.
    open lazy var viewModel: WishlistViewModel? = {
        [unowned self] in
        return WishlistViewModel(viewControllerDelegate: self)
        }()
    
    /// The identifier for the product sizes in the product size selection box.
    var productSizesViewCellIdentifier = ProductSizesViewCell.poqReuseIdentifier
    
    /// The height of the product size cell.
    let productSizesCellHeight = 90
    
    /// The specific identifier for products that have only one size.
    let oneSizeIdentifier: String = "one size"
    
    /// Flag that separates screen that appears from tab as opposed to one that comes as traditional navigation.
    open var isFromTab = true
    
    // SelectedProduct index when press addToBag
    var selectedProductIndex: Int = 0
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Triggered when the view has loaded. Sets up the navigation bar item, the pull to refresh item.
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        setUpLeftNavigationBarItem()
        
        // Do any additional setup after loading the view.
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(WishlistViewController.startRefresh(_:)), for: UIControlEvents.valueChanged)
        
        wishlistTable?.addSubview(refreshControl)
        
        updateClearAllVisibilityStatus()
        
        // Log wishlist screen
        PoqTrackerHelper.trackWishScreenLoaded()
        // Show hide right navigation menu
        if AppSettings.sharedInstance.hideRightNavigationMenuOnWish {
            navigationItem.rightBarButtonItem = nil
        }
        
        wishlistTable?.isEditing = false
        
        self.hideTableView(animated: false)
        
        updateTotals()
        
        NotificationCenter.default.addObserver(self, selector: #selector(WishlistViewController.updateTotals), name: NSNotification.Name(rawValue: wishlistChangeNotification), object: nil)
        
        PoqUserNotificationCenter.shared.setupRemoteNotifications()
    }
    
    /// Triggered when the view is set to appear. Fetches the list of products for the wishlist.
    ///
    /// - Parameter animated: Wether or not the view appears as animated.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // We called this method to be sure that we sync everything from megento.
        viewModel?.getWishList()
        
        updateTotals()
    }
    
    /// Sets up the navigation bar items.
    func setUpLeftNavigationBarItem() {
        
        if isFromTab {
            
            // Remove back button as view is in a tab.
            self.navigationItem.leftBarButtonItem = nil
        } else {
            
            // Set back button as view is pushed.
            self.navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        }
    }
    
    /// Set up any view specific items. Register cells and sets up the clear buttona and separation line.
    open func setUpView() {
        // Register our xib
        registerCells()
        
        countLabel?.font = AppTheme.sharedInstance.wishListCountLabelFont
        clearAllButton?.tintColor = AppTheme.sharedInstance.wishlistClearAllButtonTintColor
        clearAllButton?.setTitle(AppLocalization.sharedInstance.wishListClearAllText, for: .normal)
        clearAllButton?.titleLabel?.font = AppTheme.sharedInstance.wishListClearAllFont
        
        // Add a SeparationLine at the bottom of the Toolbar
        separationLine?.isHidden = !AppSettings.sharedInstance.isWishlistToolbarEnableSeparator
        separationLine?.backgroundColor = AppTheme.sharedInstance.wishlistToolbarSeparatorColor
    }
    
    /// Register the wishlist view cells.
    open func registerCells() {
        wishlistTable?.registerPoqCells(cellClasses: [WishListTableViewCell.self, NoItemsCell.self])
    }
    
    /// Triggered when the refresh actions starts.
    ///
    /// - Parameter refreshControl: The refresh control that started the refresh action.
    @objc func startRefresh(_ refreshControl: UIRefreshControl) {
        self.viewModel?.getWishList(true)
        refreshControl.endRefreshing()
    }
    
    /// Update the totals.
    @objc open func updateTotals() {
        
        let count = WishlistController.shared.localFavoritesCount
        
        let single = String(format: AppLocalization.sharedInstance.wishListCountSingleText, count)
        let plural = String(format: AppLocalization.sharedInstance.wishListCountMultipleText, count)
        self.countLabel?.text = count == 1 ? single : plural
        self.countLabel?.isHidden = count == 0
        // Set the background color the summary view to the same as empty cell.
        self.itemsSummaryHeight?.constant = count == 0 ? 0 : self.originalItemsSummaryPanelHeight
    }
    
    // MARK: - Table view data source.
    
    /// Returns the number of rows in a section of the wishlist. The number of sections is usually 1.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableView object.
    ///   - section: The section for which the number of i.
    /// - Returns: The number of rows in a section of the wishlsit.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        guard let viewModel = self.viewModel else {
            Log.error("ViewModel of WishListScreen is nil!")
            return 0
        }
        return viewModel.hasWishListItems() ? viewModel.getItemsCount() : 1
    }
    
    /// Returns the table view cell for the wishlist view cell.
    ///
    /// - Parameters:
    ///   - tableView: Refference to the tableView object.
    ///   - indexPath: The indexpath of the cell that will be rendered in wishlist.
    /// - Returns: The table view cell for the wishlist.
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let viewModel = viewModel, viewModel.hasWishListItems() {
            guard let cell: WishListTableViewCell = tableView.dequeueReusablePoqCell() else {
                Log.error("Couldn't cast to WishListTableViewCell during dequeue")
                return UITableViewCell()
            }
            
            // Configure the cell...
            cell.delegate = self
            if indexPath.row < viewModel.wishListItems.count {
                cell.setup(using: viewModel.wishListItems[indexPath.row])
            }
            cell.index = indexPath.row
            
            cell.selectionStyle = .none
            cell.accessibilityIdentifier = AccessibilityLabels.wishItems
            
            return cell
        }
        
        // Show "no items in wishlist"
        // TODO: Need to rename to general No Items Cell.
        guard let cell: NoItemsCell = tableView.dequeueReusablePoqCell() else {
            Log.error("Couldn't cast to NoItemsCell")
            return UITableViewCell()
        }
        
        cell.setUp(EmptyCellType.wishList)
        cell.delegate = self
        return cell
    }
    
    /// The height of the cell for the product item in the wishlist.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableView object.
    ///   - indexPath: The indexpath of the cell that will receive the height.
    /// - Returns: Valid float value for a given wishlist cell.
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard viewModel?.hasWishListItems() == true else {
            return tableView.frame.height
        }
        
        return productCellHeight
    }
    
    // MARK: - swipe to delete functionality.
    /// Returns wether or not swipe to delete is enabled for a given cell.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableView object.
    ///   - indexPath: The indexpath of the cell for which the swipe to delete functionality is enabled.
    /// - Returns: Wether or not swipe to delete is enabled for the cell at indexPath.
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /// Renders the cell editing style.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableView object.
    ///   - indexPath: The indexPath of the cell that will receive the editing style.
    /// - Returns: The editing style of the cell at indexPath.
    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard let viewModel = viewModel, indexPath.row < viewModel.wishListItems.count else {
            return .none
        }
        
        return .delete
    }
    
    /// Returns the swipe action configuration for a given cell.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableView object.
    ///   - indexPath: The indexPath of the cell that will receive the swipe action.
    /// - Returns: The swipe action configuration given to the cell.
    open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let viewModel = viewModel, indexPath.row < viewModel.wishListItems.count else {
            return nil
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completion) in
            let deleteItem = viewModel.wishListItems[indexPath.row]
            viewModel.removeWishlistItem(deleteItem) { isRemoved in
                if viewModel.wishListItems.isEmpty {
                    let delay = DispatchTime.now() + .milliseconds(400)
                    DispatchQueue.main.asyncAfter(deadline: delay) {
                        tableView.reloadData()
                    }
                } else {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                completion(true)
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    /// Returns the cell editing style to a give cell.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableView object.
    ///   - editingStyle: The editing style that the cell will receive.
    ///   - indexPath: The indexPath of the cell.
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        guard let viewModel = viewModel, indexPath.row < viewModel.wishListItems.count else {
            return
        }
        
        // Remove the deleted object from view model.
        let item = viewModel.wishListItems[indexPath.row]
        viewModel.removeWishlistItem(item) { (removed) in
            tableView.reloadData()
        }
    }
    
    // MARK: - select a row.
    /// Triggered when the user selects a cell in the wishlist.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableView object.
    ///   - indexPath: The indexPath of the selected cell.
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let wishlistItemCount = viewModel?.wishListItems.count, wishlistItemCount > indexPath.row else {
            Log.warning("User tapped on NoItemsCell. No wishlist items to select.")
            return
        }
        
        if  let product = viewModel?.wishListItems[indexPath.row],
            let selectedProductId = product.id,
            let selectedExternalId = product.externalID,
            let hasWishListItems = viewModel?.hasWishListItems(),
            hasWishListItems {
            
            // Check if it is a group or bundle Product, otherwise, load it as a normal item.
            if let relatedProductIds = product.relatedProductIDs,
                relatedProductIds.count > 0 {
                if let bundleId = product.bundleId, !bundleId.isEmpty {
                    NavigationHelper.sharedInstance.loadBundledProduct(using: product)
                } else {
                    NavigationHelper.sharedInstance.loadGroupedProduct(with: product)
                }
            } else {
                NavigationHelper.sharedInstance.loadProduct(selectedProductId, externalId: selectedExternalId, topViewController: self, isModal: false, isViewAnimated: true, source: ViewProductSource.wishlist.rawValue, productTitle: product.title ?? "")
            }
        }
        // Dismiss the selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Footer
    
    /// Returns the height of the header for the wishlist screen.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableView object.
    ///   - section: The section number of the header.
    /// - Returns: The height of the header.
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    /// Returns the footer view of the tableView.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableView object.
    ///   - section: The section that will receive the footer view.
    /// - Returns: The view that will be used as a footer for the wishlist screen.
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if let viewModel = viewModel, viewModel.shouldLoadMoreProducts() {
            
            var footer: UITableViewHeaderFooterView? = wishlistTable?.dequeueReusableHeaderFooterView(withIdentifier: WishlistTableViewFooter.WishlistFooterReuseIdentifier)
            
            if footer == nil {
                footer = WishlistTableViewFooter(reuseIdentifier: WishlistTableViewFooter.WishlistFooterReuseIdentifier)
            }
            
            return footer
        }
        
        return nil
    }
    
    /// Returns the height of a given footer section.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableView object.
    ///   - section: The section for which the height of the footer will be given to.
    /// - Returns: The height of the footer of the wishlist screen.
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if let viewModel = viewModel, viewModel.shouldLoadMoreProducts() {
            return WishlistTableViewFooterHeight
        }
        
        return 0.0
    }
    
    /// Triggered when the footer view is about to be rendered. We use this as a message to trigger loading of the next page.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableView object.
    ///   - view: Reffrence to the footer view that will be rendered.
    ///   - section: The section that will receive the footer.
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        
        viewModel?.loadNextPage()
    }
    
    // MARK: - IBActions
    
    /// Triggers the clear all dialog for the wishlist screen.
    ///
    /// - Parameter sender: The button that triggered the clear action.
    @IBAction open func clearAllItems(_ sender: UIButton) {
        let validAlertController = UIAlertController(title: "CONFIRMATION".localizedPoqString, message: "CLEAR_ALL_WISHLIST_ITEMS".localizedPoqString, preferredStyle: .alert)
        
        self.alertController = validAlertController
        
        validAlertController.addAction(UIAlertAction(title: "CANCEL".localizedPoqString, style: .cancel))
        
        validAlertController.addAction(UIAlertAction(title: "OK".localizedPoqString, style: .default) { _ in
            // Do whatever callback you want in here
            // Clear all of the wishlist button
            self.viewModel?.removeAllWishlistItems()
            self.wishlistTable?.reloadData()
        })
        
        present(validAlertController, animated: true)
    }
    
    /// Toggles availability of the clear all button. If turned off from MB or if there are no items, the button will not show.
    open func updateClearAllVisibilityStatus() {
        
        guard let viewModel = viewModel else {
            return
        }
        
        clearAllButton?.isHidden = !viewModel.hasWishListItems() || AppSettings.sharedInstance.wishListClearAllIsHidden
    }
    
    // ______________________________________________________
    
    // MARK: - Network task callbacks
    
    /// Triggered when a network request has started.
    ///
    /// - Parameter networkTaskType: The type of network task that has started.
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        updateClearAllVisibilityStatus()
    }
    
    /// Triggered when a network task has completed.
    ///
    /// - Parameter networkTaskType: The network task type that completed.
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        showTableView()
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.postBag:
            self.perform(#selector(startAddToBagAnimation), with: nil, afterDelay: 0.1)
             
        case PoqNetworkTaskType.postCartItems :
            syncBagCheck()
            
        case PoqNetworkTaskType.productDetails :
            
            if let selectedProduct = viewModel?.selectedProduct {
                addToBag(selectedProduct)
            }
            
        default:
            
            Log.error("Network task type \(networkTaskType.type) not handled by ViewController")
        }
        
        updateClearAllVisibilityStatus()
        self.wishlistTable?.reloadData()
        self.updateTotals()
    }
    
    /// Triggered when a network task has failed.
    ///
    /// - Parameters:
    ///   - networkTaskType: The network task type that failed.
    ///   - error: The associated error with the failure.
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        showTableView()
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.postCartItems, PoqNetworkTaskType.postBag:
            
            let errorTitle = "ADD_TO_BAG_ERROR_TITLE".localizedPoqString
            
            let alertController = UIAlertController(title: errorTitle, message: error?.localizedDescription ?? "SOMETHING_WENT_WRONG".localizedPoqString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true)
            
        default:
            
            break
        }
        
    }
    
    /// Used to update the table view in which the wishlist is rendered.
    ///
    /// - Parameters:
    ///   - isVisible: Wether or not to render the tableView. It uses alpha to hide or show the tableView TODO: Why do we use alpha to do this, both cases there's no animation? .
    ///   - isAnimated: Wether or not to animate the visiblity transition.
    func updateTableView( visibility isVisible: Bool, withAnimation isAnimated: Bool ) {
        
        func toggleTableViewVisibility() {
            
            self.wishlistTable?.alpha = isVisible ? 1.0 : 0.0
        }
        
        isAnimated ? UIView.animate(withDuration: 0.3, animations: toggleTableViewVisibility) : toggleTableViewVisibility()
    }
    
    /// Shows the wishlist table view.
    ///
    /// - Parameter isAnimated: Wether or not to animate the visibility of the wishlist.
    func showTableView( animated isAnimated: Bool = true ) {
        self.updateTableView(visibility: true, withAnimation: isAnimated)
    }
    
    /// Hides the wishlist table view.
    ///
    /// - Parameter isAnimated: Wether or not to animate the visibility of the wishlist.
    func hideTableView( animated isAnimated: Bool = true ) {
        self.updateTableView(visibility: false, withAnimation: isAnimated)
    }
    
    // MARK: - WishlistDelegate methods
    
    /// Removes a item in the wishlist.
    ///
    /// - Parameters:
    ///   - listItem: The product that is going to be removed from the wishlist.
    ///   - index: n/a TODO: Why do we need to send the index and the Product?.
    public func remove(_ listItem: AnyObject, index: Int) {
        guard let item = listItem as? PoqProduct else {
            Log.error("Item was not PoqProduct as expected.")
            return
        }
        
        self.viewModel?.removeWishlistItem(item) { (removed) in
            guard removed else {
                return
            }
            
            self.updateTotals()
            self.wishlistTable?.reloadData()
        }
    }
    
    /// Triggered when a product's add to bag button has been clicked.
    ///
    /// - Parameters:
    ///   - listItem: The product that will be added to the bag.
    ///   - index: n/a TODO: Why do we need to send the index and the Product?.
    public func addToBagClicked(_ listItem: AnyObject, index: Int) {
        guard let selectedProduct: PoqProduct = listItem as? PoqProduct else {
            Log.warning("Error: selected element is not a product")
            return
        }
        selectedProductIndex = index
        viewModel?.updateSelectedProduct(selectedProduct)
    }
    
    /// Adds a product to the bag.
    ///
    /// - Parameter product: The product that will be added to the bag. TODO: I think this needs to be moved to the service in case it hasn't been already moved then we need.
    /// TODO: Remove if else chains and make it nice and tidy.
    func addToBag(_ product: PoqProduct) {
        
        guard let sizes = product.productSizes, !sizes.isEmpty else {
            if AppSettings.sharedInstance.shouldCheckForOutOfStockeProducts {
                BagHelper.showPopupMessage(AppLocalization.sharedInstance.bagOutOfStockMessage, isSuccess: false)
            }
            
            return
        }
        
        let nilSizes = sizes.filter({ $0.size == nil })
        
        if let firstProductSize = sizes.first?.size, (firstProductSize.isEmpty || firstProductSize.lowercased().contains(oneSizeIdentifier)) && sizes.count == 1 {
            
            shouldShowSizesSection = false
        } else if nilSizes.count > 0 {
            
            shouldShowSizesSection = false
        } else {
            
            shouldShowSizesSection = true
        }
        
        if shouldShowSizesSection && AppSettings.sharedInstance.isSizeInformationRowShown {
            
            content.insert((identifier: productSizesViewCellIdentifier, height: productSizesCellHeight), at: content.count)
        }
        
        if let product = viewModel?.selectedProduct, let productSizes = product.productSizes, productSizes.count > 0 {
            
            if !shouldShowSizesSection {
                
                self.viewModel?.selectedProduct?.selectedSizeID = self.viewModel?.selectedProduct?.productSizes?[0].id
                
                product.selectedSizeID = self.viewModel?.selectedProduct?.selectedSizeID
                
                self.viewModel?.addToBag( product)
                
                if let productUnwrapped = viewModel?.selectedProduct, let productSizeUnwrapped = viewModel?.selectedProduct?.productSizes?[0] {
                    PoqTracker.sharedInstance.trackAddToBag(for: productUnwrapped, productSize: productSizeUnwrapped)
                    BagHelper.logAddToBag(productUnwrapped.title, productSize: productSizeUnwrapped)
                }
                
            } else if presentedViewController == nil {
                if AppSettings.sharedInstance.shouldCheckForOutOfStockeProducts, viewModel?.selectedProduct?.isOutOfStock() == true {
                    BagHelper.showPopupMessage(AppLocalization.sharedInstance.bagOutOfStockMessage, isSuccess: false)
                } else {
                    showSizeSelector(using: product)
                }
            }
        }
    }
    
    /// Syncronizes the bag and checks to see if the user is logged in.
    open func syncBagCheck() {
        
        // Handle the legacy PoqMessage http error code case
        if let messageObject = viewModel?.message, let message = messageObject.message, let statusCode = messageObject.statusCode, statusCode != 200 {
            
            BagHelper.showPopupMessage(message, isSuccess: false)
            
            return
        }
        
        updateRightButton(animated: true)
        
        BagHelper.completedAddToBag()
    }
    
    /// Adds to bag the product with the selected size object.
    ///
    /// - Parameter size: The size object that was selected for the product. TODO: This seems over convoluted there needs to be some cleanup on the flow of adding a product and this needs to be moved to the viewModel / service.
    public func handleSizeSelection(for size: PoqProductSize) {
        
        guard let selectedProduct = viewModel?.selectedProduct else {
            Log.error("No selected product cannot add to bag")
            return
        }
        
        selectedProduct.selectedSizeID = size.id
        
        viewModel?.addToBag(selectedProduct)
        
        // Log add to bag action
        BagHelper.logAddToBag(selectedProduct.title, productSize: size)
        
        PoqTracker.sharedInstance.trackAddToBag(for: selectedProduct, productSize: size)
    }
}

extension WishlistViewController {
    
    // Add to bag Animation
    @objc func startAddToBagAnimation() {
        
        guard let cell = wishlistTable.cellForRow(at: IndexPath(row: selectedProductIndex, section: 0)) as? WishListTableViewCell else {
            return
        }
        
        if let tabController = self.tabBarController as? TabBarViewController,
            let tabbarItem = tabController.viewForTabBarItemAtIndex(2) {
        
            let image = cell.takeScreenshot()
            let endFrame = CGPoint(x: tabbarItem.center.x,
                                   y: tabController.tabBar.center.y)
            
            let rectOfCell = wishlistTable.rectForRow(at: IndexPath(row: selectedProductIndex, section: 0))
            let rectOfCellInSuperview = wishlistTable.convert(rectOfCell, to: wishlistTable.superview)
            let settings = WishlistAddToBagAnimatorViewSettings(wishlistCellImage: image,
                                                                wishlistCellFrame: rectOfCellInSuperview,
                                                                endOrigin:endFrame)
            weak var weakself = self
            WishlistAnimator.startAddToBagAnimation(with: settings) {
                weakself?.syncBagCheck()
            }
        }
        
    }
    
}

// MARK: - BUTTON ACTION

// MARK: - Handles actions on the sign ing button. TODO: This needs to be removed and the sender should become a proper UIButton instance.
extension WishlistViewController: SignButtonDelegate {
    /// Called to navigate to Home? TODO: Why is this showing home instead of login screen.
    ///
    /// - Parameter sender: The sender that triggered the action.
    public func signButtonClicked(_ sender: Any?) {
        NavigationHelper.sharedInstance.loadHome()
    }
}

// MARK: - Handles actions on the no items cell.
extension WishlistViewController: NoItemsCellDelegate {
    
    /// Triggered when continue shopping is clicked when there are no products around.
    public func noItemsContinueShoppinClicked() {
        
        NavigationHelper.sharedInstance.continueShopping()
    }
}

