//
//  ProductAvailabilityViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 02/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

open class ProductAvailabilityViewController: PoqBaseViewController, StoreListDelegate, PoqProductSizeSelectionPresenter {
    
    // Banner and description
    @IBOutlet weak var bannerImage: PoqAsyncImageView!
    @IBOutlet weak var bannerContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel?.font = AppTheme.sharedInstance.productAvailabilityBannerTitleFont
            titleLabel?.text = AppLocalization.sharedInstance.productInStoreAvailabilityTitle
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel?.font = AppTheme.sharedInstance.productAvailabilityBannerDescriptionFont
            descriptionLabel?.text = AppLocalization.sharedInstance.inStoreAvailabilityDescriptionText
        }
    }
    
    // Size
    @IBOutlet weak var sizeSelectView: UIView!
    @IBOutlet weak var sizeNameLabel: UILabel! {
        didSet {
            sizeNameLabel?.font = AppTheme.sharedInstance.productAvailabilitySelectionNameLabelFont
            sizeNameLabel?.text = AppLocalization.sharedInstance.inStoreSizeText
            
        }
    }
    @IBOutlet weak var sizeValueLabel: UILabel! {
        didSet {
            sizeValueLabel?.font = AppTheme.sharedInstance.productAvailabilitySelectionValueFont
            sizeValueLabel?.text = AppLocalization.sharedInstance.inStoreSelectSizeText
        }
    }
    @IBOutlet weak var sizeSelectViewHeightConstraint: NSLayoutConstraint!
    
    // Store
    @IBOutlet weak var storeSelectView: UIView!
    @IBOutlet weak var storeNameLabel: UILabel! {
        didSet {
            storeNameLabel?.font = AppTheme.sharedInstance.productAvailabilitySelectionNameLabelFont
            storeNameLabel?.text = AppLocalization.sharedInstance.inStoreStoreText
        }
    }
    @IBOutlet weak var storeValueLabel: UILabel! {
        didSet {
            storeValueLabel?.font = AppTheme.sharedInstance.productAvailabilitySelectionValueFont
            storeValueLabel?.text = AppLocalization.sharedInstance.inStoreSelectStoreText
        }
    }
    
    // Availability result
    @IBOutlet weak var availabilityResultView: UIView!
    @IBOutlet weak var availabilityResultImage: UIImageView!
    @IBOutlet weak var availabilityResultLabel: UILabel! {
        didSet {
            availabilityResultLabel?.font = AppTheme.sharedInstance.productAvailabilityResultFont
            availabilityResultLabel?.text = ""
            availabilityResultImage?.alpha = 0
        }
    }
    
    // Data variables
    var product: PoqProduct?
    var productStock: PoqStoreStock?
    var selectedStoreId: Int?
    var selectedSizeId: Int?
    var resultViewBorderRadius = CGFloat(30)
    var isSizeAvailable = true
    var isNetworkTaskProgressing = false
    var viewModel: ProductAvailabilityViewModel?
    
    var unknownSize = "Select size"
    
    // Size selection animation
    public var sizeSelectionTransitioningDelegate: UIViewControllerTransitioningDelegate?
    public var sizeSelectionDelegate: SizeSelectionDelegate? {
        return self
    }
    
    func setUpNavigationItems() {
        // Set navigation title
        navigationItem.titleView = NavigationBarHelper.setupTitleView(AppLocalization.sharedInstance.productAvailabilityNavigationTitle, titleFont: AppTheme.sharedInstance.productAvailabilityNavigationTitleFont)
        
        //set up back button
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupCloseButton(self)
        navigationItem.rightBarButtonItem = nil
        
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ProductAvailabilityViewModel(viewControllerDelegate:self)
        viewModel?.product = self.product
        
        // Disable size selection if product has one size and its name is empty
        if let product = self.product {
            
            if let productSizes = product.productSizes {
                
                if productSizes.count == 1 {
                    
                    if let productFirstSize = productSizes[0].size {
                        
                        if productFirstSize == "" {
                            
                            self.isSizeAvailable = false
                        }
                    }
                }
            }
        }
        
        // Set selected store from favorites
        // Because if user doesn't have a favorite store
        // This screen will never be opened
        if let _ = productStock {
            selectedStoreId = StoreHelper.getFavoriteStoreId()
        }
        
        setUpNavigationItems()
        
        // Load banner
        let bannerUrl = DeviceType.IS_IPAD ? AppSettings.sharedInstance.iPadProductAvailabilityBannerUrl : AppSettings.sharedInstance.productAvailabilityBannerUrl
        bannerImage?.getImageFromURL(URL(string: bannerUrl)!, isAnimated: false)
        
        if DeviceType.IS_IPAD {
            bannerContainerHeightConstraint.constant = 300.0
        }
        
        // Set banner title/description fonts
        self.titleLabel?.font = AppTheme.sharedInstance.productAvailabilityBannerTitleFont
        self.titleLabel?.text = AppLocalization.sharedInstance.productInStoreAvailabilityTitle
        self.descriptionLabel?.font = AppTheme.sharedInstance.productAvailabilityBannerDescriptionFont
        self.descriptionLabel?.text = AppLocalization.sharedInstance.inStoreAvailabilityDescriptionText
        // Set store selection fonts
        self.storeNameLabel?.font = AppTheme.sharedInstance.productAvailabilitySelectionNameLabelFont
        self.storeNameLabel?.text = AppLocalization.sharedInstance.inStoreStoreText
        self.storeValueLabel?.font = AppTheme.sharedInstance.productAvailabilitySelectionValueFont
        self.storeValueLabel?.text = AppLocalization.sharedInstance.inStoreSelectStoreText
        
        let selectStoreTapGesture = UITapGestureRecognizer(target: self, action: #selector(ProductAvailabilityViewController.selectStoreTapped(_:)))
        self.storeSelectView.addGestureRecognizer(selectStoreTapGesture)
        
        if self.isSizeAvailable {
            
            // Set availability result fonts
            self.availabilityResultLabel?.font = AppTheme.sharedInstance.productAvailabilityResultFont
            self.availabilityResultLabel?.text = ""
            self.availabilityResultImage?.alpha = 0
            
            let selectSizeTapGesture = UITapGestureRecognizer(target: self, action: #selector(ProductAvailabilityViewController.selectSizeTapped(_:)))
            self.sizeSelectView.addGestureRecognizer(selectSizeTapGesture)
            
            // Set size selection fonts
            self.sizeNameLabel?.font = AppTheme.sharedInstance.productAvailabilitySelectionNameLabelFont
            self.sizeNameLabel?.text = AppLocalization.sharedInstance.inStoreSizeText
            self.sizeValueLabel?.font = AppTheme.sharedInstance.productAvailabilitySelectionValueFont
            self.sizeValueLabel?.text = AppLocalization.sharedInstance.inStoreSelectSizeText
        } else {
            
            // Remove size seleciton
            self.sizeSelectView.removeFromSuperview()
        }
        
        // Show availability as product and stock has alread been transferred
        showAvailabilityResult()
        
        // Track screen load
        PoqTrackerHelper.trackProductAvailabilityLoad(product!.title!)
    }
    
    override open func closeButtonClicked() {
        
        super.closeButtonClicked()
        NavigationHelper.sharedInstance.clearTopMostViewController()
    }
    
    @objc func selectSizeTapped(_ sender: UIGestureRecognizer) {
        
        guard let productUnwrapped = product, !isNetworkTaskProgressing else {
            Log.error("We either don't have a product or a network task is ongoing")
            return
        }
            
        showSizeSelector(using: productUnwrapped)
    }
    
    @objc func selectStoreTapped(_ sender: UIGestureRecognizer) {
        
        if !self.isNetworkTaskProgressing {
            
            // Due to this vc is a modal, we need to set top view controller
            NavigationHelper.sharedInstance.setUpTopMostViewController(self)
            NavigationHelper.sharedInstance.loadStoreSelection(self)
        }
        
    }
    
    public func storeSelected(_ store: PoqStore) {
        
        Log.verbose("Favorite store selected\n:\(String(describing: store.name))")
        self.selectedStoreId = store.id!
        self.storeValueLabel?.text = store.name!
        NavigationHelper.sharedInstance.clearTopMostViewController()
        
        // Track store selection
        PoqTrackerHelper.trackSelectMyStore(store.name!)
        
        checkAvailablity()
    }
    
    func checkAvailablity() {
        
        if let selectedSizeId = self.selectedSizeId {
            
            if let selectedStoreId = self.selectedStoreId {
                
                self.viewModel?.getStoreStock(selectedStoreId, sizeId: selectedSizeId)
            }
            
        } else {
            
            if let selectedStoreId = self.selectedStoreId {
                
                // api will get a suitable size from my size selections
                self.viewModel?.getStoreStock(selectedStoreId, sizeId: 0)
            }
            
        }
        
    }
    
    func showAvailabilityResult() {
        
        if let storeStock = self.productStock {
            
            if storeStock.selectedSizeName != nil && storeStock.name != nil && storeStock.isInStock != nil {
                
                // Set selected store name
                self.storeValueLabel?.text = storeStock.name
                
                if storeStock.selectedSizeName == self.unknownSize {
                    
                    showCheckAvailability()
                } else {
                    
                    // Set selected size here
                    // Otherwise api returns Select Size as size name
                    // This overrides the UI copy
                    self.sizeValueLabel?.text = storeStock.selectedSizeName
                    
                    if storeStock.isInStock! {
                        
                        Log.verbose("Store Stock: Product is available")
                        
                        // Product is available
                        self.availabilityResultLabel?.textColor = AppTheme.sharedInstance.availabilityInStoreTextColor
                        
                        // API doesn't return size name for
                        // products that doesn't have product size (i.e. frying pan)
                        if storeStock.selectedSizeName!.isEmpty {
                            
                            self.availabilityResultLabel?.text = String(format: AppLocalization.sharedInstance.availableAtStore, arguments: [storeStock.name!])
                        } else {
                            
                            self.availabilityResultLabel?.text = String(format: AppLocalization.sharedInstance.sizeAvailableAtStore, arguments: [storeStock.selectedSizeName!, storeStock.name!])
                            
                        }
                        
                        showTicker()
                        
                    } else {
                        
                        Log.verbose("Store Stock: Product is not available")
                        
                        // Not available
                        self.availabilityResultLabel?.textColor = AppTheme.sharedInstance.availabilityNotInStoreTextColor
                        
                        // API doesn't return size name for
                        // products that doesn't have product size (i.e. frying pan)
                        if storeStock.selectedSizeName!.isEmpty {
                            
                            self.availabilityResultLabel?.text = String(format: AppLocalization.sharedInstance.unavailableAtStore, arguments: [storeStock.name!])
                            self.availabilityResultLabel?.adjustsFontSizeToFitWidth = true
                        } else {
                            
                            self.availabilityResultLabel?.text = String(format: AppLocalization.sharedInstance.sizeUnavailableAtStore, arguments: [storeStock.selectedSizeName!, storeStock.name!])
                            self.availabilityResultLabel.adjustsFontSizeToFitWidth = true
                        }
                        
                        showHungerOn()
                    }
                }
                
            } else {
                
                // Missing some data
                showAvailabilityOff()
            }
        } else {
            
            // Incoming data is nil
            showCheckAvailability()
        }
    }
    
    func initResultView(_ color: CGColor) {
        self.availabilityResultView.isHidden = false
        self.availabilityResultView.layer.cornerRadius = self.resultViewBorderRadius
        self.availabilityResultView.layer.borderColor = color
        self.availabilityResultView.layer.borderWidth = 1
        self.availabilityResultView.setNeedsDisplay()
    }
    
    func showCheckAvailability() {
        
        Log.verbose("Store Stock: check in store availabilty")
        self.availabilityResultLabel?.textColor = AppTheme.sharedInstance.availabilityOffTextColor
        self.availabilityResultLabel?.text = AppLocalization.sharedInstance.checkInStoreAvailability
        initResultView(AppTheme.sharedInstance.availabilityOffTextColor.cgColor)
        
        showHungerOn()
    }
    
    func showAvailabilityOff() {
        
        Log.verbose("Store Stock: availabilty is off")
        
        // Availability is off
        self.availabilityResultLabel?.textColor = AppTheme.sharedInstance.availabilityOffTextColor
        self.availabilityResultLabel?.text = AppLocalization.sharedInstance.storeInformationUnavailable
        self.availabilityResultLabel.adjustsFontSizeToFitWidth = true
        initResultView(AppTheme.sharedInstance.availabilityOffTextColor.cgColor)
        showHungerOff()
    }
    
    func showHungerOff() {
        
        self.availabilityResultImage?.image = UIImage(named: "ico-sizes-disabled")
        self.availabilityResultImage?.alpha = 0.5
        self.availabilityResultImage?.setNeedsDisplay()
        initResultView(AppTheme.sharedInstance.availabilityOffTextColor.cgColor)
        
    }
    
    func showHungerOn() {
        
        self.availabilityResultImage?.image = UIImage(named: "ico-sizes-disabled")
        self.availabilityResultImage?.alpha = 1
        self.availabilityResultImage?.setNeedsDisplay()
        initResultView(AppTheme.sharedInstance.availabilityOffTextColor.cgColor)
    }
    
    func showTicker() {
        
        self.availabilityResultImage?.image = UIImage(named: "ico-sizes")
        self.availabilityResultImage?.alpha = 1
        self.availabilityResultImage?.setNeedsDisplay()
        initResultView(AppTheme.sharedInstance.availabilityInStoreTextColor.cgColor)
    }
    
    /**
     Called from view model when a network operation starts
     */
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        self.isNetworkTaskProgressing = true
    }
    
    /**
     Called from view model when a network operation ends
     */
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        self.isNetworkTaskProgressing = false
        
        if networkTaskType == PoqNetworkTaskType.storeStock {
            
            if let storeStock = self.viewModel?.storeStock {
                
                self.productStock = storeStock
                showAvailabilityResult()
            }
        }
    }
    
    /**
    Called from view model when a network operation fails
    */
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        self.isNetworkTaskProgressing = false
        showAvailabilityOff()
    }

}

extension ProductAvailabilityViewController: SizeSelectionDelegate {
 
    public func handleSizeSelection(for size: PoqProductSize) {
        
        sizeValueLabel?.text = size.size
        selectedSizeId = size.id
        
        // Track size selection
        PoqTrackerHelper.trackProductSelectSize(size.size!)
                
        checkAvailablity()
    }
}
