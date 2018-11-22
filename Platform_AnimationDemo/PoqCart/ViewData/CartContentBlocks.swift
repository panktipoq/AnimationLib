//
//  CartContentBlocks.swift
//  PoqCart
//
//  Created by Balaji Reddy on 21/06/2018.
//

import Foundation

/**
 
  A block of content displayed by the Cart screen.
 
  The Cart screen presents a scrollable view containing content views that display different chunks/content-blocks of information. Each type of content-block is associated with
  a different custom view that presents it.

  This enum type represents the different types of content-blocks and the associated content for those types.
 
 */
public enum CartContentBlocks {
    
    /// A content-block type representing a Cart item.
    case cartItemCard(cartItem: CartItemViewDataRepresentable)
    
    /// A content-block type used to present views with tappable links that navigate to either another screen in the app or an external URL
    case link(linkTitle: String, linkUrl: String)
    
    /// A custom content-block type with a content payload wrapped in AnyHashable that can be interpreted by client apps as they see fit
    case custom(payload: AnyHashable)
}

extension CartContentBlocks: Equatable {
    
    public static func == (lhs: CartContentBlocks, rhs: CartContentBlocks) -> Bool {
        
        switch lhs {
            
        case .cartItemCard(let cartItem):
            
            if case .cartItemCard(let rhsCartItem) = rhs {
                
                // The id, quantity, subTotal and isInStock are the only ones that change
                // Ideally the cartItem should be Equatable.
                // To make the cartItem Equatable, we need to make CartContentBlocks generic
                // This would introduce a fair amount of complexity
                // TODO: See if we can ensure that cartItem type conforms to Equatable
                if cartItem.id != rhsCartItem.id {
                    return false
                } else if cartItem.quantity != rhsCartItem.quantity {
                    return false
                } else if cartItem.total != rhsCartItem.total {
                    return false
                } else if cartItem.isInStock != rhsCartItem.isInStock {
                    return false
                }
                
                return true
            }
            
            return false
            
        case .link(let linkTitle, let linkUrl):
            
            if case .link(let rhsLinkTitle, let rhsLinkUrl) = rhs {
                return (linkTitle == rhsLinkTitle) && (linkUrl == rhsLinkUrl)
            }
            
            return false
            
        case .custom(let lhsPayload):
            
            if case .custom(let rhsPayLoad) = rhs {
                
                return rhsPayLoad == lhsPayload
            }
            
            return false
        }
    }
}
