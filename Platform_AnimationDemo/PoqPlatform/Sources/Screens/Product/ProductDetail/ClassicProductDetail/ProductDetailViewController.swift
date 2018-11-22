//
//  ProductDetailViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 03/06/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import IDMPhotoBrowser
import PoqModuling
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

/**
 
 ProductDetailViewController is one of the main View Controllers in Poq applications which can normaly be found as a child of a given ProductListViewController item
 The view consists of a UITableView that contains a number of cells. These make the rendering of the screen in the sense that diffrent sections can be removed/swaped easily.
 Its architecture is MVVM and its model is lazy loaded to conserve memory until the model is needed
 TODO: Future important change this screen will move to service/presenter approach as part of the platform modernisation.
 ## Usage Example: ##
 ````
 let viewController = ProductDetailViewController(nibName: "ProductDetailView", bundle: nil)
 ````
 */
open class ProductDetailViewController: PoqBaseViewController, IDMPhotoBrowserDelegate, ProductColorsDelegate, PoqProductSizeSelectionPresenter, PoqProductDetailPresenter {
    
    public var animationParams: AddToBagAnimationParams?
    public func startAddToBagAnimation(using param: AddToBagAnimationParams) {
        
    }
    
    /// The id of the selectd product.
    public var selectedProductId: Int?
    
    /// The externalId of the selected product.
    public var selectedProductExternalId: String?

    /// Flagged true if the table view should be reload. Usually used when the view will appear.
    public var shouldReloadTableView = true

    /// The tracking source this is used to dispatch GA events.
    public var trackingSource: PoqTrackingSource?
    
    /// The service of the ProductDetailViewController. The service is the view model of the viewcontroller and corresponds to the modern architecture of PoqPlatform. TODO: This is not being used. We should be using this instead of the view model.
    public var service: PoqProductDetailService {
        let service = ModularProductDetailViewModel()
        service.presenter = self
        return service
    }
    
    /// Used to calculate the position of the add to bag TODO: why do we need this - we should rely on the XIB.
    public final var addToBagNavbarShowLimit = CGFloat(210)
    
    /// The old version of the viewmodel. This will be depracted in future revisions. TODO: deprecate the viewmodel approach.
    public var viewModel: ProductDetailViewModel?
    
    /// The cell containing the image slides. TODO: We need to deprecate this in favor of the service/setup/contentItem approach.
    public var imageViewCell: ProductInfoViewCell?
    
    /// Used by the IDM photo gallery to render full screen images. TODO: We should retire IDM photo as it's currently not being maintained properly and the functionality is pretty basic.
    public var fullScreenImages: [AnyObject] = []
    
    /// Add to bag animator.
    public weak var sizeSelectionTransitioningDelegate: UIViewControllerTransitioningDelegate?
    
    /// The delegate that handles the size selection.
    public var sizeSelectionDelegate: SizeSelectionDelegate? {
        return self
    }
    
    // Navbar items
    
    /// The add to wishlist button TODO: rename this properly to wishlistButton.
    public var likeButton: UIButton?
    
    /// Content item used to generate the cells. TODO: This should have a struct for readability.
    public var content:[(identifier: String, height: CGFloat)] = []
    
    /// Height of the product Sizes cell. TODO: deprecate this in favour of auto layout.
    public let productSizesCellHeight = 90
    
    /// Height of the product reviews cell. TODO: Deprecate this in favour of auto layout.
    public let productReviewsRowHeight = 280
    
    /// Height of the product colors cells. TODO: Deprecate this in favour of auto layout.
    public let productColorsCellHeight = 60
    
    /// Height of the current screen. TODO: Remove hacky approach for screen height calculations.
    public let baseDeviceHeight = 480
    
    /// The height of the toolbar. This is invalid with the introduction of safeAreaLayout. TODO: We need to make sure that this is handled in the XIB file on iOS 11 and 10.
    public let toolbarHeight = 50.0

    /// The height of the cell that points to the size guide TODO: Remove this and rely on autolayout
    public let productSizeGuideCellHeight = 44
    
    /// The height of the empty cell
    public let emptyCellHeight = 50
    
    /// The x position of the done button. Used to offset the button, for esthetic purpuoses TODO: We need to remove this as it is not iOS Standard. Clients can change their own designs to the buttons.
    public let doneButtonX: CGFloat = 16
    
    /// The y position of the done button. Used to offset the button, for esthetic purpuoses TODO: We need to remove this as it is not iOS Standard. Clients can change their own designs to the buttons.
    public let doneButtonY: CGFloat = 25
    
    /// The width of the done button. Used to offset the button, for esthetic purpuoses TODO: We need to remove this as it is not iOS Standard. Clients can change their own designs to the buttons.
    public let doneButtonWidth: CGFloat = 44
    
    /// The height of the done button. Used to offset the button, for esthetic purpuoses TODO: We need to remove this as it is not iOS Standard. Clients can change their own designs to the buttons.
    public let doneButtonHeight: CGFloat = 44
    
    // Cell identifiers
    
