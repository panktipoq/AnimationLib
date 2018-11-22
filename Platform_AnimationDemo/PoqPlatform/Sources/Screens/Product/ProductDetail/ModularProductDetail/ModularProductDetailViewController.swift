//
//  ModularProductDetailViewController.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Mahmut Canga on 21/12/2016.
//
//

import AVFoundation
import AVKit
import IDMPhotoBrowser
import PoqModuling
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

/**
 
 ModularProductDetailViewController is one of the main View Controllers in Poq applications which can normaly be found as a child of a given ProductListViewController item.
 The view consists of a UICollectionView that contains a number of cells. These make the rendering of the screen modular in the sense that diffrent sections can be removed/swaped easily.
 Its architecture is MVVM and its model is lazy loaded to conserve memory until the model is needed.
 ## Usage Example: ##
 ````
 let viewController = ModularProductDetailViewController(nibName: "ModularProductDetailView", bundle: nil)
 ````
 */
open class ModularProductDetailViewController: PoqBaseViewController, PoqProductDetailPresenter, PoqProductSizeSelectionPresenter, UICollectionViewDelegate {

    public var animationParams: AddToBagAnimationParams?
    
    /// The source that handles the analytics tracking.
    public var trackingSource: PoqTrackingSource?
    /// The current selected product id.
    open var selectedProductId: Int?
    /// The current selected product id. This needs to be included with all product requests.
    open var selectedProductExternalId: String?
    /// Handles the size selection box animation when a product is added to the bag.
    open var sizeSelectionTransitioningDelegate: UIViewControllerTransitioningDelegate?
    /// The delegate that handles the selections size when a product is added to the bag.
    open var sizeSelectionDelegate: SizeSelectionDelegate? {
        return self
    }
    
    /// The service that handles data operations for this controller. 
    lazy open var service: PoqProductDetailService = self.getService()
    
    /// Returns the service that will be used for this view controller. TODO: This can be a variable.
    ///
    /// - Returns: The service that will be used for this view controller.
    open func getService() -> PoqProductDetailService {
        
        let service = ModularProductDetailViewModel()
        service.presenter = self
        return service
    }
    
    /// The refresh control used when the collection view executes a pull to refresh.
    let refreshControl = UIRefreshControl()
    
    /// The collection view that renders the modular PDP. 
    @IBOutlet open weak var collectionView: UICollectionView? {
        
        didSet {
            
            collectionView?.dataSource = self
            collectionView?.delegate = self
            collectionView?.backgroundColor = AppTheme.sharedInstance.plpCollectionViewBackgroundColor
            
            setCollectionViewLayout()
            setCellRegistration()
            setRefreshControl()
        }
    }
    
    /// Registers the cells with the collection view.
    open func setCellRegistration() {
        
        let customCells: [UICollectionViewCell.Type] = [
            PoqProductInfoContentBlockView.self,
            PoqProductPromotionContentBlockView.self,
            PoqProductDescriptionContentBlockView.self,
            PoqProductSwatchColorsContentBlockView.self,
            PoqProductActionContentBlockView.self,
            PoqProductLinkContentBlockView.self,
            PoqRecentlyViewedContentBlockCell.self,
            PoqProductShareContentBlockView.self,
            PoqProductSizesContentBlockView.self,
            PoqProductSizesContentBlockView.self
        ]
        
        collectionView?.registerPoqCells(cellClasses: customCells)
    }
    
    // ______________________________________________________
    
    // MARK: - UI delegates
    
    /// Triggers the setup of the navigation bar. Loads the product details from the backend.
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        if AppSettings.sharedInstance.pdpNavigationBarHidden {
            collectionView?.contentInsetAdjustmentBehavior = .never
        }
        
        setupNavigationBar()
        
        navigationItem.leftBarButtonItem = setupBackButton()
        
        setupRightBarButton()
        
