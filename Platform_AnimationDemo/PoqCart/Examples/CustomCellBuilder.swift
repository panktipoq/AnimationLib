//
//  CustomCellBuilder.swift
//  PoqCart
//
//  Created by Balaji Reddy on 10/07/2018.
//

import UIKit

/**
 
 A CartTableViewCellBuilder subclass that adds support for KeyValueCardTableViewCell for custom payloads
 */
public class CustomTableViewCellBuilder: CartTableViewCellBuilder {
    
    override public func cellClass(for contentItem: CartContentBlocks) -> UITableViewCell.Type? {
        
        switch contentItem {
        case .custom:
            return KeyValueCardTableViewCell.self
        default:
            return super.cellClass(for: contentItem)
        }
    }
    
    override public func setup(cell: UITableViewCell, with content: CartContentBlocks, delegate: CartCellPresenter?) {
        
        switch content {
            
        case .custom(let payload):
            
            guard let keyValueTableCell = cell as? KeyValueCardTableViewCell else {
                
                assertionFailure("Wrong cell for content block. Cannot set cell up.")
                return
            }
            
            guard let keyValueCard = payload.base as? KeyValueCardTableViewCell.KeyValueCard else {
                
                assertionFailure("Unexpected payload type received. Cannot set cell up.")
                return
            }
            
            guard let keyValueCardPresenter = delegate as? KeyValueCardCellPresenter else {
                
                assertionFailure("Wrong presenter type received. Cannot set cel up.")
                return
            }
            
            keyValueTableCell.isEditable = true
            
            keyValueTableCell.setup(with: keyValueCard, delegate: keyValueCardPresenter)
            
        default:
            super.setup(cell: cell, with: content, delegate: delegate)
        }
    }
}
