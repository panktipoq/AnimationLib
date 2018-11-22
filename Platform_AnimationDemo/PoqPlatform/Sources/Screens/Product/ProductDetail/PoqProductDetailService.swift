//
//  PoqProductDetailService.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Mahmut Canga on 21/12/2016.
//
//

import Foundation
import PoqNetworking
import PoqUtilities

public protocol PoqProductDetailService: PoqNetworkTaskDelegate {
    
    // ______________________________________________________
    
    // MARK: - Properties
    
    // Stored data in view model
    var presenter: PoqProductDetailPresenter? { get set }
    var product: PoqProduct? { get set }
    var content: [PoqProductDetailContentItem] { get set }
    
    // ______________________________________________________
    
    // MARK: - Methods
    
    // Network operation responses
    func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?)
    func parseProductDetails(_ result: [PoqProduct]?)
    
    func parseAddToCartResponse()
    func parseAddToBagResponse(_ result: [PoqMessage]?)
    
    // Error messages
    func showProductNotFound()
    func showAddToBagError(with message: PoqMessage?)
    
    // Network operations requests
    func addToBag(selectedSize productSizeId: Int?, forProductId productId: Int?)
    func getProductDetails(byProductId productId: Int?, externalId: String?)
    
    // PDP Business Logic
    func isInStock(product: PoqProduct) -> Bool
    func hasMultipleColours(product: PoqProduct) -> Bool
    func generateContent()
}

extension PoqProductDetailService {
    
    // ______________________________________________________
    
    // MARK: - Network Tasks
    
    public func getProductDetails(byProductId productId: Int?, externalId: String?) {

        guard let productIdValidated = productId, let externalIdValidated = externalId else {

            return
        }

        PoqNetworkService(networkTaskDelegate: self).getProductDetails(User.getUserId(), productId: productIdValidated, externalId: externalIdValidated)
    }
    
    public func addToBag(selectedSize productSizeId: Int?, forProductId productId: Int?) {
        
        guard let selectedSizeId = productSizeId, let product = product else {
            assertionFailure("Cannot add to bag without a valid productSizeID and Product")
            return
        }
        
        BagHelper.addToBag(delegate: self, selectedSizeId: selectedSizeId, in: product)
        
        PoqTrackerHelper.trackAddToBag(["productId": "\(productId ?? 0)"])
    }
    
    public func generateContent() {
        
        content = []
        
        let productInfoContentItem = PoqProductDetailContentItem(type: PoqProductDetailCellType.info(imageViewContentMode: ImageHelper.returnImageScalingMode(fromString: AppSettings.sharedInstance.pdpProductImageContentMode)))
        
        content.append(productInfoContentItem)
        
        if product?.promotion?.isNullOrEmpty() == false {
            let promotionContentItem = PoqProductDetailContentItem(type: PoqProductDetailCellType.promotion)
            content.append(promotionContentItem)
        }
        
        if let productValidated = product, hasMultipleColours(product: productValidated) {
            let productColourSwatchesContentItem = PoqProductDetailContentItem(type: PoqProductDetailCellType.colors)
            content.append(productColourSwatchesContentItem)
        }
        
        let productDescriptionContentItem = PoqProductDetailContentItem(type: PoqProductDetailCellType.htmlDescription(htmlBody: product?.body ?? ""),
                                                                        title: AppLocalization.sharedInstance.pdpProductDescriptionHeadline, 
                                                                        description: product?.description)
        content.append(productDescriptionContentItem)
        
        if let shouldShowSizes = product?.hasMultipleSizes, shouldShowSizes, AppSettings.sharedInstance.isSizeInformationRowShown {
            let sizesItem = PoqProductDetailContentItem(type: PoqProductDetailCellType.sizes)
            content.append(sizesItem)
        }
        
        // Product size guide link at the end of page (cloud configurable)
        if AppSettings.sharedInstance.isSizeGuideOnPDPEnabled {
            let title = AppLocalization.sharedInstance.sizeGuidePageOnPDPTitle
            
            let link: String? = {
                if let productSizeGuide = product?.sizeGuide, !productSizeGuide.isEmpty {
                    return productSizeGuide
                } else if let sizeGuideOnPDPPageId = AppSettings.sharedInstance.sizeGuideOnPDPPageId.toInt() {
                    return NavigationHelper.sharedInstance.pageDetailLink(pageId: String(sizeGuideOnPDPPageId), title: title)
                } else {
                    return nil
                }
            }()
            
            if let link = link {
                let contentItem = PoqProductDetailContentItem(type: PoqProductDetailCellType.link(link: link), title: title)
                content.append(contentItem)
            }
        }
        
        // Delivery link at the end of page (cloud configurable)
        if AppSettings.sharedInstance.isDeliveryPageOnPDPEnabled && !AppSettings.sharedInstance.deliveryPageOnPDPPageId.isEmpty,
            let deliveryPageIdInt = AppSettings.sharedInstance.deliveryPageOnPDPPageId.toInt() {
            
            let title = AppLocalization.sharedInstance.deliveryPageOnPDPTitle
            let link = NavigationHelper.sharedInstance.pageDetailLink(pageId: String(deliveryPageIdInt), title: title)
            let contentItem = PoqProductDetailContentItem(type: PoqProductDetailCellType.link(link: link), title: title)
            content.append(contentItem)
        }
        
        if let productId = product?.id, AppSettings.sharedInstance.isProductsCarouselOnPdpEnabled {
            let service = PoqProductsCarouselViewModel(viewedProduct: productId)
            let recentViewedContentItem = PoqProductDetailContentItem(type: RecentlyViewedCellTypeProvider(service: service))
            content.append(recentViewedContentItem)
        }
        
        if AppSettings.sharedInstance.isShareButtonAddedAsLastBlockOnPdp {
            content.append(PoqProductDetailContentItem(type: PoqProductDetailCellType.share))
        }
    }
    
