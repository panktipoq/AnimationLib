//
//  CartTableCellBuilder.swift
//  PoqCart
//
//  Created by Balaji Reddy on 24/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import UIKit
import PoqUtilities

/**
 
 This protocol represents a type that sets up the relevant Cart Table cells based on the content item type
 */
public protocol CartTableViewCellBuildable {
    
    func cellClass(for contentItem: CartContentBlocks) -> UITableViewCell.Type?
    func setup(cell: UITableViewCell, with content: CartContentBlocks, delegate: CartCellPresenter?)
}

/**
    This is the default platform implementation of the CartTableCellBuildable protocol
 */
public class CartTableViewCellBuilder: CartTableViewCellBuildable {
    
        public init() {}
    
        /// This method returns the cell class type for a specific content item
        ///
        /// - Parameter contentItem: The content item
        /// - Returns: The cell type that can present the content item
        open func cellClass(for contentItem: CartContentBlocks) -> UITableViewCell.Type? {
            
            switch contentItem {
                
            case CartContentBlocks.cartItemCard:
                
                return CartItemTableViewCell.self
                
            default:
                return nil
            }
        }
    
        /// This method sets up the appropriate cell with content and the delegate provided
        ///
        /// - Parameters:
        ///   - cell: The instance of the cell that needs to be setup
        ///   - content: The content to set the cell up with
        ///   - delegate: The presenter delegate for the cell
        open func setup(cell: UITableViewCell, with content: CartContentBlocks, delegate: CartCellPresenter?) {
            
            switch content {
                
            case CartContentBlocks.cartItemCard(let cartItem):
                
                guard let cartItemCardCell = cell as? CartItemTableViewCell else {
                    Log.error("Cell type and content item type do not match. Cannot setup cell")
                    return
                }
                
                cartItemCardCell.setup(with: cartItem, delegate: delegate)
                
            default:
                return
            }
        }
}
