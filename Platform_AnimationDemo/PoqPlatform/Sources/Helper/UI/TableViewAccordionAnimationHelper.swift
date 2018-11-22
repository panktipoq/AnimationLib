//
//  TableViewAccordionAnimationHelper.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 12/3/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import UIKit

public class TableViewAccordionAnimationHelper {
    
    /// Removes cells for subcategories from the specified row and tableview.
    public static func removeSubCategoryCells(_ range: Range<Int>, forRow row: Int, in tableView: UITableView?) {
        // Select range to be removed.
        // This will start from next available cell from the selection to the next sibling level
        
        // Remove inserted children
        // The children data is always in parent's children array
        
        let categoryCellPath = IndexPath(row: row, section: 0)
        if let categoryCell = tableView?.cellForRow(at: categoryCellPath) as? AccordionTableViewCell {
            categoryCell.setClose(animated: true)
        }
        
        // Remove subcategory index paths
        let indexPaths: [IndexPath] = (range.lowerBound..<range.upperBound).compactMap({ IndexPath(row: $0, section: 0) })
        tableView?.removeRowsForAccordion(indexPaths, selectedRowIndex: row)
    }
    
    /// Appends loaded subcategories at the specified row and tableview.
    public static func insertSubCategoryCells(_ count: Int, atRow row: Int, in tableView: UITableView?) {
        let categoryCellPath = IndexPath(row: row, section: 0)
        if let categoryCell = tableView?.cellForRow(at: categoryCellPath) as? AccordionTableViewCell {
            categoryCell.unsetLoading()
            categoryCell.setOpen(animated: true)
        }
        
        // Insert loaded subcategories to the main data source to show on tableview
        let indexPaths: [IndexPath] = (0..<count).compactMap({ IndexPath(row: 1 + row + $0, section: 0) })
        tableView?.insertingRowsForAccordion(indexPaths, selectedRowIndex: row)
    }
    
    /* Finds the next sibling in the same level of category hierarchy */
    public static func findNextAvailableLevel(_ selectedIndex: Int, dataSource: [AccordionTableViewCategory]) -> Int {
        
        // Set result to selected index not to exceed array length for the last item
        var result = selectedIndex
        
        for index in selectedIndex+1 ..< dataSource.count where dataSource[selectedIndex].level >= dataSource[index].level {
                result = index
                break
        }
        
        // The item is the last item so no next level
        // The result will be length of the array
        if result == selectedIndex {
            result = dataSource.count
        }
        return result
    }
}

open class AccordionTableViewCell: UITableViewCell {
    
    @IBOutlet open weak var indicatorView: PlusMinus?
    @IBOutlet open weak var spinnerView: PoqSpinner?
    
    public var isEnabled = true
    
    open func setOpen(animated: Bool) {
        
        // Minus Icon
        indicatorView?.isHidden = !isEnabled
        indicatorView?.open()
        accessoryType = UITableViewCellAccessoryType.none
    }
    
    open func setClose(animated: Bool) {
        
        // Plus Icon
        indicatorView?.isHidden = !isEnabled
        indicatorView?.close()
        accessoryType = UITableViewCellAccessoryType.none
    }
    
    open func setDetail() {
        
        // Detail Icon is empty to reduce confusion
        indicatorView?.isHidden = true
        accessoryType = UITableViewCellAccessoryType.none
    }
    
    open func setLoading() {
        
        // Set the tint color of the spinner
        spinnerView?.tintColor = AppTheme.sharedInstance.mainColor
        spinnerView?.isHidden = false
        spinnerView?.startAnimating()
    }
    
    open func unsetLoading() {
        
        spinnerView?.isHidden = true
        spinnerView?.stopAnimating()
    }
}

extension UITableView {
    
    @nonobjc
    public func insertingRowsForAccordion(_ indexArray: [IndexPath], selectedRowIndex: Int) {
        // Insert subcategories into the selected index
        beginUpdates()
        insertRows(at: indexArray, with: UITableViewRowAnimation.fade)
        endUpdates()
        
        // Scroll to selection after expanding children
        scrollToRow(at: IndexPath(row: selectedRowIndex, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
    
    @nonobjc
    public func removeRowsForAccordion(_ indexArray: [IndexPath], selectedRowIndex: Int) {
        // Remove subcategories into the selected index
        beginUpdates()
        deleteRows(at: indexArray, with: UITableViewRowAnimation.fade)
        endUpdates()
        
        // Scroll to selection after expanding children
        scrollToRow(at: IndexPath(row: selectedRowIndex, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
}
