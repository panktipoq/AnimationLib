//
//  CartDataMapper.swift
//  PoqCart
//
//  Created by Balaji Reddy on 08/08/2018.
//

import Foundation

/// This method maps the Cart data fetched from the network to a view data representation of it
///
/// - Parameter model: The Cart response from the network
/// - Returns: A mapped view data reprsentation of the Cart network data
struct CartViewDataMapper: CartViewDataMappable {
    func mapToViewData(_ model: CartDomainModel) -> CartViewDataRepresentable {
        
        var contentBlocks = [CartContentBlocks]()
        var numberOfCartItems = 0
        
        model.cartItems.forEach { cartItem in
            
            var cartItemViewData = CartItemViewData(id: cartItem.id, productTitle: cartItem.productTitle, quantity: cartItem.quantity, nowPrice: cartItem.priceFormatted, total: cartItem.totalPriceFormatted, isInStock: cartItem.isInStock)
            cartItemViewData.wasPrice = cartItem.wasPriceFormatted
            cartItemViewData.productImageUrl = cartItem.thumbnailUrl
            cartItemViewData.brandName = cartItem.brand
            cartItemViewData.size = cartItem.size
            cartItemViewData.color = cartItem.color
          
            let cartItemContentBlock = CartContentBlocks.cartItemCard(cartItem: cartItemViewData)
            contentBlocks.append(cartItemContentBlock)
            
            numberOfCartItems += cartItem.quantity
        }

        return CartViewData(contentBlocks: contentBlocks, numberOfCartItems: numberOfCartItems, total: model.totalPriceFormatted)
    }
}
