//
//  ProductDescriptionViewModel.swift
//  Poq.iOS
//
//  Created by Barrett Breshears on 1/29/15.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking

public protocol ProductDetailViewDelegate: AnyObject {
    
    /// Triggered when add to bag button clicked within the cell/from navbar.
    func addToBagButtonClicked()
    
    /// Triggered when user liked this product.
    func likeButtonClicked()
    
    /// Triggered when user taps to load fullscreen image.
    func imageViewClicked(_ index: Int, imageView: PoqAsyncImageView)
    
    /// Triggered when user taps more button in description.
    func descriptionClicked()
    
    /// Triggered when clicks on open reviews.
    func reviewsButtonClicked()
}

public protocol ProductColorsDelegate: AnyObject {
    // Triggered when a color swatch clicked within the cell.
    func colorSelected(_ selectedColor: String, productId: Int, externalId: String, selectedColorProductId: Int?)
}

open class ProductDetailViewModel: BaseViewModel {
   
    // ______________________________________________________
    
    // MARK: - Initializers
    /// The product who's detail is viewed.
    public final var product: PoqProduct?
    /// The id of the product currently viewed. TODO: Why we are using this here since we already have the product 
    public final var productId: Int?
    /// A stored message from the backend
    public final var message: PoqMessage
    
    public override init(viewControllerDelegate: PoqBaseViewController) {
        self.message = PoqMessage()
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network tasks
    
    /* Call in the first load of PLP. */
    open func getProduct(_ productId: Int, externalId: String?) {
        self.productId = productId
        
        PoqNetworkService(networkTaskDelegate: self).getProductDetails(User.getUserId(), productId: productId, externalId: externalId)
    }
    
    /// Adds the product to bag. TODO: BagHelper - this should be a static call
    open func addToBag() {

        guard let product = product, let selectedSizeId = product.selectedSizeID else {
            assertionFailure("No selectedSizeID or product to add to bag")
            return
        }
        
        BagHelper.addToBag(delegate: self, selectedSizeId: selectedSizeId, in: product)
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
    Callback before start of the async network task.
    */
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
            
            // Call super to show activity indicator
            super.networkTaskWillStart(networkTaskType)
            viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /**
    Callback after async network task is completed.
    */
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Call super to hide activity indicator
        // Send empty result list for avoind memory issues
        
        super.networkTaskDidComplete(networkTaskType, result: [])
        
        guard let existedResults = result else {
            return
        }

        if networkTaskType == PoqNetworkTaskType.productDetails {
            
            if let poqProduct: PoqProduct = existedResults.first as? PoqProduct {
                
                product = poqProduct

            } else {
                
                viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: nil )
            }
        } else if networkTaskType == PoqNetworkTaskType.postBag {

            if let existedMessage: PoqMessage = existedResults.first as? PoqMessage {
            
                message = existedMessage
                if BagHelper.isStatusCodeOK( message.statusCode ) {
                    BagHelper.incrementBagBy( 1 )
                }
            }
        }
        
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
    
    /**
    Callback when task fails due to lack of internet etc.
    */
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }

    /// Used to return a cell for the color swatch selection    
    ///
    /// - Parameters:
    ///   - tableView: The tableview of the color swatch.
    ///   - indexPath: The indexpath of the color swatch cell.
    ///   - delegate: The delegate that the color swatch actions responds to.
    /// - Returns: A UITableViewCell used for the color swatch cell view.
    open func getCellForColor(_ tableView: UITableView, indexPath: IndexPath, delegate: ProductColorsDelegate) -> UITableViewCell {
        
        let cell: ProductColorsViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        if let product = product {
            cell.setup(using: product)
        }
        
        cell.productDetailDelegate = delegate
        cell.accessibilityIdentifier = AccessibilityLabels.productColor
        return cell
    }
}
