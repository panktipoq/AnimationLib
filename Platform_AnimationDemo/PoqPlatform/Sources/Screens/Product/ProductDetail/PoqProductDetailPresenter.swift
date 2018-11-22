//
//  PoqProductDetailPresentable.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Mahmut Canga on 21/12/2016.
//
//

import PoqModuling
import PoqNetworking
import PoqUtilities
import UIKit

public struct AddToBagAnimationParams {
    
    var productImage: UIImage
    var productImageFrame: CGRect
}

public protocol PoqProductBlockPresenter: AnyObject {
    
    // User interactions
    func addToBagDidTap()
    func likeDidTap()
    func shareDidTap(sender: AnyObject?)
    func imageDidTap(at index: IndexPath, forImageView imageView: PoqAsyncImageView)
    
    func truncatedTextDidTap(with text: String)
    func showSizeSelector(using product: PoqProduct)
    func colorSelected(productColorId productId: Int, productColorExternalId: String)
    
    // Update UI, reload collection or table view
    func reloadView()
    
    var animationParams: AddToBagAnimationParams? { get set }
}

public protocol PoqProductDetailPresenter: PoqPresenter, PoqProductBlockPresenter {
    
    // ______________________________________________________
    
    // MARK: - Properties
    var trackingSource: PoqTrackingSource? { get set }
    var selectedProductId: Int? { get set }
    var selectedProductExternalId: String? { get set }
    var service: PoqProductDetailService { get }
    
    // ______________________________________________________
    
    // MARK: - Methods
    
    // NavigationBar setup
    func setupNavigationBar()
    func setNavigationBarBackgroundHidden(_ isHidden: Bool)
    func setNavigationBarToTransparent()
    func setNavigationBarVisible()

    func setNavigationBarItems(_ enabled: Bool)
    func setupRightBarButton()
    
    // CollectionView setup
    func setCellRegistration()
    func setRefreshControl()
    func setCollectionViewLayout()
    
    /// Open web view with 'pageHTML' in it
    func presentDescription(_ title: String, pageHTML: String)
    
    //Start Add to bag Animation
    func startAddToBagAnimation(using param: AddToBagAnimationParams)
}

// Default platform functionality

extension PoqProductDetailPresenter {
    
    public func addToBagDidTap() {
        
        guard let validatedProduct = service.product else {
            
            Log.error("Product data is not found. Can not add to bag")
            return
        }
        
        guard service.isInStock(product: validatedProduct) else {
            
            BagHelper.showPopupMessage(AppLocalization.sharedInstance.bagOutOfStockMessage, isSuccess: false)
            return
        }
        
        guard validatedProduct.isOneSize else {
            
            showSizeSelector(using: validatedProduct)
            return
        }
        
        Log.info("Add One Size product to bag directly")
        
        if let productSize = validatedProduct.productSizes?[0] {
            service.addToBag(selectedSize: productSize.id, forProductId: validatedProduct.id)
            BagHelper.logAddToBag(validatedProduct.title, productSize: productSize)
        }
    }
    
    public func likeDidTap() {
        
        guard let productTitle = service.product?.title, !productTitle.isEmpty else {
            
            Log.error("Product title is missing Couldn't track wishlist operation.")
            return
        }
        
        let valuePrice: Double = service.product?.trackingPrice ?? 0.0
        PoqTrackerHelper.trackAddToWishList(productTitle, value: valuePrice, extraParams: ["Screen": "PDP"])
    }
}

// Group shared implementations for all pdp view types into this extension

extension PoqProductDetailPresenter where Self: PoqBaseViewController {
    
    public func setupNavigationBar() {
        
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        
        if AppSettings.sharedInstance.pdpNavigationBarHidden {
            navigationItem.titleView = nil
        }
        
        // Disable while product data is loaded
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    public func setNavigationBarBackgroundHidden(_ isHidden: Bool) {
        
        isHidden ? setNavigationBarToTransparent() : setNavigationBarVisible()
    }
    
    public func setNavigationBarToTransparent() {
        
        // We make sure the navigation Bar is translucent and status bar dark.
        // We do not need to set navigationBar.barTintColor because will be transparent.
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.statusBarStyle(PoqStatusBarStyle.dark)
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.setBackgroundImage(toColor: .clear)
        navigationController?.navigationBar.setShadowImage(toColor: .clear)
    }
    
    public func setNavigationBarVisible() {
        
        navigationController?.navigationBar.resetImages()
    }
    
    public func setNavigationBarItems(_ enabled: Bool) {
        
        navigationItem.leftBarButtonItem?.isEnabled = enabled
        navigationItem.rightBarButtonItem?.isEnabled = !enabled
    }
    
    public func truncatedTextDidTap(with text: String) {
        
        // TODO: product description view
        Log.verbose("Truncated text will be revealed with text:\n\(text)")
    }
    
    public func colorSelected(productColorId productId: Int, productColorExternalId: String) {
        // First, persist the new selected productId and externalId
        selectedProductId = productId
        selectedProductExternalId = productColorExternalId
        // Second, get the details of the new selected product
        service.getProductDetails(byProductId: productId, externalId: productColorExternalId)
    }
    
    public func presentDescription(_ title: String, pageHTML: String) {
        
        let productDetailOthers = ProductDetailOthersViewController(nibName: "ProductDetailOthersViewController", bundle: nil)
        productDetailOthers.webViewTitle = title
        productDetailOthers.pageHTML = pageHTML
        productDetailOthers.bodyClassName = "productDescription"
        
        if let navigationController = navigationController {
            navigationController.pushViewController(productDetailOthers, animated: true)
        } else {
            let navigationController = PoqNavigationViewController(rootViewController: productDetailOthers)
            present(navigationController, animated: true, completion: nil)
        }
    }
}
