//
//  LookbookImageViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 14/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

open class LookbookImageView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Attributes
    
    weak open var viewControllerDelegate: PoqBaseViewController?
    
    open var lookbookImageProducts: [PoqProduct] = []
    open var loadingProducts: Bool = false
    
    public var lookbookImage: PoqLookbookImage? {
        didSet {
            setupView()
        }
    }
    
    var spinnerView: PoqSpinner? {
        didSet {
            spinnerView?.tintColor = AppTheme.sharedInstance.mainColor
        }
    }
    
    var isProductAreaVisible: Bool = false
    open var productsCollectionCellViewSize = CGSize(width: 0, height: 0)
    
    // Lookbook configurations (cloud)
    open var lookbookImageProductsHeight: CGFloat = 0 // 1/3 of the screen height
    
    var hotspotButtons: [UIButton] = []
    var lastTappedHotspotButtonIndex: Int = -1
    
    // These variables are strictly for analytics events tracking only
    open var lookbookTitle: String?
    open var screenNumber: Int?
    
    // MARK: - IBOutlets
    
    @IBOutlet open weak var imageView: PoqAsyncImageView!
    @IBOutlet weak var shopButton: LookbookButton?
    
    @IBOutlet weak var shopButtonWidth: NSLayoutConstraint? {
        didSet {
            shopButtonWidth?.constant = CGFloat(AppSettings.sharedInstance.shopTheLookButtonWidth)
        }
    }
    
    @IBOutlet public weak var productsCollectionView: UICollectionView! {
        didSet {
            registerPoqCells()
        }
    }
    @IBOutlet weak var productsCollectionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Initializers
    
    open class func createLookbookImageView() -> LookbookImageView? {
        return NibInjectionResolver.loadViewFromNib()
    }
    
    open func registerPoqCells() {
        productsCollectionView.registerPoqCells(cellClasses: [ProductListViewCell.self])
    }
    
    // MARK: - View Delegates
    
    open func setupView() {
        var showHotspots = false
        var showShopButton = false
        
        if let hotspots = lookbookImage?.hotspots, hotspots.count > 0 {
            showHotspots = true
        }
        
        if let numberOfProducts = lookbookImage?.numberOfProducts, numberOfProducts > 0 {
            showShopButton = !showHotspots
        }
        
        if let imageURL = lookbookImage?.url {
            // Hotspots works only with one aspect ratio - AspectFit, so ignore cloud settings
            let cloudSettings = ImageHelper.returnImageScalingMode(fromString: AppSettings.sharedInstance.lookbookImageContentMode)
            imageView?.contentMode = showHotspots ? .scaleAspectFit : cloudSettings
            
            if let url = URL(string: imageURL) {
                imageView?.getImageFromURL(url, isAnimated: true, showLoadingIndicator: true, resetConstraints: showHotspots) { (image: UIImage?) in
                    
                    self.resetHotspots()
                }
            }
            
            PoqTrackerHelper.trackLookBookOpen(PoqTrackerActionType.ImageURL, label: imageURL)
        }
        
        shopButton?.isHidden = !showShopButton
        
        lookbookImageProductsHeight = UIScreen.main.bounds.size.height / 3
        
        // Hide products area
        productsCollectionViewHeightConstraint.constant = 0
        
        updateCollectionCellWidth()
    }
    
    // Set size of the cell adaptive to the screen
    open func updateCollectionCellWidth() {
        let productsPerPage = AppSettings.sharedInstance.lookbookImageProductsPerPage
        var numberOfColumns = CGFloat(productsPerPage)
        
        // Divide the whole screen width into x numbers of pieces.
        if lookbookImageProducts.count <= Int(floor(productsPerPage)) {
            numberOfColumns = CGFloat(floor(productsPerPage))
        }
        
        let width = UIScreen.main.bounds.size.width / numberOfColumns
        let height = CGFloat(lookbookImageProductsHeight)
        
        productsCollectionCellViewSize = CGSize(width: width, height: height)
    }
    
    func resetHotspots() {
        for hotspotButton in hotspotButtons {
            hotspotButton.removeFromSuperview()
        }
        
        hotspotButtons.removeAll()
        
        guard let hotspots = lookbookImage?.hotspots, hotspots.count > 0 else {
            return
        }
        
        for (index, hotspot) in hotspots.enumerated() {
            guard let identifier = hotspot.productId else {
                continue
            }
            
            guard let x = hotspot.x, let y = hotspot.y, let imageSize = imageView.image?.size, let scale = imageView.image?.scale else {
                continue
            }
            
            let hotspotButton = UIButton(type: .custom)
            hotspotButton.accessibilityIdentifier = "hotspots_button_\(identifier)"
            hotspotButton.tag = index
            hotspotButton.translatesAutoresizingMaskIntoConstraints = false
            hotspotButton.setImage(ImageInjectionResolver.loadImage(named: "HotspotIconDefault"), for: .normal)
            hotspotButton.setImage(ImageInjectionResolver.loadImage(named: "HotspotIconPressed"), for: .highlighted)
            hotspotButton.addTarget(self, action: #selector(hotspotButtonTapped), for: .touchUpInside)
            
            imageView.addSubview(hotspotButton)
            
            var xMultiplier: CGFloat = 2.0 * CGFloat(x) / (scale * imageSize.width)
            // Constraints do not accept 0 multipier
            // Just in case, also avoid negative one
            if xMultiplier < 1e-3 {
                xMultiplier = 1e-3
            }
            
            let centerXContraint = NSLayoutConstraint(item: hotspotButton, attribute: .centerX,
                                                      relatedBy: .equal,
                                                      toItem: imageView, attribute: .centerX,
                                                      multiplier: xMultiplier, constant: 0)
            
            var yMultiplier: CGFloat = 2.0 * CGFloat(y) / (scale * imageSize.height)
            if yMultiplier < 1e-3 {
                yMultiplier = 1e-3
            }
            
            let centerYContraint = NSLayoutConstraint(item: hotspotButton, attribute: .centerY,
                                                      relatedBy: .equal,
                                                      toItem: imageView, attribute: .centerY,
                                                      multiplier: yMultiplier, constant: 0)
            
            imageView.addConstraints([centerXContraint, centerYContraint])
            imageView.isUserInteractionEnabled = true
            
            hotspotButtons.append(hotspotButton)
        }
    }
    
    // MARK: - Collection View Data Delegations
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lookbookImageProducts.count
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < lookbookImageProducts.count else {
            return collectionView.dequeueContentNotFoundCell(forIndexPath: indexPath)
        }
        
        let cell: ProductListViewCell = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        cell.accessibilityIdentifier = AccessibilityLabels.lookBookProductCell
        
        cell.updateView(lookbookImageProducts[indexPath.item])
        
        return cell
    }
    
    // MARK: - Collection View Delegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < lookbookImageProducts.count else {
            return
        }
        
        let product = lookbookImageProducts[indexPath.item]
        
        Log.verbose("Open pdp for \(String(describing: product.title))")
        
        viewControllerDelegate?.presentedViewController?.dismiss(animated: true, completion: nil)
        
        // If there are related product ids then it goes to grouped plp rather then pdp (Home > Dining > Linea)
        if let relatedProductIDs = product.relatedProductIDs, !relatedProductIDs.isEmpty {
            NavigationHelper.sharedInstance.loadGroupedProduct(with: product)
        } else if let productId = product.id {
            NavigationHelper.sharedInstance.loadProduct(productId, externalId: product.externalID, source: ViewProductSource.lookbookShopTheLook.rawValue, productTitle: product.title)
        }
    }
    
    // MARK: - Collection View Layout Delegations

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return productsCollectionCellViewSize
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func showProductUnavailableAlert() {
        let title = "Sorry"
        let message = "Some of the products are not available.\nPlease try again later."
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        disableShopButton()
        
        viewControllerDelegate?.present(alert, animated: true, completion: nil)
    }
    
    func disableShopButton() {
        productsCollectionViewHeightConstraint?.constant = 0
        shopButton?.isHidden = true
    }
    
    // MARK: - Utility
    
    // Shop button loads products of the current lookbook image
    
    fileprivate func setupProductArea(_ isVisible: Bool = false, height: CGFloat = 0) {
        productsCollectionViewHeightConstraint?.constant = height
        isProductAreaVisible = isVisible
        shopButton?.isSelected = isVisible
    }
    
    @objc func hotspotButtonTapped(_ button: UIButton) {
        guard let hotspots = lookbookImage?.hotspots, button.tag >= 0, hotspots.count > button.tag else {
            return
        }
        
        let hotspot = hotspots[button.tag]
        
        if DeviceType.IS_IPAD {
            showPopover(forHotspot: hotspot, index: button.tag)
            
            return
        }

        guard let productId = hotspot.productId, let externalId = hotspot.externalId else {
            Log.error("ProductId or ExternalId missing for lookbook product. Cannot fetch details.")
            return
        }
        
        PoqTrackerV2.shared.lookbookTap(lookbookTitle: lookbookTitle ?? "", type: LookbookProductSource.hotspot.rawValue, productId: productId, screenNumber: screenNumber ?? 0)
        
        let product = lookbookImageProducts.first(where: { $0.id == productId })
        NavigationHelper.sharedInstance.loadProduct(productId, externalId: externalId, source: ViewProductSource.lookbookHotspot.rawValue, productTitle: product?.title ?? "")
    }
    
    fileprivate func loadImageProducts() {

        guard let lookbookPictureId = lookbookImage?.pictureId, !loadingProducts else {
            Log.error("Missing pictureId")
            return
        }

        guard let productIds = lookbookImage?.productExternalIds, !productIds.isEmpty else {
            Log.error("LookBook picture with id \(lookbookPictureId) doesn't have any products associated with it")
            return
        }
        
        let strProductIds = productIds.compactMap({ String($0) })
        PoqNetworkService(networkTaskDelegate: self).getLookbookImageProducts(lookbookPictureId, externalProductIds: strProductIds)
        loadingProducts = true

        // Track shop button click
        PoqTracker.sharedInstance.logAnalyticsEvent("Lookbook ShopIt", action: "Shop it button clicked page", label: String(lookbookPictureId), extraParams: nil)
    }
    
    fileprivate func showPopover(forHotspot hotspot: PoqImageHotspot, index: Int) {
        guard let productId = hotspot.productId else {
            return
        }
        
        guard !lookbookImageProducts.isEmpty else {
            lastTappedHotspotButtonIndex = index
            loadImageProducts()
            
            return
        }
        
        if let product = lookbookImageProducts.first(where: { $0.id == productId }) {
            
            guard let sourceView = hotspotButtons.first(where: { $0.tag == index }) else {
                return
            }
            
            let hotspotDetailViewController = LookbookHotspotDetailViewController(product: product)
            hotspotDetailViewController.cellDelegate = self
            
            hotspotDetailViewController.modalPresentationStyle = .popover
            
            hotspotDetailViewController.popoverPresentationController?.permittedArrowDirections = .any
            hotspotDetailViewController.popoverPresentationController?.sourceView = sourceView
            hotspotDetailViewController.popoverPresentationController?.sourceRect = sourceView.bounds

            viewControllerDelegate?.present(hotspotDetailViewController, animated: true, completion: nil)
            
            PoqTrackerV2.shared.lookbookTap(lookbookTitle: lookbookTitle ?? "", type: LookbookProductSource.hotspotDetail.rawValue, productId: product.id ?? 0, screenNumber: screenNumber ?? 0)

        } else {
            Log.error("We can't find product")
        }
    }
}

