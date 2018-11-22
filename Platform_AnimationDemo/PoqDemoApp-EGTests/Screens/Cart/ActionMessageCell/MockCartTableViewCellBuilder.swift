//
//  MockCartCellBuilder.swift
//  PoqCart
//
//  Created by Balaji Reddy on 15/07/2018.
//

import UIKit

@testable import PoqCart

class MockCartTableViewCellBuilder: CartTableViewCellBuilder {
    
    public var isMessageCellActionable = false
    
    init(isMessageCellActionable: Bool) {
        self.isMessageCellActionable = isMessageCellActionable
        super.init()
    }
    
    override func cellClass(for contentItem: CartContentBlocks) -> UITableViewCell.Type? {
        
        switch contentItem {
        case .custom:
            return ActionableMessageTableViewCell.self
        default:
            return super.cellClass(for: contentItem)
        }
    }
    
    override func setup(cell: UITableViewCell, with content: CartContentBlocks, delegate: CartCellPresenter?) {
        
        switch content {
        
        case .custom(let payload):
            
            guard
                let actionMessageCell = cell as? ActionableMessageTableViewCell,
                let promotionalBanner = payload as? String,
                let actionMessagePresenter = delegate as? ActionableMessagePresenter else {
                    
                assertionFailure("Wrong cell provided for content type or Presenter not provided. Cannot setup cell.")
                return
            }
            
            actionMessageCell.setup(with: promotionalBanner, isActionable: isMessageCellActionable, presenter: actionMessagePresenter)
            
        default:
            super.setup(cell: cell, with: content, delegate: delegate)
        }
    }
}
