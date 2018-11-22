//
//  ProductListDynamicFiltersViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 05/02/2016.
//
//

import Foundation
import PoqNetworking
import PoqUtilities

public protocol DynamicFilterSelectionDelegate: AnyObject {
    
    func selectionComplete(_ selectedRefinement: PoqFilterRefinement)
    func selectionClearance(_ selectedRefinementResult: PoqFilterRefinement)
}

open class ProductListDynamicFiltersViewController: ProductListFiltersController {
    
    override func configureViews() {
        setupClearButton()
        setupNavigationButtons()
        setupNavigationTitle()
        setupPriceSlider()
        
        setupFilterTable()
    }
    
    override public func resetFilters() {
        
        let title = AppLocalization.sharedInstance.filterSelectionClearAlertTitle
        let message = AppLocalization.sharedInstance.filterSelectionClearAlertMessage
        let cancelTitle = AppLocalization.sharedInstance.filterSelectionClearCancel
        let clearTitle = AppLocalization.sharedInstance.filterSelectionClearConfirm
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: clearTitle, style: .destructive) { (action) in
            
            self.filters?.selectedRefinements = []
            
            if let _ = self.filters?.prices {
                self.filters?.selectedMinPrice = nil
                self.filters?.selectedMaxPrice = nil
                self.updatePricesSlider()
            }
            
            self.filterTypesTableView?.reloadData()
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    override open func setupNavigationTitle() {
        
        let title = AppLocalization.sharedInstance.filtersNavigationTitle
        let font = AppTheme.sharedInstance.filterTypeTitleFont
        
        navigationItem.titleView = NavigationBarHelper.setupTitleView(title, titleFont: font)
    }
    
    func setupFilterTable() {
        
        filterTypesTableView?.rowHeight = UITableViewAutomaticDimension
        filterTypesTableView?.reloadData()
    }
    
    // MARK: - TableView Interaction
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        openFilterSelection(filters?.refinements?[indexPath.row])
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    open func openFilterSelection(_ refinement: PoqFilterRefinement?) {
        
        guard let selectedRefinement = refinement else {
            
            Log.warning("Invalid refinement data")
            return
        }
        
        let filtersSelectionView: ProductListDynamicFiltersSelectionViewController = ProductListDynamicFiltersSelectionViewController(nibName: "ProductListDynamicFiltersSelectionView", bundle: nil)
        filtersSelectionView.selectedRefinement = selectedRefinement
        filtersSelectionView.filters = filters
        filtersSelectionView.selectionResultDelegate = self
        
        navigationController?.pushViewController(filtersSelectionView, animated: true)
    }
    
    // MARK: - TableView Data Source
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let refinements = filters?.refinements else {
            
            return 0
        }
        
        return refinements.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        setupCellTheme(cell)
        setupCellContent(cell, refinement: filters?.refinements?[indexPath.row])
        cell.createAccessoryView()
        
        return cell
    }
    
    open func setupCellContent(_ cell: UITableViewCell, refinement: PoqFilterRefinement?) {
        
        cell.textLabel?.text = refinement?.label
        
        guard let validRefinement = refinement, let selectedRefinements = filters?.selectedRefinements, selectedRefinements.count > 0 else {
            
            return
        }
        
        // TODO: Refactor into smaller functions
        var selectedRefinementValueLabelsResult = ""
        
        for selectedRefinement in selectedRefinements {
            
            if selectedRefinement.id == validRefinement.id {
                
                guard let selectedRefinementValues = selectedRefinement.values else {
                    
                    break
                }
                
                var selectedRefinementValueLabels: [String] = []
                
                for selectedRefinementValue in selectedRefinementValues {
                    
                    if selectedRefinementValue.label != nil {
                        
                        selectedRefinementValueLabels.append(selectedRefinementValue.label!.descapeStr())
                    }
                }
                
                if selectedRefinementValueLabels.count > 0 {
                    
                    selectedRefinementValueLabelsResult = selectedRefinementValueLabels.joined(separator: ", ")
                }
                
                break
            }
        }
        
        cell.detailTextLabel?.text = selectedRefinementValueLabelsResult
    }
    
    open func setupCellTheme(_ cell: UITableViewCell) {
        
        cell.textLabel?.textColor = AppTheme.sharedInstance.filterCellTextColor
        cell.textLabel?.font = AppTheme.sharedInstance.filterCellTextFont
        cell.detailTextLabel?.font = AppTheme.sharedInstance.filterCellDetailTextFont
        cell.detailTextLabel?.textColor = AppTheme.sharedInstance.filterCellDetailTextColor
        cell.tintColor = AppTheme.sharedInstance.filterCellTintColor
        cell.backgroundView = nil
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
    }
}

extension ProductListDynamicFiltersViewController: DynamicFilterSelectionDelegate {
    
    public func selectionComplete(_ selectedRefinementResult: PoqFilterRefinement) {
        
        guard let selectedRefinements = filters?.selectedRefinements, selectedRefinements.count > 0 else {
            
            // First time selection with none previous selections
            filters?.selectedRefinements = []
            filters?.selectedRefinements?.append(selectedRefinementResult)
            filterTypesTableView?.reloadData()
            return
        }
        
        var isFoundExisting = false
        
        for selectedRefinement in selectedRefinements {
            
            if selectedRefinement.id == selectedRefinementResult.id {
                
                selectedRefinement.values = selectedRefinementResult.values
                isFoundExisting = true
                break
            }
        }
        
        if !isFoundExisting {
            
            filters?.selectedRefinements?.append(selectedRefinementResult)
        }
        
        filterTypesTableView?.reloadData()
    }
    
    public func selectionClearance(_ selectedRefinementResult: PoqFilterRefinement) {
        
        guard let selectedRefinements = filters?.selectedRefinements, selectedRefinements.count > 0 else {
            
            return
        }
        
        for index in 0 ..< selectedRefinements.count {
            
            if selectedRefinements[index].id == selectedRefinementResult.id {
                
                filters?.selectedRefinements?.remove(at: index)
            }
        }
        
        filterTypesTableView?.reloadData()
    }
}