    // ______________________________________________________
    
    // MARK: - Network Response Parser
    
    public func parseResponse(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.productDetails:
            parseProductDetails(result as? [PoqProduct])
            
        case PoqNetworkTaskType.postBag, PoqNetworkTaskType.postCartItems:
            
            if BagHelper.usesCartApi {
                
                parseAddToCartResponse()
            } else {
                
                parseAddToBagResponse(result as? [PoqMessage])
            }
            
        default:
            Log.error("Network task is not implemented:\(networkTaskType)")
        }
    }
    
    public func parseProductDetails(_ result: [PoqProduct]?) {
        
        guard let productDetailsResults = result, productDetailsResults.count == 1 else {
            
            showProductNotFound()
            return
        }
        
        guard let productId = productDetailsResults[0].id, productId > 0 else {
            
            showProductNotFound()
            return
        }
        
        product = productDetailsResults[0]
        
        generateContent()
        
        presenter?.update(state: .completed, networkTaskType: PoqNetworkTaskType.productDetails)
    }
    
    public func parseAddToCartResponse() {
        
        BagHelper.incrementBagBy(1)
        
        presenter?.update(state: .completed, networkTaskType: PoqNetworkTaskType.postCartItems)
    }
    
    public func parseAddToBagResponse(_ result: [PoqMessage]?) {
        
        guard let message = result?[0], BagHelper.isStatusCodeOK(message.statusCode) else {
            
            showAddToBagError(with: result?[0])
            return
        }
        
        presenter?.update(state: .completed, networkTaskType: PoqNetworkTaskType.postBag)
    }
    
    public func showAddToBagError(with message: PoqMessage?) {
        
        guard let errorMessage = message?.message else {
            
            Log.error("Server returned an error without message after add to bag")
            
            let error = NSError(domain: "Add to Bag", code: HTTPResponseCode.SERVER_ERROR, userInfo: [NSLocalizedDescriptionKey: "ERROR_ADDED_TO_BAG".localizedPoqString])
            
            presenter?.error(error)
            return
        }
        
        let error = NSError(domain: "Add to Bag", code: HTTPResponseCode.SERVER_ERROR, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        
        presenter?.error(error)
    }
    
    public func showProductNotFound() {
        
        let error = NSError(domain: "Not Found", code: HTTPResponseCode.NOT_FOUND, userInfo: [NSLocalizedDescriptionKey: "PRODUCT_NOT_FOUND".localizedPoqString])
        presenter?.update(state: .error, networkTaskType: PoqNetworkTaskType.productDetails, withNetworkError: error)
    }
    
    // ______________________________________________________
    
    // MARK: - PDP Business Logic
    
    public func isInStock(product: PoqProduct) -> Bool {
        
        guard product.isOutOfStock() else {
            
            // Product is in stock
            // It is best to continue with size selection
            return true
        }
        
        // Product is out of stock
        // Product is NOT in stock
        return false
    }
    
    // TODO: this method is super important to circle the selected color. However it is only called when content is created.
    // We need to move the call of the method to other places.
    // Else product.selectedColorProductID is not set.
    public func hasMultipleColours(product: PoqProduct) -> Bool {
        if let productColours = product.productColors,
        let productID = product.id,
            productColours.count > 1 {
            // Make sure that the productID from the main product is in one of the colours
            if let index = productColours.index(where: { $0.productID == productID }) {
                product.selectedColorProductID = productColours[index].productID
            }
            return true
        }
        return false
    }

    // ______________________________________________________

    // MARK: - Network Task Callbacks

    /**
     Callback before start of the async network task
     */
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {

        presenter?.update(state: .loading, networkTaskType: networkTaskType)
    }

    /**
     Callback after async network task is completed successfully
     */
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        parseResponse(networkTaskType, result: result)
    }

    /**
     Callback when task fails due to lack of responded data, connectivity etc.
     */
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {

        presenter?.update(state: .error, networkTaskType: networkTaskType, withNetworkError: error)
    }
}
