//
//  CheckoutSelectAddressViewModel.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/25/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import Locksmith
import PoqNetworking
import PoqUtilities
import PoqAnalytics

public struct CheckoutSelectAddressCellType {
    public var cellType: String
    public var address: PoqAddress
    public var height: CGFloat
    
    public init(cellType: String, address: PoqAddress, height: CGFloat) {
        self.cellType = cellType
        self.address = address
        self.height = height
    }
}

open class CheckoutSelectAddressViewModel: BaseViewModel, PoqTitleBlock {
    
    let addressIdentifier                               = "AddressIdentifier"
    public var addressType = AddressType.NewAddress
    public var content = [CheckoutSelectAddressCellType]()
    let titleRowHeight: CGFloat                         = 50
    let restRowHeight: CGFloat                         = 80
    var sameAsBilling                                   = false
    
    public var existedBillinAddress: PoqAddress?
    
    public init(viewControllerDelegate: PoqBaseViewController, existedBillinAddress: PoqAddress?) {
        self.existedBillinAddress = existedBillinAddress
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        super.networkTaskDidFail(networkTaskType, error: error)
        guard let validViewControllerDelegate = self.viewControllerDelegate else {
            return
        }
        if networkTaskType != PoqNetworkTaskType.stripeCheckCardToken {
            validViewControllerDelegate.networkTaskDidFail(networkTaskType, error: error)
        }
    }

    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        super.networkTaskDidComplete(networkTaskType, result: result)

        if let networkResult = result as? [PoqAddress], networkResult.count > 0 {
            content = []
            if existedBillinAddress != nil {
                setUpSameAsBilling()
            }
            let addressItems = networkResult.map({ (address: PoqAddress) -> CheckoutSelectAddressCellType in
                return CheckoutSelectAddressCellType(cellType: AppLocalization.sharedInstance.addressTextCheckout, address: address, height: restRowHeight)
            })
            content.append(contentsOf: addressItems)
        }
        guard let validViewControllerDelegate = self.viewControllerDelegate else {
            return
        }
        if networkTaskType != PoqNetworkTaskType.stripeCheckCardToken {
            validViewControllerDelegate.networkTaskDidComplete(networkTaskType)
        }
    }

    open func setUpSameAsBilling() {
        if AppSettings.sharedInstance.addressTypeTitleEnabled {
            content.append(CheckoutSelectAddressCellType(cellType: CheckoutAddressLabelNames.Title, address: PoqAddress(), height: titleRowHeight))
        }
        
        if addressType == .Delivery {
            content.append(CheckoutSelectAddressCellType(cellType: CheckoutAddressLabelNames.SameAsBilling, address: PoqAddress(), height: AppSettings.sharedInstance.checkoutAddressTableViewCellHeight))
        }
    }

    open func getAddresses() {
        PoqNetworkService(networkTaskDelegate: self).getCheckoutAddresses()
    }

    open func postAddress(_ address: PoqAddress) {

        // TODO: #PLA-850 if we still need support MSG without cards list - we should make operaions and queue them
        // StripeHelper.sharedInstance.checkCurrentPaymentSourceWithBillingAddress(validAddress)
        
        let postAddress = PoqPostAddress()
        switch addressType {
        case AddressType.Billing:
            postAddress.billingAddress = address
            address.isDefaultBilling = true
            PoqTrackerV2.shared.checkoutAddress(type: AddressType.Billing.rawValue, userId: User.getUserId())
            
        case AddressType.Delivery:
            postAddress.shippingAddress = address
            address.isDefaultShipping = true
            PoqTrackerV2.shared.checkoutAddress(type: AddressType.Delivery.rawValue, userId: User.getUserId())
            
        default:
            Log.error("We are tryint to save unsupported address type")
            return
        }

        if let orderId = BagHelper().getOrderId() {
            PoqNetworkService(networkTaskDelegate: self).saveAddressToOrder(String(orderId), postAddress: postAddress)
        }
        
        // I will just comment it, since no reason to do it. Address or saved, or in case of the same as billing, can't be saved at all
        // PoqNetworkService(networkTaskDelegate: self).saveUserAddress(address)
    }
    
    open func getHeight(_ indexPath: IndexPath) -> CGFloat {
        switch content[indexPath.row].cellType {
        case CheckoutAddressLabelNames.Title, CheckoutAddressLabelNames.SameAsBilling:
            return content[indexPath.row].height
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func getNumberOfRows() -> Int {
        return content.count
    }
    
    func getCellForRow(_ tableView: UITableView, indexPath: IndexPath, delegate: ChooseSameAddressDelegate) -> UITableViewCell {
        
        switch content[indexPath.row].cellType {
        case CheckoutAddressLabelNames.Title:
            return getPoqTitleBlock(tableView, indexPath: indexPath, title: AddressHelper.getTitle(addressType))
        case CheckoutAddressLabelNames.SameAsBilling:
            return getUISwitchCell(tableView, indexPath: indexPath, delegate: delegate)
        default:
            return getCellForAddress(tableView, indexPath: indexPath)
        }
    }
    
    open func getCellForAddress(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: addressIdentifier)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = getFullAddress(content[indexPath.row].address)
        cell.textLabel?.font = AppTheme.sharedInstance.checkoutOrderSummeryTotalLabelFont
        cell.sizeToFit()
        return cell
    }
    
    open func getUISwitchCell(_ tableView: UITableView, indexPath: IndexPath, delegate: ChooseSameAddressDelegate) -> UITableViewCell {
        
        let cell: CheckoutSameAddressTableViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.setUp(.billing, sameAddressdelegate: delegate, titleText: AppLocalization.sharedInstance.sameAsAddressLabelText)
        return cell
    }
    
    func changeUISiwtchCellValue(_ tableView: UITableView, indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CheckoutSameAddressTableViewCell {
            cell.setUpSwitch(true)
        }
    }
    fileprivate func getFullAddress(_ address: PoqAddress) -> String {
        var fullAddress = ""
        if let address1 = address.address1 {
            fullAddress += address1
        }
        if let address2 = address.address2 {
            fullAddress += ", \(address2)"
        }
        if let city = address.city {
            fullAddress += "\n\(city)"
        }
        if let postCode = address.postCode {
            fullAddress += ", \(postCode)"
        }
        if let country = address.country {
            fullAddress += "\n\(country)"
        }
        return fullAddress
    }
}
