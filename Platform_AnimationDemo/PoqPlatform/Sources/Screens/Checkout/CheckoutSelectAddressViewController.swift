//
//  CheckoutSelectAddressViewController.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/25/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import Stripe
import UIKit

public protocol AddressSelectionDelegate: AnyObject {
    
    func selectAddress(_ responder: CheckoutSelectAddressResponder, didSelectedAddress adrdess: PoqAddress)
}

open class CheckoutSelectAddressViewController: PoqBaseViewController, CheckoutSelectAddressResponder, NavigationBarTitle, ChooseSameAddressDelegate {
    
    /// For address selection - we don't need to know which paticular items used in checkout
    /// So lets use default platform
    typealias CheckoutItemType = PoqCheckoutItem<PoqBagItem>

    override open var screenName: String {
        switch addressType {
        case .Billing:
            return "Checkout - Select Billing Address Screen"
        case .Delivery:
            return "Checkout - Select Delivery Address Screen"
        default:
            Log.warning("Unknown address selection screen type")
            return super.screenName
        }
    }
    
    override open class var XibName: String {
        
        return "CheckoutSelectAddressViewController"
    }

    public lazy var viewModel: CheckoutSelectAddressViewModel = {
        [unowned self] in
        let checkoutSelectAddressViewModel = CheckoutSelectAddressViewModel(viewControllerDelegate: self, existedBillinAddress: self.existedBillinAddress)
        return checkoutSelectAddressViewModel
    }()

    public var addressType = AddressType.NewAddress
    public var isRedirectedToNewAddress = false
    
    /// If this value is nil - we won't show 'as billing' switcher, since no billing
    public var existedBillinAddress: PoqAddress?
    
    /// Address, which we have sent to API
    public var postedAddress: PoqAddress?
    
    public weak var delegate: AddressSelectionDelegate?
    
    @IBOutlet public weak var addressTableView: UITableView? {

        didSet {
            addressTableView?.tableFooterView = UIView(frame: CGRect.zero)
            
            addressTableView?.registerPoqCells(cellClasses: [CheckoutSameAddressTableViewCell.self, MyProfileAddressBookTitleTableViewCell.self])
            addressTableView?.estimatedRowHeight = UITableViewAutomaticDimension
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // FIXME: localize
        let addButtonItem = NavigationBarHelper.createButtonItem(withTitle: "Add", target: self, action: #selector(CheckoutSelectAddressViewController.addButtonPressed))
        setUpNavigationBar(AddressHelper.getTitle(addressType),
                           leftBarButtonItem: NavigationBarHelper.setupBackButton(self),
                           rightBarButtonItem: addButtonItem)
        viewModel.addressType = addressType
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getAddresses()
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        addressTableView?.isUserInteractionEnabled = true
        
        guard let validError: NSError = error else {
            return
        }
        
        let errorMessage: String = validError.errorMessage()
        
        guard let validNavigationController = navigationController else {
            return
        }
        
        let validAlertController = UIAlertController(title: "", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)

        validAlertController.addAction(UIAlertAction.init(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (_: UIAlertAction) in
            // FIXME: strange dependencies, find other way, maybe notification?
            StripeHelper.sharedInstance.removePaymentPrefferedPaymentSource()
            validNavigationController.popViewController(animated: true)
        }))
        
        self.present(validAlertController, animated: true) {
            // Completion handler once everything is dismissed
        }
    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        addressTableView?.isUserInteractionEnabled = true
        
        if networkTaskType == .saveAddressesToOrder {

            switch addressType {
                
            case .Billing:
                PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.BillingAddress.step, option: CheckoutActionType.BillingAddress.option)
                
            case .Delivery:
                PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.ShippingAddress.step, option: CheckoutActionType.ShippingAddress.option)
                
            default:
                Log.warning("Undefined addresstype for checkout option")
            }
        
            if let validAddress = postedAddress {
                delegate?.selectAddress(self, didSelectedAddress: validAddress)
            }
            
            _ = navigationController?.popViewController(animated: true)
        } else if networkTaskType == .getAddresses && viewModel.content.count == 0 {
            
            guard !isRedirectedToNewAddress else {
                _ = navigationController?.popViewController(animated: true)
                return
            }
            
            isRedirectedToNewAddress = true
            addButtonPressed()
            
        } else if networkTaskType == .stripeCheckCardToken {
            _ = navigationController?.popViewController(animated: true)
        }
        
        addressTableView?.reloadData()
        addressTableView?.isUserInteractionEnabled = true
    }
    
    open func isSameAddressChangeValue(_ sameAs: AddressSameAs, isSame: Bool) {
        guard let billingAddress = existedBillinAddress else {
            return
        }
        
        viewModel.postAddress(billingAddress)
    }
}

// MARK: - UITableViewDelegate Implementation
// __________________________

extension CheckoutSelectAddressViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.getHeight(indexPath)
    }
}

// MARK: - UITableViewDataSource Implementation
// __________________________

extension CheckoutSelectAddressViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.getCellForRow(tableView, indexPath: indexPath, delegate: self)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard viewModel.content[indexPath.row].cellType != CheckoutAddressLabelNames.SameAsBilling else {
            if let billingAddress = existedBillinAddress {
                viewModel.changeUISiwtchCellValue(tableView, indexPath: indexPath)
                viewModel.postAddress(billingAddress)
                postedAddress = billingAddress
            }
            return
        }
        
        let address: PoqAddress = viewModel.content[indexPath.row].address
        
        viewModel.postAddress(address)
        postedAddress = address
        addressTableView?.isUserInteractionEnabled = false
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    @objc open func addButtonPressed() {
        NavigationHelper.sharedInstance.loadAddAddress(addressType, title: nil)
    }
}
