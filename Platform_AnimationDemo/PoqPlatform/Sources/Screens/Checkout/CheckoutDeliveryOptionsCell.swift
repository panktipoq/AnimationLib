//
//  CheckoutDeliveryOptionsCell.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 29/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation

open class CheckoutDeliveryOptionsCell: UITableViewCell {
    
    public static let ReuseIdentifier:String = "CheckoutDeliveryOptionsCell"
    public static let XibName:String = "CheckoutDeliveryOptionsCell"
    
    @IBOutlet open weak var titleLabel: UILabel!{
        didSet{
            titleLabel.font = AppTheme.sharedInstance.checkoutDeliveryOptionsTitleFont
        }
    }
    @IBOutlet open weak var priceLabel: UILabel!
        {
        didSet{
            priceLabel.font = AppTheme.sharedInstance.checkoutDeliveryOptionsPriceFont
        }
    }
    
        
}
