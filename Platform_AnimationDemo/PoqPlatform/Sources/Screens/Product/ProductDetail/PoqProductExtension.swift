//
//  PoqProductExtension.swift
//  Poq.iOS.Platform
//
//  Created by Nikolay Dzhulay on 6/23/17.
//
//

import Foundation
import PoqNetworking

extension PoqProduct {
    
    public var hasMultipleSizes: Bool {
        let nonNilSizes = productSizes?.filter({ return $0.size != nil })
        guard let sizes = nonNilSizes, sizes.count > 0 else {
            return false
        }
        
        // it might be one size, but with specific names, saying, that only one size exists
        if isOneSize {
            return false
        }
        
        return true
    }
    
    public var isOneSize: Bool {
        guard let productSizes = productSizes, let firstProductSize = productSizes.first?.size else {
            return false
        }
        
        if productSizes.count == 1 && (firstProductSize.isEmpty || firstProductSize.lowercased().contains(AppLocalization.sharedInstance.pdpSizesOneSizeText)) {
            return true
        }
        
        return false
    }
    
    var isGroupedProduct: Bool {
        if let relatedProductIds = relatedProductIDs, relatedProductIds.count > 0 {
            return true
        }
        return false
    }
    
    // MARK: Color support
    open func getColourProduct(_ selectedColorProductId: Int) -> PoqProduct {
        
        // Create a PoqProduct with the productID and externalID of the selected color product but the title, price and specialPrice of the base product.
        // This is because we currently do not receive the title, price and specialPrice information in the PoqProductColors object and they are used for tracking when we add to wishlist
        let productColorProduct = PoqProduct()
        productColorProduct.id = selectedColorProductId
        productColorProduct.externalID = getProductColor(forProduct: self, productColorProductId: selectedColorProductId)?.externalID
        productColorProduct.price = price
        productColorProduct.specialPrice = specialPrice
        productColorProduct.title = title
        
        return productColorProduct
    }
    
    func getProductColor(forProduct product: PoqProduct?, productColorProductId: Int) -> PoqProductColor? {
        if let productColorIndex = product?.productColors?.index(where: { $0.productID == productColorProductId }) {
            return product?.productColors?[productColorIndex]
        }
        return nil
    }
    
    var trackingPrice: Double {
    
        var trackingPrice: Double = 0.0
        
        if let specialPrice = specialPrice {
            trackingPrice = specialPrice
        } else if let price = price {
            trackingPrice = price
        }
        
        return trackingPrice
    }
}
