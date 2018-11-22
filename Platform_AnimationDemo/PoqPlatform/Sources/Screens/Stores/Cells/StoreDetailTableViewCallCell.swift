//
//  StoreDetailTableViewCallCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 02/09/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import PoqNetworking
import UIKit

protocol StoreDetailTableViewCallButtonClickDelegate: AnyObject {
    
    func callButtonClicked()
}

open class StoreDetailTableViewCallCell: UITableViewCell, CallButtonDelegate {
    
    // MARK: - Class attributes
    // _____________________________
    
    // Custom view XIB, Identifier and custom Height

    static let CellXib: String = "StoreDetailTableViewCallCellView"
    public static let CellHeight = CGFloat(AppSettings.sharedInstance.storeDetailCallCellHeight)
    
    // Send call button click delegate to viewModel
    weak var callButtonClickDelegate: StoreDetailTableViewCallButtonClickDelegate?
    
    // MARK: - IBOutlets
    // _____________________________
    
    @IBOutlet public weak var callButtonView: CallButton?
    
    open func setCallButton(_ store: PoqStore) {
        callButtonView?.setTitle(getDeviceSpecificStorePhone(getStorePhone(store)), for: .normal)
    }

    @IBAction public func callButtonClicked(_ sender: Any?) {
        callButtonClickDelegate?.callButtonClicked()
    }
    
    public func getStorePhone(_ store: PoqStore) -> String {
        
        if let phone = store.phone {
            
            return phone
        } else {
            
            return ""
        }
    }
    
    public func getDeviceSpecificStorePhone(_ phone: String) -> String {
        
        if (DeviceType.IS_IPAD) {
            
            return "\(AppLocalization.sharedInstance.getNumberForCallStore) \(phone)"
        } else {
            return "\(AppLocalization.sharedInstance.callStoreText) \(phone)"
        }
    }
    
}
