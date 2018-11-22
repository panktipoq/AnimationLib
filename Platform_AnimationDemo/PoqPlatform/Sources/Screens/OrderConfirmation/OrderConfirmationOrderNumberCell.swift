//
//  OrderConfirmationOrderNumberCell.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/23/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import PoqNetworking
import UIKit

open class OrderConfirmationOrderNumberCell: UITableViewCell {

    public static let XibName:String = "OrderConfirmationOrderNumberCell"
    
    @IBOutlet open weak var orderNumberLabel: UILabel?
    @IBOutlet open weak var orderDateLabel: UILabel?
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        orderNumberLabel?.font = AppTheme.sharedInstance.checkoutConfirmationOrderNumberFont
        orderNumberLabel?.textColor  = AppTheme.sharedInstance.confirmationBlackColor
        
        orderDateLabel?.font = AppTheme.sharedInstance.checkoutConfirmationOrderDateFont
        orderDateLabel?.textColor = AppTheme.sharedInstance.confirmationGrayColor
    }
}


extension OrderConfirmationOrderNumberCell: OrderConfirmationCell {
    
    public func updateUI<OrderItemType>(_ item: OrderConfirmationItem, order: PoqOrder<OrderItemType>) {
        
        guard let externalOrderNumber = order.externalOrderId else {
            return
        }
        
        orderNumberLabel?.text = String(format: AppLocalization.sharedInstance.checkoutOrderConfirmationNumber, externalOrderNumber)
        
        orderDateLabel?.text = order.orderDate

    }
    
}