    /// The cell identifier of the product info view cell. TODO: remove this and use when generating content method without exposing as public property.
    public var productInfoViewCellIdentifier = ProductInfoViewCell.poqReuseIdentifier
    
    /// The cell identifier of the product description view cell. TODO: remove this and use when generating content method without exposing as public property.
    public var productDescriptionViewCellIdentifier = ProductDescriptionViewCell.poqReuseIdentifier
    
    /// The cell identifier of the product size views cell. TODO: remove this and use when generating content method without exposing as public property.
    public var productSizesViewCellIdentifier = ProductSizesViewCell.poqReuseIdentifier
    
    /// The cell identifier of the product reviews view cell. TODO: remove this and use when generating content method without exposing as public property.
    public var productReviewsViewCellIdentifier = ProductReviewsViewCell.poqReuseIdentifier
    
    /// The cell identifier of the product colors view cell. TODO: remove this and use when generating content method without exposing as public property.
    public var productColorsViewCellIdentifier = ProductColorsViewCell.poqReuseIdentifier
    
    /// The cell identifier of the product add to bag view cell. TODO: remove this and use when generating content method without exposing as public property.
    public var productAddToBagViewCellIdentifier = ProductAddToBagViewCell.poqReuseIdentifier
    
    /// The cell identifier of the product reward view cell. TODO: remove this and use when generating content method without exposing as public property.
    public var productRewardDetailsViewCellIdentifier = ProductRewardDetailsViewCell.poqReuseIdentifier
    
    /// The cell identifier of the product card details view cell. TODO: This doesn't exist.
    public var productSizeGuideViewCellIdentifier = "ProductSizeGuideViewCellIdentifier"
    
    /// The cell identifier of the product card details view cell. TODO: This doesn't exist.
    public var careDetailsViewCellIdentifier = "CareDetailsViewCellIdentifier"
    
     /// The cell identifier of the product card details view cell. TODO: This doesn't exist.
    public var emptyViewCellIdentifier = "EmptyCellIdentifier"
    
    /// The cell identifier of the product delivery view cell. TODO: remove this and use when generating content method without exposing as public property.
    public var productDeliveryViewCellIdentifier = ProductDeliveryViewCell.poqReuseIdentifier

    // IBOutlets
    
    /// The table view that renders this detail view. TODO: This an optional and not force unwrap.
    @IBOutlet public weak var tableView: UITableView!
    
    // ______________________________________________________
    
    // MARK: - UI delegates
    
    /// Called when the view is loaded. Triggers the setting up of the navigation bar, the nib registration, and the view model.
    override open func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        
        registerNibs()
        
        setUpTableView()

        // Set view model for networking
        viewModel = ProductDetailViewModel(viewControllerDelegate: self)
        
        loadProductDetails()
        
