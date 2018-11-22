//
//  CartTableViewDelegate.swift
//  PoqCart
//
//  Created by Balaji Reddy on 26/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import UIKit
import PoqUtilities

/**
    This class is a UITableViewDelegate subclass for the Cart View content table
 */
public class CartTableViewDelegate: NSObject, UITableViewDelegate {
    
    var dataSource: CartContentTableDataProvidable
    var swipingToDelete: Bool = false
    var shouldShowMoveToWishlistAction = false
    
    init(dataSource: CartContentTableDataProvidable) {
        self.dataSource = dataSource
    }
    
    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        
        swipingToDelete = true
    }
    
    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        
        if !tableView.isEditing {
            swipingToDelete = false
        }
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {

        return .delete
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        // Swipe-To-Delete in progress, don't update cells for edit mode
        guard !swipingToDelete else {
            return
        }
        
        if let editableCell = cell as? ViewEditable {
            editableCell.setEditMode(to: tableView.isEditing, animate: false)
        }
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var editActions = [UITableViewRowAction]()
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE".localizedPoqString) {
            
            _, indexPath in
            
            self.dataSource.deleteRow(in: tableView, at: indexPath)
        }
        
        deleteAction.backgroundColor = .red
        
        editActions.append(deleteAction)
        
        if shouldShowMoveToWishlistAction {
            
            let wishlistAction = UITableViewRowAction(style: .destructive, title: "MOVE_TO_WISHLIST".localizedPoqString) {
                
                _, indexPath in
                
                self.dataSource.wishlistItem(at: indexPath)
                
                self.dataSource.deleteRow(in: tableView, at: indexPath)
            }
            
            wishlistAction.backgroundColor = .orange
            
            editActions.append(wishlistAction)
        }
        
        return editActions
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        var actions = [UIContextualAction]()
        let deleteActionTitle = "DELETE".localizedPoqString

        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle, handler: {
        
            (_, _, completionHandler) in
            
            // Update data source when user taps action
            self.dataSource.deleteRow(in: tableView, at: indexPath)
            completionHandler(true)
        })
        
        deleteAction.backgroundColor = .red

        actions.append(deleteAction)

        if shouldShowMoveToWishlistAction {
            
            let favoriteActionTitle = "MOVE_TO_WISHLIST".localizedPoqString
            let favoriteAction = UIContextualAction(style: .destructive, title: favoriteActionTitle, handler: {
                
                (_, _, completionHandler) in

                // Update data source when user taps action
                self.dataSource.wishlistItem(at: indexPath)

                self.dataSource.deleteRow(in: tableView, at: indexPath)
                completionHandler(true)
            })

            favoriteAction.backgroundColor = .orange

            actions.append(favoriteAction)
        }
    
        let configuration = UISwipeActionsConfiguration(actions: actions)
        return configuration
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let cartItem = dataSource.cartItem(at: indexPath) else {
            Log.debug("Cart Content Cell tapped but not a Cart Item. Nothing to do.")
            return
        }
        
        dataSource.delegate?.didTapOnCartItem(id: cartItem.id)
    }
}
