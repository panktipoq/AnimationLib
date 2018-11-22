//
//  DomainModelMapper.swift
//  PoqCart
//
//  Created by Balaji Reddy on 02/10/2018.
//

import Foundation

/// This interface represents a type that defines methods that can map a generic network model type to a CartDomainModel
public protocol CartDomainModelMappable {
    
    associatedtype NetworkModelType
    func map(from networkModel: NetworkModelType) -> CartDomainModel
}

/*  This class is the platform implementation of the CartDomainModelMappable interface
 
    It maps a Cart object to the CartDomainModel object
 */
public class CartDomainModelMapper: CartDomainModelMappable {
    
    public func map(from networkModel: Cart) -> CartDomainModel {
        
        let cartItems = networkModel.cartItems.map { networkCartItem in
            
            return CartItemDomainModel(id: networkCartItem.id,
                                               brand: networkCartItem.brand,
                                               productTitle: networkCartItem.title,
                                               priceFormatted: networkCartItem.price.nowFormatted,
                                               price: networkCartItem.price.now,
                                               wasPriceFormatted: networkCartItem.price.wasFormatted,
                                               wasPrice: networkCartItem.price.was,
                                               productId: networkCartItem.platformProductId,
                                               externalProductId: networkCartItem.clientProductId,
                                               thumbnailUrl: networkCartItem.thumbnailUrl,
                                               color: networkCartItem.color,
                                               size: networkCartItem.variantName,
                                               sku: networkCartItem.variantId,
                                               quantity: networkCartItem.quantity,
                                               totalPriceFormatted: networkCartItem.total.nowFormatted,
                                               totalPrice: networkCartItem.total.now,
                                               isInStock: networkCartItem.isInStock,
                                               customData: networkCartItem.customData)
        }
        
        let cartDomainModel = CartDomainModel(cartId: networkModel.cartId, cartItems: cartItems, totalPriceFormatted: networkModel.total.nowFormatted, totalPrice: networkModel.total.now, customData: networkModel.customData)
        
        return cartDomainModel
    }
    
}
