//
//  ProductListDynamicFiltersSelectionViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 05/02/2016.
//
//

import Foundation
import PoqNetworking
import UIKit

open class ProductListDynamicFiltersSelectionViewController: ProductListDynamicFiltersViewController {
    
    open var selectedRefinement: PoqFilterRefinement = PoqFilterRefinement()
    open var existingSelectedRefinement: PoqFilterRefinement?
    
    weak open var selectionResultDelegate: DynamicFilterSelectionDelegate?
    
    override func configureViews() {
        setupClearButton()
        clearButton?.title = AppLocalization.sharedInstance.filterClearTitle
        
        setupNavigationButtons()
        setupNavigationTitle()
        setupFilterTable()
        
        findExistingRefinementForSelectedRefinement()
    }
    
    override open func setupNavigationButtons() {
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        navigationItem.rightBarButtonItem = nil
    }
        
    override open func setupNavigationTitle() {
        guard let selectedRefinementTitle = selectedRefinement.label else {
            return
        }
        
        let titleLabel = NavigationBarHelper.setupTitleView(selectedRefinementTitle, titleFont: AppTheme.sharedInstance.filterTypeTitleFont)
        navigationItem.titleView = titleLabel
    }
    
    override public func resetFilters() {
        guard let existingSelectedRefinementValues = existingSelectedRefinement?.values, existingSelectedRefinementValues.count > 0 else {
            return
        }
        
        let title = AppLocalization.sharedInstance.filterSelectionClearAlertTitle
        let message = AppLocalization.sharedInstance.filterSelectionClearAlertMessage
        let cancelTitle = AppLocalization.sharedInstance.filterSelectionClearCancel
        let clearTitle = AppLocalization.sharedInstance.filterSelectionClearConfirm
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: clearTitle, style: .destructive) { (action) in
            self.existingSelectedRefinement?.values = []
            self.filterTypesTableView?.reloadData()
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    override open func backButtonClicked() {
        let _ = navigationController?.popViewController(animated: true)
        guard let existingSelectedRefinementValues = existingSelectedRefinement?.values, existingSelectedRefinementValues.count > 0 else {
            
            // User unselected all values and clicked done
            // So we need to clear the selections
            
            if existingSelectedRefinement != nil {
                
                selectionResultDelegate?.selectionClearance(existingSelectedRefinement!)
            }
            
            return
        }
        
        if existingSelectedRefinement != nil {
            
            selectionResultDelegate?.selectionComplete(existingSelectedRefinement!)
        }
    }
    
    // MARK: - TableView Interaction
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let isSelected = updateCellMark(tableView.cellForRow(at: indexPath))
        updateCellTitleColor(tableView.cellForRow(at: indexPath))
        updateSelection(selectedRefinement.values?[indexPath.row], isSelected: isSelected)
    }
    
    open func updateCellMark(_ cell: UITableViewCell?) -> Bool {
        
        guard let selectedCell = cell else {
            
            return true
        }
        
        selectedCell.accessoryType = selectedCell.accessoryType == .checkmark ? .none : .checkmark
        selectedCell.textLabel?.textColor = selectedCell.accessoryType == .checkmark ? AppTheme.sharedInstance.filterCellTintColor : AppTheme.sharedInstance.filterCellTextColor
        
        return selectedCell.accessoryType == .checkmark
    }
    
    open func updateCellTitleColor(_ cell: UITableViewCell?) {
        
        guard let selectedCell = cell else {
            return
        }
        
        selectedCell.textLabel?.textColor = selectedCell.accessoryType == .checkmark ? AppTheme.sharedInstance.filterCellTintColor : AppTheme.sharedInstance.filterCellTextColor
    }
    
    open func updateSelection(_ refinementValue: PoqFilterRefinementValue?, isSelected: Bool) {
        
        guard let selectedRefinementValue = refinementValue else {
            
            return
        }
        
        if isSelected {
            
            addRefinementSelection(selectedRefinementValue)
        }
        else {
            
            removeRefinementSelection(selectedRefinementValue)
        }
    }
    
    func addRefinementSelection(_ refinementValue: PoqFilterRefinementValue) {
        
        createIfExistingSelectionNotExists()
        
        existingSelectedRefinement?.values?.append(refinementValue)
    }
    
    func removeRefinementSelection(_ refinementValue: PoqFilterRefinementValue) {
        
        guard let existingRefinementValues = existingSelectedRefinement?.values else {
            
            return
        }
        
        for index in 0 ..< existingRefinementValues.count {
            
            if existingRefinementValues[index].id == refinementValue.id {
                
                existingSelectedRefinement?.values?.remove(at: index)
                break
            }
        }
    }
    
    func createIfExistingSelectionNotExists() {
        
        if existingSelectedRefinement == nil {
            
            existingSelectedRefinement = PoqFilterRefinement()
            existingSelectedRefinement?.id = selectedRefinement.id
            existingSelectedRefinement?.label = selectedRefinement.label
            existingSelectedRefinement?.values = []
        }
    }
    
    // MARK: - TableView Data Source
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let refinementsValues = selectedRefinement.values else {
            
            return 0
        }
        
        return refinementsValues.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        setupCellTheme(cell)
        setupCellAccessory(cell, row: indexPath.row)
        setupCellContent(cell, refinement: selectedRefinement.values?[indexPath.row])
        updateCellTitleColor(cell)
        return cell
    }
    
    open func setupCellContent(_ cell: UITableViewCell, refinement: PoqFilterRefinementValue?) {
        
        cell.textLabel?.text = refinement?.label
    }
    
    open func setupCellAccessory(_ cell: UITableViewCell, row: Int) {
        
        cell.accessoryType = isRefinementPreviouslySelected(row) ? .checkmark : .none
        cell.accessoryView?.backgroundColor = UIColor.clear
    }
    
    override open func setupCellTheme(_ cell: UITableViewCell) {
        
        super.setupCellTheme(cell)
    }
}

extension ProductListDynamicFiltersSelectionViewController {
    
    open func isRefinementPreviouslySelected(_ row: Int) -> Bool {
        
        guard let refinementValue = selectedRefinement.values?[row] else {
            
            return false
        }
        
        guard let existingSelectedRefinementValues = existingSelectedRefinement?.values else {
            
            return false
        }
        
        for existingSelectedRefinementValue in existingSelectedRefinementValues {
            
            if existingSelectedRefinementValue.id?.descapeStr() == refinementValue.id {
                
                return true
            }
        }
        
        return false
        
    }
    
    func findExistingRefinementForSelectedRefinement() {
        
        guard let existingSelectedRefinements = filters?.selectedRefinements else {
            
            return
        }
        
        
        for existingSelectedRefinement in existingSelectedRefinements {
            
            if existingSelectedRefinement.id == selectedRefinement.id {
                
                self.existingSelectedRefinement = existingSelectedRefinement
                break
            }
        }
    }
}
