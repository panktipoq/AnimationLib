//
//  TableCellHelper.swift
//  Poq.iOS
//
//  Created by Jun Seki on 25/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//


public protocol TableViewControllerWithTextFields {
    
    var tableView: UITableView? { get }
    
    func resizeTableViewForKeyboardWillShow(_ notification: Notification)
    func resizeTableViewForKeyboardWillHide(_ notification: Notification)
}

extension TableViewControllerWithTextFields {
    
    // MARK: Keyboard will be shown and tableview will be pushed up.
    public func resizeTableViewForKeyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else {
            return
        }
        
        let editingIndexPath = indexPathOfFirstReponderCell()
        var contentInsets = tableView?.contentInset ?? .zero
        var scrollIndicatorInsets = tableView?.scrollIndicatorInsets ?? .zero
        
        contentInsets.bottom = keyboardSize.height
        scrollIndicatorInsets.bottom = keyboardSize.height
        
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
        UIView.animate(withDuration: duration) {
            self.tableView?.contentInset = contentInsets
            self.tableView?.scrollIndicatorInsets = scrollIndicatorInsets
        }
        
        if let indexPath = editingIndexPath {
            tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    // MARK: Keyboard will be hidden and table view will be reset
    public func resizeTableViewForKeyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        var contentInsets = tableView?.contentInset ?? .zero
        var scrollIndicatorInsets = tableView?.scrollIndicatorInsets ?? .zero
        
        contentInsets.bottom = 0
        scrollIndicatorInsets.bottom = 0
        
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
        UIView.animate(withDuration: duration) {
            self.tableView?.contentInset = contentInsets
            self.tableView?.scrollIndicatorInsets = scrollIndicatorInsets
        }
    }
    
    /**
     Return cell with text field on it, which is first responder now
     */
    fileprivate func indexPathOfFirstReponderCell() -> IndexPath? {
        
        guard let indexPaths: [IndexPath] = tableView?.indexPathsForVisibleRows else {
            return nil
        }
        
        for indexPath in indexPaths {
            let boolOrNil: Bool? = tableView?.cellForRow(at: indexPath)?.containtFirstResponderTextField()
            
            if boolOrNil == true {
                return indexPath
            }
        }
        
        
        return nil
    }
    
}