extension LookbookImageView {
    
    @IBAction public func lookbookButtonClicked(_ sender: Any?) {
        needsUpdateConstraints()
        
        if !isProductAreaVisible {
            // Property productId is only available for hotspots.
            PoqTrackerV2.shared.lookbookTap(lookbookTitle: lookbookTitle ?? "", type: LookbookProductSource.shopTheLook.rawValue, productId: 0, screenNumber: screenNumber ?? 0)
        }
        
        UIView.animate(withDuration: 0.3) {
            if self.isProductAreaVisible {
                self.setupProductArea()
            } else {
                self.setupProductArea(true, height: self.lookbookImageProductsHeight)
                
                if self.lookbookImageProducts.count == 0 {
                    self.loadImageProducts()
                    
                    if !self.loadingProducts {
                        self.setupProductArea()
                    }
                }
            }
            
            self.layoutIfNeeded()
        }
    }
}

extension LookbookImageView: ProductListViewCellDelegate {
    
    public func getIsPromoExpanded(_ productId: Int) -> Bool {
        // FIXME: We need to have a base collectionview that handles a generic set of functionality
        // Nothing to do
        return false
    }

    public func toggleExpandedProduct(_ product: PoqProduct) {
        // FIXME: We need to have a base collectionview that handles a generic set of functionality
        // Nothing to do
    }
}

