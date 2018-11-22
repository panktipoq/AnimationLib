//
//  OrderConfirmationEmailTableViewCell.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/23/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import PoqNetworking
import UIKit

open class OrderConfirmationEmailTableViewCell: UITableViewCell {
    
    @IBOutlet open weak var sendMessageLabel: UILabel!{
        didSet{
            sendMessageLabel.font = AppTheme.sharedInstance.checkoutConfirmationSendMessageLabelFont
            sendMessageLabel.text = AppLocalization.sharedInstance.orderConfirmationSendMessage
        }
    }
    @IBOutlet open weak var emailLabel: UILabel!{
        didSet{
            emailLabel.text = LoginHelper.getAccounDetails()?.email
            emailLabel.font = AppTheme.sharedInstance.checkoutConfirmationEmailLabelFont
        }
    }
}
