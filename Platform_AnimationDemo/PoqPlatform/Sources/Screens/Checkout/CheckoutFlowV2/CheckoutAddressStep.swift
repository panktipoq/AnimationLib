//
//  CheckoutAddressStep.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 14/07/2016.
//
//

import Foundation
import PoqNetworking
import PoqUtilities

public protocol CheckoutSelectAddressResponder {
    var postedAddress: PoqAddress? { get set }
}

open class CheckoutAddressStep<CFC: CheckoutFlowController>: CheckoutFlowStep<CFC>, TableCheckoutFlowStep, CheckoutStep3LinePresentation {

    public var stepNumber: Int?
    
    weak public var tableViewOwner: CheckoutTableViewOwner?
    
    public var addressType: AddressType = AddressType.Billing
    
    public init(addressType: AddressType) {
        
        assert([.Billing, .Delivery].contains(addressType), "Not supported address type \(addressType)")
        self.addressType = addressType
    }
    
    public var address: PoqAddress?
    
    // MARK: CheckoutFlowStep override
    open override var checkoutStep: CheckoutStep {
        return addressType == .Billing ? .billingAddress : .shippingAddress
    }
    
    open override var status: StepStatus {
        if let _ = address?.countryId {
            return .completed
        }
        
        return .notCompleted(message: AppLocalization.sharedInstance.checkoutSelectDeliveryAddressMessage)
    }
    
    open override func update(_ checkoutItem: CheckoutItemType) {
        address = addressType == .Billing ? checkoutItem.billingAddress : checkoutItem.shippingAddress
    }
    
    open override func populateCheckoutItem(_ checkoutItem: CheckoutItemType) {
        switch addressType {
        case .Billing:
            checkoutItem.billingAddress = address
            
        case .Delivery:
            checkoutItem.shippingAddress = address
            
        default:
            Log.error("How does it possible? \(addressType)")
        }
    }
    
    open override func canFlowPresentsStep(_ step: CheckoutStep) -> CheckoutFlowCanPresentResult {
        // we should prevent app from showng delivery option selection while, not delivery address
        guard addressType == .Delivery && step == .deliveryMethod else {
            return .ok
        }
        
        // adres may be not nil, but there will be no fields
        // just minor validation
        guard let existedAddress = address, existedAddress.countryId != nil && existedAddress.address1 != nil else {
            return .cannotPresent(errorMessage: AppLocalization.sharedInstance.orderConfirmationNoDeliveryAddressError)
        }
        return .ok
    }
    
    public func registerReuseViews(_ tableView: UITableView?) {
        
        tableView?.registerPoqCells(cellClasses: [CheckoutOrderSummaryCell.self, CheckoutStepCell.self])
    }
    
    public func numberOfCellInOverviewSection() -> Int {
        return 1
    }
    
    open func overviewCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int) -> UITableViewCell {
        
        let cell = configureCheckoutStepCell(tableView, atIndexPath: indexPath)
        
        cell.accessibilityIdentifier = addressType == .Billing ? AccessibilityLabels.billingAddressCell : AccessibilityLabels.deliveryAddressCell
        
        cell.createAccessoryView()
        
        return cell
    }
    
    open func overviewCellSelected(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int) {
        let addressSection = CheckoutSelectAddressViewController(nibName: CheckoutSelectAddressViewController.XibName, bundle: nil)
        addressSection.addressType = addressType
        
        if addressType == .Delivery {
            addressSection.existedBillinAddress = flowController?.addressStep(.Billing)?.address
        }
        addressSection.delegate = self
        
        flowController?.presentStepDetail(self, viewController: addressSection, modal: false)
    }
    
    /// we have 3 different styles of label,they depends on which line this label is. May be used only one this line
    open var firstLine: String? {
        return addressType == .Delivery ? "CHECKOUT_DELIVERY_STEP_FIRST_LINE".localizedPoqString : "CHECKOUT_BILLING_STEP_FIRST_LINE".localizedPoqString
    }
    
    open var secondLine: String? {
        guard let address = address, address.countryId != nil else {
            return nil
        }
        
        let fullName = String.combineComponents([address.firstName, address.lastName], separator: " ")
        
        return fullName
    }

    open var thirdLine: String? {
        guard let address = address, address.countryId != nil else {
            return CheckoutAddressStep.selectAddressText(addressType)
        }

        let line2 = String.combineComponents([address.address1, address.address2], separator: ", ")
        let line3 = String.combineComponents([address.city, address.postCode, address.country], separator: ", ")
        let line4 = address.phone
        
        return String.combineComponents([line2, line3, line4], separator: "\n")
    }
    
    open var rightDetailText: String? { return nil }
}

extension CheckoutAddressStep: AddressCheckoutStep {
}

extension CheckoutAddressStep: AddressSelectionDelegate {
    
    public func selectAddress(_ responder: CheckoutSelectAddressResponder, didSelectedAddress adrdess: PoqAddress) {
        self.address = adrdess
        flowController?.stepDidUpdateInformation(self)
    }
}

// MARK: Private

extension CheckoutAddressStep {

    fileprivate final func configureCheckoutOrderSummaryCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {

        let cell: CheckoutOrderSummaryCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        var contentStrint: String = AddressHelper.createFullAddress(address)
        let subTitle: String
        if contentStrint.isNullOrEmpty() {

            contentStrint = CheckoutAddressStep.selectAddressText(addressType)
            subTitle = ""
        } else {
            subTitle = String(format: "ADDRESS_TYPE".localizedPoqString, addressType.rawValue)
        }
        
        cell.setupUI(subTitle, contentDetail: contentStrint)
        
        return cell
    }

    public static func selectAddressText(_ addressType: AddressType) -> String {
        
        // FIXME: This is not even localization, it is always english.
        var addressTypeString = ""
        
        switch addressType {
        case .Billing:
            addressTypeString = "ADDRESS_TYPE_BILLING".localizedPoqString
        case .Delivery:
            addressTypeString = "ADDRESS_TYPE_DELIVERY".localizedPoqString
        case .AddressBook:
            addressTypeString = "ADDRESS_TYPE_ADDRESS_BOOK".localizedPoqString
        case .NewAddress:
            addressTypeString = "ADDRESS_TYPE_NEW_ADDRESS".localizedPoqString
        }
        
        let addressTypeText = String(format: "ADDRESS_TYPE".localizedPoqString, addressTypeString)
        
        return String(format: "SELECT_ADDRESS_TYPE".localizedPoqString, addressTypeText)
    }
}
