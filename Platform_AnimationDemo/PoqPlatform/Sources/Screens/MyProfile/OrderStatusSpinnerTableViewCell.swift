//
//  OrderStatusSpinnerTableViewCell.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 12/12/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import PoqNetworking
import UIKit

open class OrderStatusSpinnerTableViewCell: UITableViewCell {

    public static let RowHeight: CGFloat = 120
    public static let RowHeightWithoutSpinner: CGFloat = 50

   
    @IBOutlet open weak var spinner: PoqSpinner? {
        didSet {
            
            
            if !AppSettings.sharedInstance.shouldShowOrderSpinner {
                spinner?.stopAnimating()
                spinner?.removeFromSuperview()
            } else {
                spinner?.tintColor = AppTheme.sharedInstance.mainColor
                spinner?.startAnimating()
            }
        }
    }
    @IBOutlet open weak var orderStatusCell: UILabel! {
        didSet {
            orderStatusCell.font = AppTheme.sharedInstance.orderDetailStatusFont
            orderStatusCell.textColor = AppTheme.sharedInstance.orderDetailStatusTextColor
        }
    }
 
    open func setUpStatus(_ orderStatus: String?) {
        if let orderStatusMessage = orderStatus {
            OrderStatusHelper.setUpControls(orderStatusMessage, colorView: UIView(), label: orderStatusCell)
            orderStatusCell.text = String(format: AppLocalization.sharedInstance.orderStatusText, orderStatusMessage.lowercased())
            
            if OrderStatusHelper.checkOrderActioned(orderStatusMessage), let realSpinner = spinner{
                realSpinner.stopAnimating()
                realSpinner.removeFromSuperview()
            }
        }
    }
    
    
    
}

//MARK: OrderConfirmationCell
extension OrderStatusSpinnerTableViewCell: OrderConfirmationCell {
    open func updateUI<OrderItem>(_ item: OrderConfirmationItem, order: PoqOrder<OrderItem>) {
        setUpStatus(order.orderStatus)
    }
}
