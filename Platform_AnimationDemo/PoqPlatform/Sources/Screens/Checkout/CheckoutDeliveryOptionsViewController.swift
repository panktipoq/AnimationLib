//
//  CheckoutDeliveryOptionsViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 29/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit

public protocol DeliveryMethodSelectionDelegate: AnyObject {
    func didSelect(_ deliveryMethod: PoqDeliveryOption)
}

open class CheckoutDeliveryOptionsViewController: PoqBaseViewController, UITableViewDelegate {
    
    override open var screenName: String {
        return "Checkout - Delivery Options Screen"
    }
        
    public let rowHeight = CGFloat(80)
    
    open var deliveryAddress: PoqAddress?
    open var viewModel: CheckoutDeliveryOptionsViewModel?
    open var showAccessory: Bool = false
    
    open var paymentOptionAlreadySelected: Bool = false
    
    open weak var delegate: DeliveryMethodSelectionDelegate?
    open var selectedOption: PoqDeliveryOption?
    
    @IBOutlet open var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView(frame: CGRect.zero)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.estimatedRowHeight = rowHeight
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.registerPoqCells(cellClasses: [CheckoutDeliveryOptionsCell.self])
        }
    }
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        
        viewModel = CheckoutDeliveryOptionsViewModel(viewControllerDelegate: self)
        
        initNavigationBar()
        getDeliveryOptions()
    }
    
    public func initNavigationBar() {
        
        navigationItem.titleView = NavigationBarHelper.setupTitleView(AppLocalization.sharedInstance.checkoutDeliveryOptionsPageTitle)
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        navigationItem.rightBarButtonItem = nil
    }
    
    open func getDeliveryOptions() {
        
        guard let validDeliveryAddress = deliveryAddress, let postAddress = viewModel?.createPostAddress(validDeliveryAddress) else {
            
            showInvalidAddressAlert()
            return
        }
        
        viewModel?.loadDeliveryOption(postAddress)
    }
    
    public func showInvalidAddressAlert() {
        
        let alert = UIAlertController(title: "Invalid Country Selection", message: "Please update your shipping/billing addresses", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (_: UIAlertAction) in
            self.backButtonClicked()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    public  func showInvalidAddressAlert(_ message: String) {
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (_: UIAlertAction) in
            self.backButtonClicked()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        if networkTaskType == PoqNetworkTaskType.postDeliveryOption {
            
            PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.DeliveryOptions.step, option: CheckoutActionType.DeliveryOptions.option)
            if let existedSelectedOption = selectedOption {
                delegate?.didSelect(existedSelectedOption)
            }
            
            paymentOptionAlreadySelected = false
            super.backButtonClicked()
        } else {
            
            if let networkResultValidation = viewModel?.networkResultValidation, !networkResultValidation.isValid {
                
                showInvalidAddressAlert(networkResultValidation.message)
                
                // Reset data source to hide tableview empty cells
                viewModel?.deliveryOptions = []
            }
            
            tableView.reloadData()
        }
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {

        super.networkTaskDidFail(networkTaskType, error: error)
        
        if networkTaskType == PoqNetworkTaskType.postDeliveryOption {
            
            paymentOptionAlreadySelected = false
        }
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let existedSelectedOption = viewModel?.getDeliverySelection(indexPath), !paymentOptionAlreadySelected else {
            
            return
        }
        selectedOption = existedSelectedOption
        viewModel?.postDeliverySelection(existedSelectedOption)
        showAccessory = true
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        tableView.deselectRow(at: indexPath, animated: true)
        paymentOptionAlreadySelected = true
    }
}

// MARK: - UITableViewDataSource Implementation
// __________________________

extension CheckoutDeliveryOptionsViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let numberOfRows = viewModel?.getNumberOfRowsForTableView(section) else {
            
            return 0
        }
        
        return numberOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = viewModel?.getCellForRowAtIndexPath(tableView, cellForRowAtIndexPath: indexPath, withAccessoriType: showAccessory) else {
            
            return UITableViewCell()
        }
        
        return cell
    }
}
