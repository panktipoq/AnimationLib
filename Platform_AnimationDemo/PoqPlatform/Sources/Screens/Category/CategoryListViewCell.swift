//
//  CategoryListViewCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 29/06/2016.
//
//

import Foundation
import PoqNetworking
import UIKit

/// A cell inside the category list
open class CategoryListViewCell: UITableViewCell {

    /// The label rendering the category name
    @IBOutlet open weak var categoryNameLabel: UILabel?
    
    /// The constraint of the top label
    @IBOutlet open weak var topLabelConstraint: NSLayoutConstraint?
    
    /// The constraint of the bottom label
    @IBOutlet open weak var bottomLabelConstraint: NSLayoutConstraint?

    /// Updates the UI accordingly to the object model
    ///
    /// - Parameters:
    ///   - category: The category object
    ///   - branded: Wether the category object is a branded category or not
    open func updateUI(_ category: PoqCategory, branded: Bool = false) {
        
        categoryNameLabel?.textColor = AppTheme.sharedInstance.mainTextColor

        categoryNameLabel?.text = branded ? category.title?.uppercased() : category.title

        categoryNameLabel?.font = branded ? AppTheme.sharedInstance.brandTextCategoryFont : AppTheme.sharedInstance.mainTextFont
        categoryNameLabel?.numberOfLines = 0

        isAccessibilityElement = true
        accessibilityIdentifier = AccessibilityLabels.categoryList

        if !branded {
            topLabelConstraint?.constant = 0
            bottomLabelConstraint?.constant = 0
        }
    }
}