        service.getProductDetails(byProductId: selectedProductId, externalId: selectedProductExternalId)
    }
    
    /// Hides the navigation bar background to give way to a enhanced photo gallery to the top of the screen.
    ///
    /// - Parameter animated: if the view comes in as animated or not.
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBarBackgroundHidden(AppSettings.sharedInstance.pdpNavigationBarHidden)
        updateWishlistIcon()
    }
        
    /// Returns the background of the navigation bar to visible.
    ///
    /// - Parameter animated: if the view comes in as animated or not.
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setNavigationBarVisible()
    }
    
    // ______________________________________________________
    
    // MARK: - Presenter implementation protocols
    
    /// Called when a network task has finished. We are not implementing this method in a ModularProductDetailViewController extension so other classes can override it if needed.
    ///
    /// - Parameter networkTaskType: The type of the network task that completed.
    open func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.productDetails:
            reloadView()
            setupRightBarButton()
            if let productId = selectedProductId {
                var recentlyViewedProduct = RecentlyViewedProduct()
                recentlyViewedProduct.productId = productId
                PoqDataStore.store?.create(recentlyViewedProduct, maxCount: maxNumberOfRecentlyViewedProducts, completion: nil)
            }

            if let product = service.product, let productId = product.id {
                
                var productTrackingPrice = service.product?.price ?? 0.0
                
                if let productSpecialPrice = service.product?.specialPrice, let productPrice = service.product?.price, productSpecialPrice < productPrice {
                    productTrackingPrice = productSpecialPrice
                }
                
                PoqTrackerHelper.trackProductDetailLoad(product.title ?? "", extraParams: ["ProductID": String(productId), "ProductPrice": String(productTrackingPrice)])
            }
            
        case PoqNetworkTaskType.postBag:
            if let params = animationParams {
                startAddToBagAnimation(using: params)
            } else {
                BagHelper.incrementBagBy(1)
                BagHelper.completedAddToBag()
            }
        case PoqNetworkTaskType.postCartItems:
            BagHelper.completedAddToBag()
        default:
            Log.error("Controller doesn't respond \(networkTaskType)")
        }
    }
    
    public func startAddToBagAnimation(using param: AddToBagAnimationParams) {
        // Test Code
        if let tabController = self.tabBarController as? TabBarViewController,
            let tabbarItem = tabController.viewForTabBarItemAtIndex(2) {
            let startFrame = CGRect(x: param.productImageFrame.origin.x,
                                    y: param.productImageFrame.origin.y - (self.collectionView?.contentOffset.y ?? 0),
                                    width: param.productImageFrame.size.width,
                                    height: param.productImageFrame.size.height)
            
            let endFrame = CGPoint(x: tabbarItem.center.x,
                                   y: tabController.tabBar.center.y)
            let settings = PDPAddToBagAnimatorViewSettings(productImage: param.productImage,
                                                           startFrame: startFrame,
                                                           endOrigin: endFrame)
            ProductDetailAnimator.startAddToBagAnimation(with: settings) {
                BagHelper.incrementBagBy(1)
                BagHelper.completedAddToBag()
            }
        } else {
            BagHelper.incrementBagBy(1)
            BagHelper.completedAddToBag()
        }
    }
  
    /// Reloads the collection view and updates with new data.
    public func reloadView() {

        collectionView?.reloadData()
    }
    
    /// Updates wishlist button
    public func updateWishlistIcon() {
        let infoContentCell = collectionView?
            .visibleCells
            .compactMap { $0 as? PoqProductInfoContentBlockView }
            .first
        
        infoContentCell?.updateWishlistIcon()
    }
    
    // ______________________________________________________
    
    // MARK: - UICollectionViewDelegate
    
    /// Triggered when a modular PDP cell has been selected
    ///
    /// - Parameters:
    ///   - collectionView: reffrence to the collection view that renders the PDP
    ///   - indexPath: the indexpath for the selected photo
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let contentItem = service.content[indexPath.row]
            
            guard let contentItemType = contentItem.cellType as? PoqProductDetailCellType else {
                Log.error("Wrong content item type.")
                return
            }
            
            guard case PoqProductDetailCellType.htmlDescription(let description) = contentItemType else {
                
                Log.error("Wrong cell type provided.")
                return
            }
            
            presentDescription(contentItem.title ?? "", pageHTML: description)
        }