// MARK: - Basic network task callbacks

extension LookbookImageView: PoqNetworkTaskDelegate {
    
    open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        presentSpinner()
    }

    open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        hideSpinner()
        loadingProducts = false
        
        if networkTaskType == PoqNetworkTaskType.lookbookImageProducts {
            if let result = result as? [PoqProduct], !result.isEmpty {
                lookbookImageProducts = result
            }
            
            if !lookbookImageProducts.isEmpty {
                updateCollectionCellWidth()
                
                if lastTappedHotspotButtonIndex < 0 {
                    productsCollectionView.reloadData()
                } else if let hotspots = lookbookImage?.hotspots, hotspots.count > lastTappedHotspotButtonIndex {
                    let hotspot = hotspots[lastTappedHotspotButtonIndex]
                    
                    showPopover(forHotspot: hotspot, index: lastTappedHotspotButtonIndex)
                    lastTappedHotspotButtonIndex = -1
                }
            } else {
                showProductUnavailableAlert()
            }
        }
    }

    open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        hideSpinner()
        loadingProducts = false
    }

    func presentSpinner() {
        if spinnerView == nil {
            let spinnerView = PoqSpinner(frame: .zero)

            addSubview(spinnerView)
            spinnerView.translatesAutoresizingMaskIntoConstraints = false
            spinnerView.applyCenterPositionConstraints()
        }
        
        spinnerView?.startAnimating()
    }
    
    func hideSpinner() {
        spinnerView?.stopAnimating()
        spinnerView?.removeFromSuperview()
    }
}
