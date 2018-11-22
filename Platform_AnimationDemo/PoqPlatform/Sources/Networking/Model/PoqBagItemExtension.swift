//
//  PoqBagItemExtension.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Andrei Mirzac on 21/03/2017.
//
//

import Foundation
import ObjectMapper
import PoqNetworking

extension PoqBagItem {
    
    public func constructPoqBagItemPost() -> PoqBagItemPostBodyItem {
        
        let bagItemPostBodyItem = PoqBagItemPostBodyItem()
        bagItemPostBodyItem.id = id
        bagItemPostBodyItem.productSizeID = productSizeId
        bagItemPostBodyItem.quantity = quantity
        bagItemPostBodyItem.cartId = cartId
        
        let selectedProductSize = ProductSizeHelper().findSelectedSize(withId: productSizeId, inProduct: product)
        
        bagItemPostBodyItem.sizeOptionId = selectedProductSize?.sizeAttributes?.optionId ?? ""
        bagItemPostBodyItem.sizeAttributeId = selectedProductSize?.sizeAttributes?.attributeId ?? ""
        bagItemPostBodyItem.sku = selectedProductSize?.sku
        
        return bagItemPostBodyItem
    }
}