        self.view.accessibilityIdentifier = AccessibilityLabels.productDetailView
    }
    
    /// Sets up the navigation bar layout.
    public func setupNavigationBar() {
        
        navigationItem.leftBarButtonItem = setupPDPBackButton()
        
        if AppSettings.sharedInstance.pdpNavigationBarHidden {
            navigationItem.titleView = nil
        }
        // Disable while product data is loaded
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    /// Sets up the table view and hides the anvigation bar if required. TODO: We should remove the hiding by changing the constraint value.
    public func setUpTableView() {
        // Hide empty cells
        tableView?.tableFooterView = UIView(frame: CGRect.zero)
        
        // Move table view up if the navigation bar is transparent hidden.
        // All client projects design their PDP and sign off before release.
        // Technically they don't change their navigation bar visibility (pdp design) without design sign off
        // Every design sign off is an app release in this case
        // So this paramater should be removed from Developer Center
        // Instead we need to create a custom Xib in client repo and use Insets
        // For this reason, Modular PDP doesn't implement this
        // TODO: Please retire this setting regarding above case
        
        if AppSettings.sharedInstance.pdpNavigationBarHidden {
            tableView?.contentInsetAdjustmentBehavior = .never
        }
        
        // Hide empty cells
        tableView?.tableFooterView = UIView(frame: .zero)
    }
    
    /// Share Button to be shown as rightBarButtonItem in PDP level.
    ///
    /// - Returns: The share bar button item.
    public func pdpShareButton() -> UIBarButtonItem? {
        
        let pdpShareButtonStyle = ResourceProvider.sharedInstance.clientStyle?.pdpShareButtonStyle
        
        let pdpShareButton = UIButton(frame: SquareBurButtonRect)
        pdpShareButton.configurePoqButton(style: pdpShareButtonStyle)
        
        return UIBarButtonItem(customView: pdpShareButton)
    }
    
    /// Back Button to be shown as leftBarButtonItem in PDP level.
    ///
    /// - Returns: The back button item.
    public func pdpBackButton() -> UIBarButtonItem? {
        
        return NavigationBarHelper.setupBackButton(self)
    }
    
    /// Sets up the back button item action by using the previously defined by pdpBackButton().
    ///
    /// - Returns: The pdp back button item with the added to it.
    public func setupPDPBackButton() -> UIBarButtonItem? {
        
        let backButton = pdpBackButton()
        
        if let customView = backButton?.customView as? UIButton {
            
            customView.addTarget(self,
                                 action: #selector(ProductDetailViewController.backButtonPressed(sender:)),
                                 for: .touchUpInside)
        }
        
        return backButton
    }
    
    /// Sets up the share button.
    ///
    /// - Returns: The share button with the action attached to it.
    public func setupPDPShareButton() -> UIBarButtonItem? {
    
        let shareButton = pdpShareButton()
        
        if let customView = shareButton?.customView as? UIButton {
            
            customView.addTarget(self,
                                 action: #selector(ProductDetailViewController.shareButtonPressed(sender:)),
                                 for: .touchUpInside)
        }
        
        return shareButton
    }
    
    // MARK: - ButtonActions.

    /// Called when the share button has been pressed.
    ///
    /// - Parameter sender: The sender object of the action.
    @objc public func shareButtonPressed(sender: UIButton) {
        
        shareButtonClicked(sender)
    }
    
    /// Called when the back button has been pressed.
    ///
    /// - Parameter sender: The sender object of the action.
    @objc public func backButtonPressed(sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }

    // MARK: - RegisterNibs

    /// Registers table view cells to the modular PDP. It uses Poq's builtin cell register functionality via registerPoqCells().
    open func registerNibs() {
        
        let cellsToRegister: [UITableViewCell.Type] = [ProductInfoViewCell.self, ProductColorsViewCell.self, ProductDescriptionViewCell.self, ProductSizesViewCell.self, ProductReviewsViewCell.self, ProductAddToBagViewCell.self, ProductRewardDetailsViewCell.self, ProductDeliveryViewCell.self]
        tableView.registerPoqCells(cellClasses: cellsToRegister)
    }
    
    /// Loads the product's details by calling the product detail endpoint together with the product's id.
    public func loadProductDetails() {
        
        // Both external id and poq product id is needed
        // For better deeplinking support
        if let productId = selectedProductId {
            
            self.viewModel?.getProduct(productId,
                                       externalId: selectedProductExternalId)
        }
    }
    
    /// Called when the view is scheduled for appearance. The MB property pdpNavigationBarHidden makes the navigation bar available or not based on the requirements of the screen. The view controller relies on ##shouldReloadTableView## to flag a reload of the table or not.
    ///
    /// - Parameter animated: Indicates if the appearance will occur in a animated fashion or not.
    override open func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setNavigationBarBackgroundHidden(AppSettings.sharedInstance.pdpNavigationBarHidden)
        
        if shouldReloadTableView {
            
            tableView.reloadData()
            
        } else {
            
            // Refresh ProductColorsViewCell to recenter ScrollView.
            if let productColorsIndexPath = tableView.indexPathsForVisibleRows?.filter({ content[$0.row].identifier == productColorsViewCellIdentifier }),
                productColorsIndexPath.count > 0,
                let cell = tableView.cellForRow(at: productColorsIndexPath[0]) as? ProductColorsViewCell,
                let productColorsView = cell.productColorsView {
                
                cell.updateScrollViewWithCGSize(productColorsView.frame.size)
            }
        }
        
        shouldReloadTableView = true
    }
    
    /// Called when the view is about to disapear we do this to make background visible again in case we made it invisible previously.
    ///
    /// - Parameter animated: Indicates if the appearance will occur in a animated fashion or not.
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Set back navigation bar background
        setNavigationBarBackgroundHidden(false)
    }
    
    /// Called when the view disappeared. We do this to unflag a potential reload of the table view.
    ///
    /// - Parameter animated: Indicates if the appearance will occur in a animated fashion or not.
    override open func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        shouldReloadTableView = false
    }
    
    // MARK: - NetworkDelegates
    
    /// Called when a network request has started in this viewcontroller.
    ///
    /// - Parameter networkTaskType: The type of the task currently starting.
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        // Enable back
        navigationItem.leftBarButtonItem?.isEnabled = true
        
        // Disable share during network operation
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    /// Called when a network request completed on this viewcontroller.
    /// We use these to add content items with their respective information.
    ///
    /// - Parameter networkTaskType: The type of network task that currently finished.
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        // Enable share
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        if networkTaskType == PoqNetworkTaskType.productDetails {
            
            self.likeButton?.isHidden = self.viewModel?.product == nil
            
            // Update like button
            if let product: PoqProduct = self.viewModel?.product {
                let isFavorite = product.id.flatMap { WishlistController.shared.isFavorite(productId: $0) } ?? false
                likeButton?.isSelected = isFavorite
            }
           
            // Hide share button if the product url is empty. Otherwise share sheet will look empty
            if let productURL = viewModel?.product?.productURL, !productURL.isEmpty {
                
                if AppSettings.sharedInstance.pdpHasShareButton {
                    // Set share button according to cloud setting
                    navigationItem.rightBarButtonItem = setupPDPShareButton()
                }
            }
            
            // Clear the content first
            content = []
            
            // Set up content cells
            // Content.append somehow was giving compile error
            // Append info cell
            // Height is updated with respect to screen height, this number is arbitrary
            content.insert((identifier: productInfoViewCellIdentifier, height:300), at: content.count)
            
            // Append colors if there is more then 1 color
            if let productColors = viewModel?.product?.productColors, productColors.count > 1 {
                
                content.insert((identifier: productColorsViewCellIdentifier, height: CGFloat(productColorsCellHeight)), at: content.count)
            }
            
            // Add To Bag Independent Cell
            if AppSettings.sharedInstance.isAddToBagBlockOnClassicPdpEnabled { 
                
                content.insert((identifier: productAddToBagViewCellIdentifier,
                    height:74),
                               at: content.count)
            }
            
            // Append Product Reward Details
            if AppSettings.sharedInstance.isProductRewardDetailsOnClassicPdpEnabled {
                
                content.insert((identifier: productRewardDetailsViewCellIdentifier, height: 80), at: content.count)
            }
            
            // Append Description
            if let description = viewModel?.product?.description, !description.isEmpty {
                
                content.insert((identifier: productDescriptionViewCellIdentifier,
                    height: AppSettings.sharedInstance.productDescriptionCellHeight),
                               at: content.count)
            }
            
            // Append sizes
            if let shouldShowSizes = viewModel?.product?.hasMultipleSizes, shouldShowSizes, AppSettings.sharedInstance.isSizeInformationRowShown {
                
                content.insert((identifier: productSizesViewCellIdentifier, height: CGFloat(productSizesCellHeight)), at: content.count)
            }
            
            // Product size guide link at the end of page (cloud configurable)
            if AppSettings.sharedInstance.isSizeGuideOnPDPEnabled && !AppSettings.sharedInstance.sizeGuideOnPDPPageId.isEmpty {
                
                content.insert((identifier: productSizeGuideViewCellIdentifier, height:CGFloat(productSizeGuideCellHeight)), at: content.count)
            }
            
            // Care details link at the end of page (cloud configurable)
            if AppSettings.sharedInstance.isCareDetailsPageOnPDPEnabled && !AppSettings.sharedInstance.careDetailsOnPDPPageId.isEmpty {
                
                content.insert((identifier: careDetailsViewCellIdentifier, height:CGFloat(productSizeGuideCellHeight)), at: content.count)
            }
            
            // Delivery link at the end of page (cloud configurable)
            if AppSettings.sharedInstance.isDeliveryPageOnPDPEnabled && !AppSettings.sharedInstance.deliveryPageOnPDPPageId.isEmpty {
                
                content.insert((identifier: productDeliveryViewCellIdentifier, height:CGFloat(productSizeGuideCellHeight)), at: content.count)
            }
            
            if AppSettings.sharedInstance.isEmptyCellOnTheBottomOfPDPEnabled {
                content.insert((emptyViewCellIdentifier, CGFloat(emptyCellHeight)), at: content.count)
            }
            
            // TODO: Append reviews
            
            // Setup images
            self.fullScreenImages = []
            
            if let productImages = self.viewModel?.product?.productPictures {
                
                for productImage in productImages {
                    
                    if let imageUrlString = productImage.url, let imageUrl = URL(string: imageUrlString), let photo = IDMPhoto(url: imageUrl) {
                        self.fullScreenImages.append(photo)
                    }
                }
            }
            
            // Setup images
            self.imageViewCell?.product = self.viewModel?.product
            self.imageViewCell?.swipeView?.reloadData()
            
            // Reload tableview to show product details
            self.tableView?.reloadData()
            
            // Duplicate control is done by helper
            // Add product to recently viewed
            if let productId = self.viewModel?.product?.id {
                var recentlyViewedProduct = RecentlyViewedProduct()
                recentlyViewedProduct.productId = productId
                PoqDataStore.store?.create(recentlyViewedProduct, maxCount: maxNumberOfRecentlyViewedProducts, completion: nil)
            }
            
            if let trackProductId = self.viewModel?.product?.id, let trackProductTitle = self.viewModel?.product?.title {
             // Log product detail load
                PoqTrackerHelper.trackProductDetailLoad(trackProductTitle, extraParams: ["ProductID": String(trackProductId)])
            }
        } else if networkTaskType == PoqNetworkTaskType.postBag {
           
            if let statusCode = viewModel?.message.statusCode, statusCode == 200 {
                
                BagHelper.completedAddToBag()
            } else {
                var errorMessage = "ERROR_ADDED_TO_BAG".localizedPoqString
                
                if let errorMsg = viewModel?.message.message {
                    errorMessage = errorMsg
                }
                BagHelper.showPopupMessage(errorMessage, isSuccess: false)
            }
            
            navigationItem.leftBarButtonItem?.isEnabled = true
            updateRightButton(animated: true)
        }
    }
    
    /// Called in case a network task has failed in this viewcontroller.
    ///
    /// - Parameters:
    ///   - networkTaskType: The network task type that failed.
    ///   - error: The error object that was generated as a consequence of the failure.
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        if networkTaskType == .productDetails {
            let title =  "ERROR".localizedPoqString
            let message = "UNABLE_TO_CONNECT".localizedPoqString
            let actionTitle = "OK".localizedPoqString
            
            let validAlertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            self.alertController = validAlertController
            
            validAlertController.addAction(UIAlertAction.init(title: actionTitle, style: UIAlertActionStyle.default, handler: { (_: UIAlertAction) in
                self.backButtonClicked()
            }))
        
            self.present(validAlertController, animated: true, completion: { 
                // Completion handler once everything is dismissed
            })
        }
        
        // Enable back
        navigationItem.leftBarButtonItem?.isEnabled = true
        
        // Enable share in case network call fails
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    // ______________________________________________________
    
    // MARK: - Delegates
    
    // Share button
    ///
    /// - Parameter sender: The sender object that triggered the share action.
    public func shareButtonClicked(_ sender: Any?) {
        
        guard let productURL = viewModel?.product?.productURL, !productURL.isEmpty else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [productURL], applicationActivities: nil)
        // New Excluded Activities Code
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
        
        switch sender {
        case let barButton as UIBarButtonItem:
            activityViewController.popoverPresentationController?.barButtonItem = barButton
        case let sourceView as UIView:
            activityViewController.popoverPresentationController?.sourceView = sourceView
            activityViewController.popoverPresentationController?.sourceRect = sourceView.bounds
        default:
            activityViewController.popoverPresentationController?.sourceView = view
        }
        activityViewController.completionWithItemsHandler = shareDidComplete
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    /// Triggered when the share action completed.
    ///
    /// - Parameters:
    ///   - activity: The type of activity that the share completed with.
    ///   - completed: Checked wether or not the action has completed TODO: We need to find out why we need this.
    ///   - returnedItems: The items returned by the share action TODO: We need to find out why we need this.
    ///   - error: Error in case the action resulted as an error.
    public func shareDidComplete(_ activity: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) {
        
        Log.verbose("Product Share: \(activity?.rawValue ?? "nil")")
        
        PoqShareTracking.trackShareEvent(activity?.rawValue)
        PoqTrackerV2.shared.share(productId: viewModel?.product?.id ?? 0, productTitle: viewModel?.product?.title ?? "")
    }
    
    /// Product color selection delegate.
    ///
    /// - Parameters:
    ///   - selectedColor: The elected color in string format.
    ///   - productId: The product id of the color.
    ///   - externalId: The external id of the product color.
    ///   - selectedColorProductId: The selected color product id (PoqPlatform uses a product for each color variant).
    public func colorSelected(_ selectedColor: String, productId: Int, externalId: String, selectedColorProductId: Int?) {
        
        // Should reset content
        self.content = []
        self.viewModel?.product?.color = selectedColor
        self.viewModel?.getProduct(productId, externalId: externalId)
    }
    
    /// Called when the photo browser goes to a certain image.
    ///
    /// - Parameters:
    ///   - photoBrowser: The photo browser instance.
    ///   - index: The index of the shown image.
    public func photoBrowser(_ photoBrowser: IDMPhotoBrowser!, didShowPhotoAt index: UInt) {
        
        imageViewCell?.swipeView?.scrollToItem(at: IndexPath(row: Int(index), section: 0),
                                               at: .centeredHorizontally,
                                               animated: true)
        
        imageViewCell?.pageControl?.currentPage = Int(index)
    }
    
    /// Called when the photo browser has closed at a page.
    ///
    /// - Parameters:
    ///   - photoBrowser: Instance to the photo browser.
    ///   - index: The index of the image being dismissed from view.
    public func photoBrowser(_ photoBrowser: IDMPhotoBrowser!, didDismissAtPageIndex index: UInt) {}
    
    /// Called when the full screen has been triggered.
    ///
    /// - Parameters:
    ///   - photoBrowser: Instance to the photo browser.
    ///   - activityType: The type of activity that needs to be tracked when full screen has been triggered.
    ///   - photo: The description of the photo.
    @nonobjc public func photoBrowser(_ photoBrowser: IDMPhotoBrowser!, activityViewControllerActivitySelected activityType: String!, andPhoto photo: AnyObject!) {
        PoqTrackerHelper.trackFullScreenImageViewSharing(activityType ?? "")
    }
    
    /// Sets the proper content inset if for when the navigation bar is hidden.
    ///
    /// - Parameter isNavigationBarHidden: Wether the navigation bar is hidden or not.
    public func setContentInset(isNavigationBarHidden: Bool) {
    }
    
    /// Triggered when a network task has been completed.
    ///
    /// - Parameter networkTaskType: The type of the network task completed.
    public func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
    }
    
    /// Called by the presenter protocol to register cells. TODO: Cell registration should happen here.
    public func setCellRegistration() {
    }
    
    /// Called by the presenter protocol to set the refresh control instance.
    public func setRefreshControl() {
    }
    
    /// Called by the presenter protocol to set the collection view layout.
    public func setCollectionViewLayout() {
    }
    
    /// Called by the presenter protocol to set the right bar button. TODO: This should replace the current setup of the navigation bar.
    public func setupRightBarButton() {
    }
    
    /// Action for when the share action has been triggered. TODO: Move the share action to this.
    ///
    /// - Parameter sender: The sender object generating the action
    public func shareDidTap(sender: AnyObject?) {
    }
    
    /// Action when an image has been taped in the Productinfo. TODO Right now it's being handled by the IDM photobrowser future versions should call this.
    ///
    /// - Parameters:
    ///   - index: The index of the image that was taped
    ///   - imageView: The imageview for tapped
    public func imageDidTap(at index: IndexPath, forImageView imageView: PoqAsyncImageView) {
    }
    
    /// Called when the view needs to be reloaded.  TODO: Move view updates to this.
    public func reloadView() {
    }
}

