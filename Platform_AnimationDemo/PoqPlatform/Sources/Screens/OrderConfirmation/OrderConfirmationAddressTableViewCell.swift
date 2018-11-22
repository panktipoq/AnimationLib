//
//  OrderConfirmationAddressTableViewCell.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/23/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import PoqNetworking
import UIKit

class OrderConfirmationAddressTableViewCell: UITableViewCell {

    static let XibName: String = "OrderConfirmationAddressTableViewCell"

    @IBOutlet weak var addressTypeLabel: UILabel?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    
    @IBOutlet weak var nameAddressSpace: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addressTypeLabel?.textColor = AppTheme.sharedInstance.mainColor
        addressTypeLabel?.font = AppTheme.sharedInstance.confirmationOrderAddressTypeFont
        
        nameLabel?.font = AppTheme.sharedInstance.confirmationOrderNameFont
        nameLabel?.textColor =  AppTheme.sharedInstance.confirmationBlackColor
        
        addressLabel?.font = AppTheme.sharedInstance.confirmationOrderAddressFont
        addressLabel?.textColor =  AppTheme.sharedInstance.confirmationGrayColor
    }
}

extension OrderConfirmationAddressTableViewCell: OrderConfirmationCell {
    func updateUI<OrderItem>(_ item: OrderConfirmationItem, order: PoqOrder<OrderItem>) {
        let addressType: String
        let address: PoqAddress?
        
        if item.itemType == .billing {
            address = order.address(forType: .Billing)
            addressType = AppLocalization.sharedInstance.billingAddressOrderStatusTitle
        } else {
            // assume .Shipping case
            address = order.address(forType: .Delivery)
            addressType = AppLocalization.sharedInstance.deliveryAddressOrderStatusTitle
        }
        
        addressTypeLabel?.text = addressType
        
        nameLabel?.text = String.combineComponents([address?.firstName, address?.lastName], separator: " ")
        
        let line2: String? = String.combineComponents([address?.address1, address?.address2], separator: ", ")
        
        let line3: String? = String.combineComponents( [address?.city, address?.postCode, address?.country], separator: ", ")

        addressLabel?.text = String.combineComponents([line2, line3], separator: "\n")
        
        if addressLabel?.text == nil || nameLabel?.text == nil {
            nameAddressSpace?.constant = 0
        }
    }
    
}
