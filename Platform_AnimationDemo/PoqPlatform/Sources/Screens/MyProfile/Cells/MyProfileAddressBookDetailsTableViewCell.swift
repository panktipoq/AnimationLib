//
//  MyProfileAddressBookDetailsTableViewCell.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/11/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import PoqNetworking
import UIKit


open class MyProfileAddressBookDetailsTableViewCell: UITableViewCell {

    public static let RowHeight: CGFloat = 130
    
    @IBOutlet open weak var addressNameLabel: UILabel?
    @IBOutlet open weak var addressLabel: UILabel?
    @IBOutlet open weak var addressTypeLabel: UILabel?
    @IBOutlet open weak var viewAmendButton: WhiteButton? {
        didSet {
            viewAmendButton?.setTitle(AppLocalization.sharedInstance.viewAmendButtonText, for: .normal)
            viewAmendButton?.fontSize = CGFloat(AppSettings.sharedInstance.viewAmendButtonTextFontSize)
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = UITableViewCellSelectionStyle.none
        
        self.addressLabel?.font = AppTheme.sharedInstance.myProfileAddressBookDetailsTextFont
        self.addressTypeLabel?.font = AppTheme.sharedInstance.myProfileAddressBookTypeTextFont
        self.addressNameLabel?.font = AppTheme.sharedInstance.myProfileAddressBookNameTextFont
    }
    
    open func setUp(_ address: PoqAddress) {
        
        if let addressName = address.addressName, !addressName.isEmpty {
            
            addressNameLabel?.text = addressName
            
        } else {
            
            addressNameLabel?.text = nil
        }

        addressLabel?.text = AddressHelper.createFullAddress(address)
        
        updateAddressTypeLabel(address)
        
        viewAmendButton?.isHidden = !AppSettings.sharedInstance.isMyProfileEditAddressEnabled
    }
    
    open func updateAddressTypeLabel(_ address: PoqAddress) {
        
        if let isDefaultBilling = address.isDefaultBilling, let isDefaultShipping = address.isDefaultShipping, isDefaultBilling && isDefaultShipping {
            
            addressTypeLabel?.text = AppLocalization.sharedInstance.primaryBillingAddressTitle + ", " + AppLocalization.sharedInstance.primaryDeliveryAddressTitle
            
        } else if let isDefaultShipping = address.isDefaultShipping, isDefaultShipping {
            
            addressTypeLabel?.text = AppLocalization.sharedInstance.primaryDeliveryAddressTitle
            
        } else if let isDefaultBilling = address.isDefaultBilling, isDefaultBilling {
            
            addressTypeLabel?.text = AppLocalization.sharedInstance.primaryBillingAddressTitle
            
        } else {
            
            addressTypeLabel?.text = nil
        }
        
    }

}