// MARK: - PoqProductDetailPresenter Implementations

    public func setCollectionViewLayout() {
        
        guard let collectionViewFlowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            
            Log.error("Collection view flow layout is not found.")
            return
        }
        
        collectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
    }
    
    /// Adds the refresh control to the collection view.
    public func setRefreshControl() {
        collectionView?.refreshControl = refreshControl
        refreshControl.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(ModularProductDetailViewController.refreshData(_:)), for: .valueChanged)
    }
    
    /// Triggered when the pull to refresh action is executed. Fetches the product details from the backend.
    ///
    /// - Parameter refreshControl: The refresh control that triggered the action.
    @objc public func refreshData(_ refreshControl: UIRefreshControl) {
        
        refreshControl.endRefreshing()
        service.getProductDetails(byProductId: selectedProductId, externalId: selectedProductExternalId)
    }
    
    /// Sets up the back button.
    ///
    /// - Returns: Valid back button used with this view controller.
    @objc open func setupBackButton() -> UIBarButtonItem? {
    
        return NavigationBarHelper.setupBackButton(self)
    }
    
    /// Sets up the right bar button for the modular PDP.
    @objc open func setupRightBarButton() {
        
        var rightButtonItem: UIBarButtonItem?
        
        if AppSettings.sharedInstance.isVideoButtonEnabledOnPdp {
            
            if let videoUrl = service.product?.videoURL, let _ = URL(string: videoUrl) {
                // TODO: Move this button generation code to Client Style to allow bespoke.
                let playVideoButton = UIButton(frame: SquareBurButtonRect)
                let playVideoIcon = ImageInjectionResolver.loadImage(named: "PlayVideoIcon")
                playVideoButton.setImage(playVideoIcon, for: .normal)
                playVideoButton.addTarget(self, action: #selector(ModularProductDetailViewController.videoDidTap), for: .touchUpInside)
                rightButtonItem = UIBarButtonItem(customView: playVideoButton)
            }
        } else {
            let shareVideoButton = UIButton(frame: SquareBurButtonRect)

            let shareButtonStyle = ResourceProvider.sharedInstance.clientStyle?.pdpShareButtonStyle
            
            shareVideoButton.configurePoqButton(style: shareButtonStyle)

            shareVideoButton.addTarget(self, action: #selector(ModularProductDetailViewController.shareDidTap(sender:)), for: .touchUpInside)
         
            rightButtonItem = UIBarButtonItem(customView: shareVideoButton)
        }
        
        navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    /// Triggered when the back action is executed.
    ///
    /// - Parameter sender: The button that triggered the action.
    @objc public func backButtonPressed(sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    /// Triggered when the video is tapped for play. Tracks the action.
    @objc public func videoDidTap() {
        
        guard let videoUrlValue = service.product?.videoURL, !videoUrlValue.isEmpty else {
            
            Log.error("Video URL is missing. Can not play")
            return
        }
        
        guard let videoUrl = URL(string: videoUrlValue) else {
            
            Log.error("Video URL is not valid: \(videoUrlValue)")
            return
        }
 
        let player = AVPlayer(url: videoUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
        
        PoqTrackerV2.shared.videoPlay(productId: service.product?.id ?? 0, productTitle: service.product?.title ?? "")
        PoqTrackerHelper.trackVideoPlayed(for: service.product?.title ?? "")
    }
    
    /// Triggered when the share button has been tapped.
    ///
    /// - Parameter sender: The button that triggers the action.
    @objc public func shareDidTap(sender: AnyObject?) {
        
        guard let productUrlValue = service.product?.productURL, !productUrlValue.isEmpty else {
            
            Log.error("Product URL is missing. Can not share")
            return
        }
        
        guard let productUrl = URL(string: productUrlValue) else {
            
            Log.error("Product URL is not valid: \(productUrlValue)")
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [productUrl], applicationActivities: nil)
        
        if let barButtonItem = sender as? UIBarButtonItem {
            activityViewController.popoverPresentationController?.barButtonItem = barButtonItem
        } else if let sourceView = sender as? UIView {
            activityViewController.popoverPresentationController?.sourceView = sourceView
            activityViewController.popoverPresentationController?.sourceRect = sourceView.bounds
        } else {
            activityViewController.popoverPresentationController?.sourceView = view
        }
        
        activityViewController.completionWithItemsHandler = shareDidComplete
            
        present(activityViewController, animated: true, completion: nil)
    }

    /// Triggered when the share action has executed.
    ///
    /// - Parameters:
    ///   - activity: The activity on which the share action completed.
    ///   - completed: Flag if the action is completed or not.
    ///   - returnedItems: The returned items from the share action.
    ///   - error: If not nil an error has occured when trying to share.
    public func shareDidComplete(_ activity: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) {
        
        Log.verbose("Product Share: \(activity?.rawValue ?? "nil")")
        
        PoqShareTracking.trackShareEvent(activity?.rawValue)
        PoqTrackerV2.shared.share(productId: service.product?.id ?? 0, productTitle: service.product?.title ?? "")
    }
    
    /// Triggred when a image in the photo gallery has been tapped.
    ///
    /// - Parameters:
    ///   - index: The index of the image tapped.
    ///   - imageView: The image view of the photo from the gallery view.
    public func imageDidTap(at index: IndexPath, forImageView imageView: PoqAsyncImageView) {
        
        Log.verbose("Full screen image presenter called")
        
        guard let productImages = service.product?.productPictures else {
            
            Log.error("Product images are not found. Can not open fullscreen photo browser")
            return
        }
        
        let fullscreenImages = generateFullscreenImage(using: productImages)
        
        guard fullscreenImages.count > 0 else {
            
            Log.error("Can not generate fullscreen images. Product picture URLs must be corrupted")
            return
        }
        
        present(fullscreenImages: fullscreenImages, witInitialIndex: index, forImageView: imageView)
        logFullscreenPhotoBrowser()
    }
    
    /// Creates a fullscreen view for the photo gallery complete with share button and page details.
    ///
    /// - Parameter productImages: The list of products that need to be rendered in the viewcontroller.
    /// - Returns: The photo objects that will be rendered.
    fileprivate func generateFullscreenImage(using productImages: [PoqProductPicture]) -> [IDMPhoto] {
        
        var fullscreenImages = [IDMPhoto]()
        
        for productImage in productImages {
            
            guard let productImageUrlValue = productImage.url, !productImageUrlValue.isEmpty else {
                
                Log.error("Product image url does not exist. Skipping in fullscreen image browser")
                return []
            }
            
            guard let productImageUrl = URL(string: productImageUrlValue) else {
                
                Log.error("Product image url format is not correct: \(productImageUrlValue)")
                return []
            }
            
            fullscreenImages.append(IDMPhoto(url: productImageUrl))
        }

        return fullscreenImages
    }
    
    /// Called when the photo browser needs to be displayed.
    ///
    /// - Parameters:
    ///   - fullScreenImages: The fullscreen photo objects that need to be rendered.
    ///   - index: The index of the photo browser.
    ///   - imageView: The imageview in which the image is rendered.
    fileprivate func present(fullscreenImages fullScreenImages: [IDMPhoto], witInitialIndex index: IndexPath, forImageView imageView: PoqAsyncImageView) {
        
        let browser = IDMPhotoBrowser(photos: fullScreenImages, animatedFrom: imageView)
        browser?.delegate = self
        browser?.usePopAnimation = true
        browser?.shareButtonImage = ImageInjectionResolver.loadImage(named: "PDPBrowserShareDefault")
        
        // Done buttons
        let doneButtonFrame = CGRect(x: 16, y: 25, width: 44, height: 44)
        
        let closeButton = AppSettings.sharedInstance.pdpFullScreenCloseButtonHasBackground ? RoundedCloseButton(frame: doneButtonFrame) : CloseButton(frame: doneButtonFrame)
        
        browser?.doneButtonImage = closeButton.backgroundImage(for: .normal)
        browser?.doneButtonFrame = doneButtonFrame
        
        // Share
        browser?.displayActionButton = true
        // Left right
        browser?.displayArrowButton = false
        
        // Number of images
        browser?.displayCounterLabel = true
        browser?.counterLabelFont = AppTheme.sharedInstance.mainTextFont
        
        // Use white background
        browser?.useWhiteBackgroundColor = true
        imageView.backgroundColor = UIColor.white
        
        // Share button color
        browser?.view.tintColor = UIColor.black
        // Circular track color
        browser?.trackTintColor = UIColor.clear
        // Downloaded progress color
        browser?.progressTintColor = AppTheme.sharedInstance.mainColor
        
        browser?.setInitialPageIndex(UInt(index.row))
        
        guard let browserUnwrapped = browser else {
            Log.error("Browser could not be presented")
            return
        }
        self.present(browserUnwrapped, animated: true, completion: nil)
    }
    
    /// Tracks the fullscreen action of the photo browser.
    fileprivate func logFullscreenPhotoBrowser() {
        
        guard let productTitle = service.product?.title, !productTitle.isEmpty else {
            
            Log.error("Can not track fullscreen browser. Product title is empty")
            return
        }
        
        PoqTrackerHelper.trackFullScreenImageViewLoad(productTitle)
        PoqTrackerV2.shared.fullScreenImageView(productId: service.product?.id ?? 0, productTitle: productTitle)
    }
    
    /// Invalidates the cell layout of the cell.
    ///
    /// - Parameter indexPath: The indexpath of the cell who's layout needs to be invalidated.
    fileprivate func invalidateCellLayout(at indexPath: IndexPath) {
        let invalidationContext = UICollectionViewFlowLayoutInvalidationContext()
        invalidationContext.invalidateItems(at: [indexPath])
        collectionView?.collectionViewLayout.invalidateLayout(with: invalidationContext)
    }
}

// MARK: - Handles the size selection specific methods.
extension ModularProductDetailViewController: SizeSelectionDelegate {
    
    /// Triggered when size has been selected.
    ///
    /// - Parameter size: The product size object.
    open func handleSizeSelection(for size: PoqProductSize) {
        
        guard let productValidated = service.product else {
            
            Log.error("View model doesn't return product data")
            return
        }
        
        guard let productId = productValidated.id, let productSizeId = size.id else {
            
            Log.error("Product Id \(productValidated.id ?? 0) and Selected Size Id are not valid  \(size.id ?? 0)")
            return
        }
        
        service.addToBag(selectedSize: productSizeId, forProductId: productId)
        
        BagHelper.logAddToBag(productValidated.title, productSize: size, trackingSource: trackingSource)

        PoqTracker.sharedInstance.trackAddToBag(for: productValidated, productSize: size)
    }
}

// ______________________________________________________

// MARK: - IDMPhotoBrowserDelegate Delegates

extension ModularProductDetailViewController: IDMPhotoBrowserDelegate {
    
    /// Triggered when the photobrowser has shown an image.
    ///
    /// - Parameters:
    ///   - photoBrowser: The reffrence to the photo browser object.
    ///   - index: The index of the photo browser.
    public func photoBrowser(_ photoBrowser: IDMPhotoBrowser!, didShowPhotoAt index: UInt) {
        
        // It is not guaranteed the order of ProductInfoCB as well as having only one ProductInfoCB.
        // So it is better to update any of them found in collectionView.
        for i in 0..<service.content.count {
            
            guard let productInfoCell = collectionView?.cellForItem(at: IndexPath(item: i, section: 0)) as? PoqProductInfoContentBlockView else {
                
                continue
            }
            
            productInfoCell.imagesCollectionView?.scrollToItem(at: IndexPath(row: Int(index), section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    /// Tracks the photo browser full screen view when the image is shared.
    ///
    /// - Parameters:
    ///   - photoBrowser: Reffrence to the photo browser object.
    ///   - activityType: The type of share activity that was triggered.
    ///   - photo: The photo object that was shared.
    public func photoBrowser(_ photoBrowser: IDMPhotoBrowser!, activityViewControllerActivitySelected activityType: String!, andPhoto photo: Any!) {
        
        PoqTrackerHelper.trackFullScreenImageViewSharing(activityType ?? "PDP FullScreen Photo Action")
    }
}

// ______________________________________________________

// MARK: - UICollectionViewDataSource

extension ModularProductDetailViewController: UICollectionViewDataSource {

    /// Returns the number of items in a given section. By default there is only one section that handles the rendering of the modular cells.
    ///
    /// - Parameters:
    ///   - collectionView: Reffrence to the collectionview object.
    ///   - section: The section that renders the collection view cell.
    /// - Returns: The number of content items in the section.
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return service.content.count
    }
    
    /// Fetches the uicollectionviewcell that renders one row of product detail information.
    ///
    /// - Parameters:
    ///   - collectionView: Reffrence to the collection view object.
    ///   - indexPath: The indexpath of the modular cell inside the PDP.
    /// - Returns: A valid cell for a part of the PDP information.
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let contentItem = service.content[indexPath.row]

        let reuseIdentifier = contentItem.cellType.cellClass.poqReuseIdentifier

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        setup(cell: cell, at: indexPath)
        
        /// This action makes sense only for real cell, which will be on screen, not for static/sizing
        if let productDetailCell = cell as? PoqProductDetailCell {
            productDetailCell.presenter = self
            
            productDetailCell.separator?.isHidden = indexPath.row == (service.content.count - 1)
        }
        
        return cell
    }
}

// MARK: - Handles the uicollectionview cells as full width cells.
extension ModularProductDetailViewController: FullWidthAutoresizedCellFlowLayoutDelegate {
    
    /// Sets up the cell for the modular PDP with the correct information received from the backend.
    ///
    /// - Parameters:
    ///   - cell: The cell that needs to be setup.
    ///   - indexPath: The indexpath of the cell.
    public func setup(cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let productDetailCell = cell as? PoqProductDetailCell else {
            return
        }

        var contentItem = service.content[indexPath.row]
        contentItem.invalidateCellBlock = {
            [weak self] in
            self?.invalidateCellLayout(at: indexPath)
        }

        productDetailCell.setup(using: contentItem, with: service.product)
    }
    
    /// The class used for the cell inside the modular PDP.
    ///
    /// - Parameter indexPath: The indexpath of the collectionview cell.
    /// - Returns: A valid cell type for the cell that is to be rendered.
    public func cellClass(at indexPath: IndexPath) -> UICollectionViewCell.Type? {
        guard service.content.count > indexPath.row else {
            assertionFailure("IndexPath out of range for CellClass")
            return nil
        }
        
        return service.content[indexPath.row].cellType.cellClass
    }
}
