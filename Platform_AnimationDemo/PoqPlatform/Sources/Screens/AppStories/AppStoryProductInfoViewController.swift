//
//  AppStoryProductInfoViewController.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 9/15/17.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

let AppStoryProductInfoViewAccessibilityIdentifier = "AppStoryProductInfoViewAccessibilityIdentifier" 
let AppStoryProductInfoCloseButtonAccessibilityIdentifier = "AppStoryProductInfoCloseButtonAccessibilityIdentifier"
let AppStoryProductInfoBackButtonAccessibilityIdentifier = "AppStoryProductInfoBackButtonAccessibilityIdentifier"

open class AppStoryProductInfoViewController: PoqBaseViewController, PoqPresenter, PoqProductBlockPresenter,
                                                      SheetContentViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
PoqProductSizeSelectionPresenter, SizeSelectionDelegate {
    
    public var animationParams: AddToBagAnimationParams?
    
    @IBOutlet open weak var collectionView: UICollectionView?
    @IBOutlet open weak var closeButton: UIButton?
    @IBOutlet open weak var backButton: UIButton?
    
    public static var pdpImageViewContentMode: UIViewContentMode = .scaleAspectFit
    
    public let viewModel: AppStoryCardProductInfoViewModel?
    open var product: PoqProduct?
    
    lazy open var service: AppStoryProductInfoService = {
        var res = AppStoryProductInfoService()
        res.presenter = self
        return res
    }()

    public init(with viewModel: AppStoryCardProductInfoViewModel) {
        
        self.viewModel = viewModel

        super.init(nibName: "AppStoryProductInfoView", bundle: nil)
        
        viewModel.presenter = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.fetchProductInfo()
        
        collectionView?.registerPoqCells(cellClasses: [PoqProductInfoContentBlockView.self])
        
        view.accessibilityIdentifier = AppStoryProductInfoViewAccessibilityIdentifier
        closeButton?.accessibilityIdentifier = AppStoryProductInfoCloseButtonAccessibilityIdentifier
        backButton?.accessibilityIdentifier = AppStoryProductInfoBackButtonAccessibilityIdentifier
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let index = navigationController?.viewControllers.index(where: { $0 == self }) ?? 0
        backButton?.isHidden = index == 0
    }
    
    // MARK: - Actions
    
    @IBAction func closeButtonAction() {
        containerViewController?.dismiss(animated: true)
    }
    
    @IBAction func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - PoqPresenter
    
    public func completed(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        if let product = viewModel?.product {
            self.product = product
        }
        collectionView?.reloadData()
    }
    
    // MARK: - SheetContentViewController
    
    public weak var containerViewController: SheetContainerViewController?
    
    public var action: SheetContainerViewController.ActionButton? {
        
        let action = SheetContainerViewController.ActionButton(text: AppLocalization.sharedInstance.appStoryInfoPdpGoToProductText) {
            [weak self] in
            
            var productId: Int?
            var externalProductId: String?
            
            if let productUnwrapped = self?.product {
                productId = productUnwrapped.id 
                externalProductId = productUnwrapped.externalID
            } else if let productIdsStruct = self?.viewModel?.productId {
                
                // Assume that VC was opened with only product in story card productIds array
                productId = productIdsStruct.internalProductId
                externalProductId = productIdsStruct.externalProductId
            }

            guard let productIdUnwrapped = productId else {
                Log.error("We are trying present product without id")
                return
            }
            
            UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: { 
                NavigationHelper.sharedInstance.loadProduct(productIdUnwrapped, externalId: externalProductId, source: ViewProductSource.appStories.rawValue, productTitle: self?.product?.title ?? "")
            })
        }
        
        return action
    }
    
    public func calculateSize(for maxSize: CGSize) -> CGSize {
        return CGSize(width: maxSize.width, height: 400)
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return product != nil ? 1 : 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: PoqProductInfoContentBlockView = collectionView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        if let productUnwrapped = product {
            let contentItem = PoqProductDetailContentItem(type: PoqProductDetailCellType.info(imageViewContentMode: AppStoryProductInfoViewController.pdpImageViewContentMode))
            cell.setup(using: contentItem, with: productUnwrapped)
        }
        
        cell.presenter = self
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 400)
    }
    
    // MARK: - PoqProductBlockPresenter
    
    public func likeDidTap() {
        guard let productTitle = product?.title, !productTitle.isEmpty else {
            
            Log.error("Product title is missing Couldn't track wishlist operation.")
            return
        }
        
        let valuePrice: Double = product?.trackingPrice ?? 0.0
        PoqTrackerHelper.trackAddToWishList(productTitle, value: valuePrice, extraParams: ["Screen": "AppStoryProductInfo"])
    }
    
    public func addToBagDidTap() {
        guard let productUnwrapped = product else {
            Log.error("Product data is not found. Can not add to bag")
            return
        }
        
        guard !productUnwrapped.isOutOfStock() else {
            
            BagHelper.showPopupMessage(AppLocalization.sharedInstance.bagOutOfStockMessage, isSuccess: false)
            return
        }
        
        guard productUnwrapped.isOneSize else {
            
            showSizeSelector(using: productUnwrapped)
            return
        }
        
        addToBag(product: productUnwrapped, size: productUnwrapped.productSizes?[0])
        Log.info("Add One Size product to bag directly")
    }
    
    // Lets put  empty implementations
    
    public func shareDidTap(sender: AnyObject?) {}
    public func imageDidTap(at index: IndexPath, forImageView imageView: PoqAsyncImageView) {}
    
    public func truncatedTextDidTap(with text: String) {}
    public func colorSelected(productColorId productId: Int, productColorExternalId: String) {}

    public func reloadView() {}
    
    // MARK: - PoqProductSizeSelectionPresenter
    
    public var sizeSelectionTransitioningDelegate: UIViewControllerTransitioningDelegate?
    public var sizeSelectionDelegate: SizeSelectionDelegate? {
        return self
    }
    
    // MARK: - SizeSelectionDelegate
    
    public func handleSizeSelection(for size: PoqProductSize) {
        Log.info("Add product to bag after size selection")
        addToBag(product: product, size: size)
    }
    
    // MARK: - Private
    
    fileprivate func addToBag(product: PoqProduct?, size: PoqProductSize?) {
        
        guard let productUnwrapped = product, let sizeUnwrapped = size else {
            Log.error("Product data is not found. Can not add to bag")
            return
        }

        service.addToBag(selectedSize: sizeUnwrapped.id, forProduct: productUnwrapped)
        BagHelper.logAddToBag(productUnwrapped.title, productSize: sizeUnwrapped)
    }
}