// MARK: - Delegate for tableview data source.
extension ProductDetailViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return content.count
    }
    
    /// Generates the contents of the cells and the layout of the page.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableview.
    ///   - indexPath: The indexpath for the generated cell.
    /// - Returns: Valid tableviewcell .
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // If user scrolls while downloading data (esp. color swatches)
        // We need this check to avoid runtime crash
        if indexPath.row < content.count {
            
            let productDetailContentCell = content[indexPath.row]
            
            if productDetailContentCell.identifier == productInfoViewCellIdentifier {
                
                // Info / Image /Basic details
                let cell: ProductInfoViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)

                if let product = viewModel?.product {
                    
                    cell.setup(using: product)
                }
                
                cell.productDetailDelegate = self
                imageViewCell = cell
                likeButton = cell.likeButton
                likeButton?.isHidden = AppSettings.sharedInstance.hidePDPLikeButton
                
                // Update like button
                if let product = viewModel?.product {
                    let isFavorite = product.id.flatMap { WishlistController.shared.isFavorite(productId: $0) } ?? false
                    likeButton?.isSelected = isFavorite
                }

                cell.accessibilityIdentifier = AccessibilityLabels.productBasicDetail
                
                return cell
            } else if productDetailContentCell.identifier == productColorsViewCellIdentifier {
                
                let cell = viewModel?.getCellForColor(tableView, indexPath: indexPath, delegate: self)
                
                return cell ?? UITableViewCell()
            } else if productDetailContentCell.identifier == productDescriptionViewCellIdentifier {
                
                // Description
                
                let cell: ProductDescriptionViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
                
                if let product = viewModel?.product {
                    
                    cell.setup(using: product)
                }
                
                cell.productDetailViewDelegate = self
                cell.accessibilityIdentifier = AccessibilityLabels.productDescription

                return cell
            } else if productDetailContentCell.identifier == productSizesViewCellIdentifier {
                
                // Sizes
                
                let cell: ProductSizesViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
                
                if let product = viewModel?.product {
                    
                    cell.setup(using: product)
                }
                
                cell.accessibilityIdentifier = AccessibilityLabels.sizeSelection
                return cell
            } else if productDetailContentCell.identifier == productReviewsViewCellIdentifier {
                
                // TODO: Reviews
                
                let cell: ProductReviewsViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
                
                return cell
            } else if productDetailContentCell.identifier == productSizeGuideViewCellIdentifier {
                
                // Size guide
                let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: productDetailContentCell.identifier)
                // Use the customised disclosure indicator
                cell.createAccessoryView()
                cell.textLabel?.text = AppLocalization.sharedInstance.sizeGuidePageOnPDPTitle
                cell.textLabel?.font = AppTheme.sharedInstance.pdpSizeGuideLabelFont
                return cell
            } else if productDetailContentCell.identifier == careDetailsViewCellIdentifier {
                
                // Care details
                let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: productDetailContentCell.identifier)
                // Use the customised disclosure indicator
                cell.createAccessoryView()
                cell.textLabel?.text = AppLocalization.sharedInstance.careDetailsOnPDPTitle
                cell.textLabel?.font = AppTheme.sharedInstance.pdpCareDetailsLabelFont
                return cell
            } else if productDetailContentCell.identifier == productDeliveryViewCellIdentifier {
                
                // Delivery
                let cell: ProductDeliveryViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)

                return cell
            } else if productDetailContentCell.identifier == productAddToBagViewCellIdentifier {
                
                // Add to Bag Button 
                let cell: ProductAddToBagViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)

                cell.productDetailDelegate = self
                
                if let product = viewModel?.product {
                    
                    cell.setup(using: product)
                }

                return cell
            } else if productDetailContentCell.identifier == productRewardDetailsViewCellIdentifier {
                
                // Product Details
                
                let cell: ProductRewardDetailsViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
                
                if let product = viewModel?.product {
                    
                    cell.setup(using: product)
                }
                
                return cell
            } else {
                
                Log.warning("Product Detail: Unknown cell identifier")
                return UITableViewCell()
            }
        } else {
            
            Log.warning("Product Detail: Unknown cell identifier")
            return UITableViewCell()
        }
    }
}

