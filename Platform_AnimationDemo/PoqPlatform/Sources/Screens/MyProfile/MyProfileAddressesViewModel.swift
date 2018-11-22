//
//  MyProfileAddressesViewModel.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/18/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities

open class MyProfileAddressesViewModel: BaseViewModel, PoqTitleBlock {
    
    open var addresses: [PoqAddress] = []
    
    public override init() {
        super.init()
    }
    
    public override init(viewControllerDelegate: PoqBaseViewController) {
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        super.networkTaskWillStart(networkTaskType)

    }
    
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        super.networkTaskDidComplete(networkTaskType, result: result)
    
        if networkTaskType == PoqNetworkTaskType.getUserAddresses {
            
            if let networkResult = result as? [PoqAddress] {
                addresses = networkResult
                if networkResult.count > 0 {
                    checkForDuplicateAddresses()
                    if AppSettings.sharedInstance.addressTypeTitleEnabled {
                        addresses.insert(PoqAddress(), at: 0)
                    }
                }
            }
            
        } else if networkTaskType == PoqNetworkTaskType.deleteUserAddress {
            getAddresses()
        }

        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
        
    // if we make some address both billing and shipping the megento return to us two different addresses with same id and one of the is defaultShipping the other one is defaultBilling so we have to handle it and make it one address
    public func checkForDuplicateAddresses() {
        // In order to avoid running this meaningful method for Belk
        guard (addresses[0].externalAddressId ?? "").isEmpty else {
            return
        }
        
        if addresses.count > 2 && addresses[0].id == addresses[1].id {
            addresses.remove(at: 0)
            addresses[0].isDefaultShipping = true
            addresses[0].isDefaultBilling = true
        }
    }
    
    public func getAddresses() {
        PoqNetworkService(networkTaskDelegate: self).getUserAddresses(true)
    }
    
    public func deleteAddress(_ index: Int) {
        guard let addressId = addresses[index].id else {
            Log.error("Could not delete address because address ID could not be found")
            return
        }
        PoqNetworkService(networkTaskDelegate: self).deleteUserAddress(addressId)
        addresses.remove(at: index)
    }
    
    open func isEmpty() -> Bool {
        return addresses.count == 0
    }
    
    public func getRowHeight() -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    public func getTitleHeigh() -> CGFloat {
        return AppSettings.sharedInstance.checkoutAddressTableViewPoqTitleBlockHeight
    }
    
    public func getNumberOfRows() -> Int {
        return addresses.count
    }
    
    public func getCellForRow(_ tableView: UITableView, indexPath: IndexPath, whiteButtonDelegate: WhiteButtonDelegate) -> UITableViewCell {
        
        if hasTitle(indexPath) {
            return getPoqTitleBlock(tableView, indexPath: indexPath, title: AppLocalization.sharedInstance.myProfileAddressBookTitle)
        }
        return getDetailCell(tableView, indexPath: indexPath, whiteButtonDelegate: whiteButtonDelegate)
    }
    
    open func getDetailCell(_ tableView: UITableView, indexPath: IndexPath, whiteButtonDelegate: WhiteButtonDelegate) -> UITableViewCell {
        
        let cell: MyProfileAddressBookDetailsTableViewCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.viewAmendButton?.tag = indexPath.row
        cell.viewAmendButton?.addTarget(whiteButtonDelegate, action: #selector(whiteButtonDelegate.whiteButtonClicked(_:)), for: .touchUpInside)
        
        cell.setUp(addresses[indexPath.row])
        
        if AppSettings.sharedInstance.isMyProfileEditAddressEnabled {
            
            cell.createAccessoryView()
        }
        
        return cell
    }
    
    public func canEdit(_ indexPath: IndexPath) -> Bool {
        guard indexPath.row == 0 else {
            return true
        }
        return !AppSettings.sharedInstance.addressTypeTitleEnabled
    }
}
