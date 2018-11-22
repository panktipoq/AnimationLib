//
//  CheckoutAddressImportSelectionViewController.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 10/2/15.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking

public protocol SelectedAddress: AnyObject {

    func selectedValue(_ indext: Int)
}

open class CheckoutAddressImportSelectionViewController: PoqBaseViewController {
    
    override open var screenName: String {
        return "Checkout - Contact Address Import Selection Screen"
    }
    
    open var viewModel = CheckoutAddressImportSelectionViewModel()
    
    public let rowHeight: CGFloat = 44.00
    
    weak open var delegate: SelectedAddress?
    
    @IBOutlet var importSelectionContainer: UIView?
    @IBOutlet var importSelectionHiddenConstraint: NSLayoutConstraint?
    
    @IBOutlet open var tableViewHeightConstraints: NSLayoutConstraint?
    
    @IBOutlet open var deliveryTypeTableView: UITableView? {
        didSet {

            deliveryTypeTableView?.registerPoqCells(cellClasses: [ProductSizeTableViewCell.self])
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateHeight()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateTo(hidden: false)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.backgroundColor = .clear
    }

    // Tap outside the view to dissmiss itself
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

            self.dismiss(animated: true, completion: nil)
    }
    
    open func showDeliveryModelWithContact(_ message: String, information: [String?]?) {

        viewModel.contactInformation = information
        viewModel.headerTitle = message
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        deliveryTypeTableView?.reloadData()
    }
    
    open func updateHeight() {
        
        let numberOfRows = viewModel.getNumberOfContactInfoRows()
        var height = CGFloat(numberOfRows + 1) * rowHeight
        
        // Max height that table view can have
        let validHeight = UIScreen.main.bounds.size.height * 2 / 3
        
        if height > validHeight {
            height = validHeight
        }
        
        tableViewHeightConstraints?.constant = height
    }
    
    private func animateTo(hidden: Bool) {
        importSelectionHiddenConstraint?.isActive = hidden
        
        let backgroundColor = UIColor(white: 0, alpha: hidden ? 0.5 : 0)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.view.backgroundColor = backgroundColor
        }
    }
}

// MARK: - UITableViewDelegate Implementation
// __________________________

extension CheckoutAddressImportSelectionViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewHeightConstraints?.constant = 0
        self.dismiss(animated: true, completion: { () in
            self.delegate?.selectedValue(indexPath.row)
        })
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sizeSelectorHeader = viewModel.getViewForHeaderInSection(tableView, viewForHeaderInSection: section) as? SizeSelectorHeader
        sizeSelectorHeader?.delegate = self
        return sizeSelectorHeader
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return rowHeight
    }
    
    // Remove the weird animation for view cell labels flying to the middle
    // http://stackoverflow.com/questions/30692417/layoutifneeded-affecting-table-view-cells
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        UIView.performWithoutAnimation { () in
            cell.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource Implementation
// __________________________

extension CheckoutAddressImportSelectionViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.getNumberOfContactInfoRows()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       return viewModel.getCellForRowAtIndexPath(tableView, cellForRowAtIndexPath: indexPath)
    }
}

// MARK: - SizeSelectorHeaderDelegate

extension CheckoutAddressImportSelectionViewController: SizeSelectorHeaderDelegate {}
