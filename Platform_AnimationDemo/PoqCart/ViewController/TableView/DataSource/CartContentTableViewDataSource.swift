//
//  CartContentTableViewDataSource.swift
//  PoqCart
//
//  Created by Balaji Reddy on 24/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import UIKit
import PoqUtilities

/**
    This protocol represents a type that acts as the source of and manages the data for the Cart View content table
 */
public protocol CartContentTableDataProvidable: UITableViewDataSource {
    
    var content: [CartContentBlocks]? { get set }
    var cellBuilder: CartTableViewCellBuildable { get set }
    var delegate: CartCellPresenter? { get set }
    func cartItem(at indexPath: IndexPath) -> CartItemViewDataRepresentable?
    func registerCells(with tableView: UITableView)
    func deleteRow(in tableView: UITableView, at indexPath: IndexPath)
    func wishlistItem(at indexPath: IndexPath)
}

/**
    This is the default platform implementation of the CartContentTableDataProvidable protocol
 */
public class CartContentTableViewDataSource: NSObject, CartContentTableDataProvidable {

    public var cellBuilder: CartTableViewCellBuildable
    public var content: [CartContentBlocks]?
    public weak var delegate: CartCellPresenter?
    
    public required init(cellBuilder: CartTableViewCellBuildable = CartTableViewCellBuilder(), delegate: CartCellPresenter? = nil) {
        
        self.cellBuilder = cellBuilder
        self.delegate = delegate
        super.init()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let contentItem = content?[indexPath.row] else {
            
            assertionFailure("No content for index path. Cannot return cell")
            return UITableViewCell()
        }
        
        guard let cellType = cellBuilder.cellClass(for: contentItem) else {
            
            assertionFailure("CellBuilder did not provide a cell type for content item at indexPath")
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.description(), for: indexPath)
        
        cell.selectionStyle = .none
        
        cellBuilder.setup(cell: cell, with: contentItem, delegate: delegate)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
    
            deleteRow(in: tableView, at: indexPath)
            
        default:
            return
        }
    }
    
    /// This method registers all the cell types required to present the content
    ///
    /// - Parameter tableView: The table view with which the cells need to be registered
    public func registerCells(with tableView: UITableView) {
        
        var cellIdentifiers = Set<String>()
        
        content?.forEach {
            if let cellClass = cellBuilder.cellClass(for: $0),
                !cellIdentifiers.contains(cellClass.description()) {
                
                    tableView.register(cellClass, forCellReuseIdentifier: cellClass.description())
                    cellIdentifiers.insert(cellClass.description())
                }
            }
    }
    
    /// This method returns a CartItemViewDataRepresentable instance if one is present at the given IndexPath
    ///
    /// - Parameter indexPath: The IndexPath at which to look a for a cart item
    /// - Returns: The CartItemViewDataRepresentable instance if it exists or a nil
    public func cartItem(at indexPath: IndexPath) -> CartItemViewDataRepresentable? {
        
        guard (content?.count ?? 0) > indexPath.row, let contentItem = content?[indexPath.row] else {
            Log.error("No content for index path")
            return nil
        }
    
        switch contentItem {

        case .cartItemCard(let cartItem):

            return cartItem

        default:

            Log.error("Content item at index path is not a cart item.")
            return nil
        }
    }
    
    /// This method deletes the row in the table view at the index path provided
    ///
    /// - Parameters:
    ///   - tableView: the table view in which the row is to be deleted
    ///   - indexPath: the indexPath at which the row is to be deleted
    public func deleteRow(in tableView: UITableView, at indexPath: IndexPath) {
        
        guard let cartItem = self.cartItem(at: indexPath) else {
            
            assertionFailure("Unable to find cartItem at index.")
            return
        }
        
        func deleteRow() {
        
            content?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        tableView.beginUpdates()
        deleteRow()
        tableView.endUpdates()
        
        delegate?.deleteCartItem(id: cartItem.id)
    }
    
    /// This method wishlists an item at the index path provided
    ///
    /// - Parameter indexPath: The index path at which the item is to wishlisted
    public func wishlistItem(at indexPath: IndexPath) {
        
        if let cartItem = cartItem(at: indexPath) {
            
            delegate?.wishlistItem(id: cartItem.id)
        }
    }
}
    
