//
//  PoqOrderItemExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 09/03/2016.
//
//

import Foundation
import PoqNetworking

extension PoqOrderItem: BagItemConvertable {
    
    public init(bagItem: PoqBagItem) {
        self.init()
        
        productID = bagItem.productId
        externalID = bagItem.product?.externalID
        size = bagItem.product?.selectedSizeName
        quantity = bagItem.quantity
        productTitle = bagItem.product?.title
        price = PoqOrderItem.getOrderPriceFromProduct(bagItem.product)
        productSizeID = bagItem.productSizeId
        sku = PoqOrderItem.getSKUFromProductByProductSizeId(bagItem.productSizeId, product: bagItem.product)

        productImageUrl = bagItem.product?.pictureURL
    }
    
    
    static func getSKUFromProductByProductSizeId(_ productSizeId:Int?, product:PoqProduct?) -> String? {
        
        // Find sku in productSize
        for productSize in product!.productSizes! {
            
            if productSize.id! == productSizeId {
                
                return productSize.sku
            }
        }
        
        return nil
    }
    
    
    static func getOrderPriceFromProduct(_ product: PoqProduct?) -> Double? {
        
        if let specialPrice = product?.specialPrice {
            return specialPrice
        }

        return product?.price
    }
}
