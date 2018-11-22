//
//  OrderConfirmationTitleCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 9/23/16.
//
//

import PoqNetworking
import UIKit

open class OrderConfirmationTitleCell: UITableViewCell, OrderConfirmationCell {
    
    static let XibName: String = "OrderConfirmationTitleCell"
    
    @IBOutlet public weak var titleLabel: UILabel?

    @IBOutlet public weak var emailLabel: UILabel?

    open func setup<OrderItemType>(with item: OrderConfirmationItem, order: PoqOrder<OrderItemType>) {
       
        let title = AppLocalization.sharedInstance.orderConfirmationTitleCellText
        // TODO: find on which screen and which situation we should show it
        //        If let externalOrderId = order.externalOrderId {
        //            Title = AppLocalization.sharedInstance.orderConfirmationPageOrderIDTitleText + externalOrderId
        //        }
        
        titleLabel?.text = title

        if let email: String = order.email {

            let emailMessageString: String = NSString(format: AppLocalization.sharedInstance.orderConfirmationTitleCellMessageFormat as NSString, email) as String
            let attributedString = NSMutableAttributedString(string: emailMessageString, attributes: [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.confirmationGrayColor])
            
            // Apply other color for email
            let emailRange = (emailMessageString as NSString).range(of: email)
            if emailRange.location != NSNotFound {
                
                let attributes = [NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.mainColor,
                                  NSAttributedStringKey.font: AppTheme.sharedInstance.confirmationOrderAddressTypeFont]
                
                attributedString.addAttributes(attributes, range: emailRange)
            }

            emailLabel?.attributedText = attributedString
        } else {
            emailLabel?.text = ""
        }
    }
    
    // MARK: - OrderConfirmationCell
    
    /// Update cell UI with email. If pass externalOrderId - it will be attached to title
    public func updateUI<OrderItemType>(_ item: OrderConfirmationItem, order: PoqOrder<OrderItemType>) {
        setup(with: item, order: order)
    }
}
