//
//  AddtoBagHelper.swift
//  Poq.iOS
//
//  Created by Jun Seki on 18/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import PoqModuling
import PoqNetworking
import PoqAnalytics
import UIKit

open class BagHelper: NSObject {
    
    // Decides whether we use the old BagItems POST endpoint or the new cart/items POST endpoint.
    public static var usesCartApi = false
    
    open class func resetBag() {
        let tabIndex = Int(AppSettings.sharedInstance.shoppingBagTabIndex)
        BadgeHelper.setBadge(for: tabIndex, value: 0)
    }
    
    open class func incrementBagBy( _ qty: Int ) {
        let tabIndex = Int(AppSettings.sharedInstance.shoppingBagTabIndex)
        BadgeHelper.increaseBadgeValue(tabIndex, increaseValue: qty)
    }
    
    open class func addToBag(delegate: PoqNetworkTaskDelegate, selectedSizeId: Int, in product: PoqProduct) {
        
        let postBodyItem = PoqBagItemPostBodyItem()
        // We don't have quantity selector. Always add one item at a time
        postBodyItem.quantity = 1
        postBodyItem.productSizeID = selectedSizeId
        let selectedSize = product.productSizes?.first(where: { $0.id == selectedSizeId })
        postBodyItem.sizeAttributeId = selectedSize?.sizeAttributes?.attributeId ?? ""
        postBodyItem.sizeOptionId = selectedSize?.sizeAttributes?.optionId ?? ""
        postBodyItem.sku = selectedSize?.sku
        
        let postBody = PoqBagItemPostBody()
        postBody.items = [postBodyItem]
        
        if usesCartApi {
        
            if let sku = selectedSize?.sku, let productId = product.externalID {
                
                let addToCartPostBody = AddToCartBody(variantId: sku, variantName: selectedSize?.size ?? "", productId: productId, quantity: 1)
                PoqNetworkService(networkTaskDelegate: delegate).addToCart(cartItemPostBody: addToCartPostBody)
            }
            
        } else {
        
            PoqNetworkService(networkTaskDelegate: delegate).postUsersBagItems(User.getUserId(), postBody: postBody)
        }
        
        PoqTrackerHelper.trackAddToBag(["productId":"\(product.id ?? 0)"])
    }

    open class func showPopupMessage(_ message: String, isSuccess: Bool, displayInterval: Int = 1) {
 
        // Success or Failure
        if isSuccess {
            // TODO: Bad naming for the images. Should be good to move this into Client Style.
            PopupMessageHelper.showMessage("icn-done", message: message)
        } else {
            PopupMessageHelper.showMessage("icn-info", message: message)
        }
    }
    
    // This is platform implementation of the completed add to bag
    open class func completedAddToBag() {

        // A hack just for wishlist
        showPopupMessage(AppLocalization.sharedInstance.addToBagConfirmationButtonText, isSuccess: true)

        if AppSettings.sharedInstance.pushRegistrationType == PushRegistrationType.afterLikeOrAddToBag.rawValue {
            PoqUserNotificationCenter.shared.setupRemoteNotifications()
        }
    }
    
    /**
    Logs user's add to bag action
    
    - parameter productSize: Selected product size added to bag
    */
    open class func logAddToBag(_ productName: String?, productSize: PoqProductSize, trackingSource: PoqTrackingSource? = nil) {
        
        // Set product size attributes
        var extraParams = [String: String]()
        
        if let title = productName, title != ""{
            extraParams["Title"] = title
        }
        
        // Add Size Name
        if let sizeName = productSize.size {
            
            extraParams["SizeName"] = sizeName
        }
        
        // Add SKU
        if let sku = productSize.sku {
            
            extraParams["SKU"] = sku
        }
        
        // Add EAN
        if let ean = productSize.ean {
            
            extraParams["EAN"] = ean
        }
        
        // Add specialPrice
        if let specialPrice = productSize.specialPrice {
            extraParams["Price"] = specialPrice.toPriceString()
        } else if let price = productSize.price {
            extraParams["Price"] = price.toPriceString()
        }
        
        if let id = productSize.id {
            extraParams["Id"] = String(id)
        }
        
        // Due to not having quantity selector, default is 1
        extraParams["Qty"] = "1"
        extraParams["Screen"] = "ProductDetail"
        
        if let validTrackingSource = trackingSource {
            extraParams.update(validTrackingSource.sourceDictionary)
        }
        
        // Get size id
        if let productSizeID = productSize.id {
            let selectedSize = String(productSizeID)
        
            // Track add to bag
            PoqTrackerHelper.trackSelectSize(selectedSize, extraParams: extraParams)
        }
        
        PoqTrackerV2.shared.addToBag(quantity: 1, productId: productSize.id ?? 0, productTitle: productName ?? "", productPrice: productSize.specialPrice ?? productSize.price ?? 0, currency: CurrencyProvider.shared.currency.code)
    }
    
    // Save Poq Order ID to be used in Native Checkout
    open func saveOrderId(_ orderId: Int?) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(orderId, forKey: "orderId")
        userDefaults.synchronize()
    }
    
    // Get Poq Order ID to be used in Native Checkout
    open func getOrderId() -> Int? {
        
        let userDefaults = UserDefaults.standard
        
        guard let orderId = userDefaults.value(forKey: "orderId") as? Int else {
            
            return nil
        }
        
        return orderId
    }
    
    open class func isStatusCodeOK(_ statusCode: Int?) -> Bool {
        
        if let code: Int = statusCode, code != HTTPResponseCode.OK {
            
            return false
        } else {
            
            return true
        }
    }
}