// MARK: - Table view delegate that determines the Tableview layout.
extension ProductDetailViewController: UITableViewDelegate {
    
    /// Generates the header for the view. If the PDP is branded then the header is rendered accordingly.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableview that will receive the given header.
    ///   - section: The section of the table view that receives the given header.
    /// - Returns: A valid ui used as a header for the section.
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let brandBlock: PoqBlock = viewModel?.product?.headerImage else {
            return nil
        }
        
        let brandHeader = BrandedHeaderView(headerBlock: brandBlock)
        
        return brandHeader
    }
    
    /// Calculates the height of the header for a given section.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the table view that will receive the ehader.
    ///   - section: The section to which the header will be attached to.
    /// - Returns: A float value for the height of the header.
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let brandBlock: PoqBlock = viewModel?.product?.headerImage else {
            return 0
        }
        
        return BrandedHeaderView.calculateSize(brandBlock).height
    }
    
    /// Variable height support. Adds diffrent heights for each cell as specified by their settings. TODO: We need to clear this out in favor of a newly.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableview.
    ///   - indexPath: The indexpath for the given cell.
    /// - Returns: The height of the cell.
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // If user scrolls while downloading data (esp. color swatches)
        // We need this check to avoid runtime crash
        if indexPath.row < content.count {
            
            let productDetailContentCell = content[indexPath.row]
            
            if productDetailContentCell.identifier == productInfoViewCellIdentifier {
                
                if AppSettings.sharedInstance.isClassicPDPInfoCellFixedHeight == true {
                    
                    return AppSettings.sharedInstance.classicPDPInfoCellFixedHeight
                }
                
                var height = tableView.bounds.height
                
                // Reduce the height for the navigation bar
                if !AppSettings.sharedInstance.pdpNavigationBarHidden {
                    // TODO: IMO this is wrong and we should not be removing this arbitary amount but it works for how we use it.
                    height -= topLayoutGuide.length
                }
                
                // When scroll gets to the end of image, it should stick the add to bag button to the navbar
                if let imageHeight = imageViewCell?.swipeView?.bounds.height, imageHeight > 0 {
                    addToBagNavbarShowLimit = imageHeight
                }
                
                if let productColors = viewModel?.product?.productColors, productColors.count > 1 {
                    
                    // Show product colors in page fold
                    height -= CGFloat(productColorsCellHeight)
                } else {

                    // Image is taller so add color swatch cell height for treshold
                    addToBagNavbarShowLimit += CGFloat(productColorsCellHeight)
                }
                
                return CGFloat(height)
            } else {
                
                return CGFloat(productDetailContentCell.height)
            }
            
        } else {
            
            return CGFloat(0)
        }
    }
    
    /// Row selection for default cell implementations only.
    ///
    /// - Parameters:
    ///   - tableView: Reffrence to the tableview.
    ///   - indexPath: The indexpath of the cell.
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // If user scrolls while downloading data (esp. color swatches)
        // We need this check to avoid runtime crash
        if indexPath.row < content.count {
            
            let productDetailContentCell = content[indexPath.row]
            
            if productDetailContentCell.identifier == productSizeGuideViewCellIdentifier {
                
                // Load size guide page detail
                if let pageId = AppSettings.sharedInstance.sizeGuideOnPDPPageId.toInt() {
                    
                    NavigationHelper.sharedInstance.loadPageDetail(pageId, pageTitle: "SIZE_GUIDE".localizedPoqString, isModal: true, topViewController: self)
                }
            }
            
            if productDetailContentCell.identifier == careDetailsViewCellIdentifier {
                
                // Load size guide page detail
                if let pageId = AppSettings.sharedInstance.careDetailsOnPDPPageId.toInt() {
                    
                    NavigationHelper.sharedInstance.loadPageDetail(pageId, pageTitle: AppLocalization.sharedInstance.careDetailsOnPDPTitle, isModal: true, topViewController: self)
                }
            }

            if productDetailContentCell.identifier == productDeliveryViewCellIdentifier {
                
                // Load size guide page detail
                if let deliveryPageOnPDPPageId = AppSettings.sharedInstance.deliveryPageOnPDPPageId.toInt() {
                    NavigationHelper.sharedInstance.loadPageDetail(deliveryPageOnPDPPageId, pageTitle: AppLocalization.sharedInstance.deliveryPageOnPDPTitle, isModal: true, topViewController: self)
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Handles screen specific actions.
extension ProductDetailViewController: ProductDetailViewDelegate {
    
    /// Triggered when the product has been added to the bag.
    public func addToBagButtonClicked() {
        
        guard let product = viewModel?.product else {
            Log.error("No product in viewModel to add to bag")
            return
        }
        
        guard let productSizes = product.productSizes, !productSizes.isEmpty else {
            Log.error("No productSizes in product to add to bag")
            return
        }
        
        if product.isOneSize {
            
            guard let validProduct = self.viewModel?.product, let validTitle = validProduct.title, let validProductSizes = validProduct.productSizes, let firstValidProductSize = validProductSizes.first else {
                return
            }
            
            self.viewModel?.product?.selectedSizeID = firstValidProductSize.id
            self.viewModel?.addToBag()
            
            BagHelper.logAddToBag(validTitle, productSize: firstValidProductSize, trackingSource: trackingSource)
            
        } else {
            
            if AppSettings.sharedInstance.shouldCheckForOutOfStockeProducts {
                guard let productOutOfStock = viewModel?.product?.isOutOfStock(), productOutOfStock else {
                    showSizeSelector(using: product)
                    return
                }
                
                BagHelper.showPopupMessage(AppLocalization.sharedInstance.bagOutOfStockMessage, isSuccess: false)
                
            } else {
                showSizeSelector(using: product)
            }
        }
    }
    
    /// Triggered when the like (wishlist) button has been pressed
    open func likeButtonClicked() {
        guard let likebutton = likeButton, let product = viewModel?.product else {
            return
        }
        
        if !likebutton.isSelected {
            
            WishlistController.shared.add(product: product)
            // Track add to shoppinglist
            if let productTitle = product.title {
                
                let valuePrice: Double = product.trackingPrice
                PoqTrackerHelper.trackAddToWishList(productTitle, value: valuePrice, extraParams: ["Screen": "PDP"])
            }
        } else {
            if let productId = product.id {
                WishlistController.shared.remove(productId: productId)
            }
        }
        
        likebutton.isSelected = !likebutton.isSelected
    }
    
    /// Single tap to show Full screen image view.
    ///
    /// - Parameters:
    ///   - index: The indexpath of the taped image.
    ///   - imageView: The image view that was taped.
    open func imageViewClicked(_ index: Int, imageView: PoqAsyncImageView) {
        
        Log.verbose("Image tapped \(index)")
        
        if fullScreenImages.count != 0 {
            
            let browser = IDMPhotoBrowser(photos: fullScreenImages, animatedFrom: imageView)
            browser?.delegate=self
            browser?.usePopAnimation=true
            
            // Done buttons
            let doneButtonFrame = CGRect(x: doneButtonX, y: doneButtonY, width: doneButtonWidth, height: doneButtonHeight)
            
            let closeButton = AppSettings.sharedInstance.pdpFullScreenCloseButtonHasBackground ? RoundedCloseButton(frame: doneButtonFrame) : CloseButton(frame: doneButtonFrame)
            
            browser?.doneButtonImage = closeButton.backgroundImage(for: .normal)
            browser?.doneButtonFrame = doneButtonFrame
            
            // Share
            browser?.displayActionButton=true
            // Left right
            browser?.displayArrowButton=false
            
            // Number of images
            browser?.displayCounterLabel=true
            browser?.counterLabelFont = AppTheme.sharedInstance.mainTextFont
            
            // Use white background
            browser?.useWhiteBackgroundColor = true
            imageView.backgroundColor = UIColor.white
            
            // Share button color
            browser?.view.tintColor = UIColor.black
            // Circular track color
            browser?.trackTintColor = UIColor.clear
            // Downloaded progress color
            browser?.progressTintColor=AppTheme.sharedInstance.mainColor
            
            browser?.scaleImage = imageView.image
            browser?.setInitialPageIndex(UInt(index))
            
            if let browserUnwrapped = browser, let productTitle = viewModel?.product?.title {
                present(browserUnwrapped, animated: true, completion: nil)
            
                // Log fullscreen image load
                PoqTrackerHelper.trackFullScreenImageViewLoad(productTitle)
            }
        }
    }
    
    /// Triggered when the description of the product has been clicked.
    public func descriptionClicked() {
        guard let body = viewModel?.product?.body else {
            Log.error("Product description is not found")
            return
        }
        
        let title = AppLocalization.sharedInstance.productDescriptionOnPDPTitle
        presentDescription(title, pageHTML: body)
    }
    
    /// Triggered when the reviews button is clicked.
    public func reviewsButtonClicked() {
    
        guard let viewModel = viewModel,
            let productId = viewModel.productId else {
            
                Log.error("Missing productID trying to public Reviews")
            
                return
        }
        
        // Open ReviewsViewController
        NavigationHelper.sharedInstance.loadReviews(productId)
    }
}

// MARK: - Handles the size selection functionality for the screen.
extension ProductDetailViewController: SizeSelectionDelegate {
    
    /// Called when the add to bag action has occured.
    ///
    /// - Parameter size: The size object that was added to bag.
    public func handleSizeSelection(for size: PoqProductSize) {
        
        viewModel?.product?.selectedSizeID = size.id
        viewModel?.addToBag()
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        // Log add to bag action
        BagHelper.logAddToBag(viewModel?.product?.title, productSize: size, trackingSource: trackingSource)
    }
    
    /// Called when the size selection controller has disappeared from the screen, given that the product does display it (one size products do not display this hence not called).
    ///
    /// - Parameter sizeSelectionViewController: The size selection controller reffrence.
    public func sizeSelectionViewControllerWillDismiss(_ sizeSelectionViewController: ProductSizeSelectionViewController) {
        
        shouldReloadTableView = false
    }
}
