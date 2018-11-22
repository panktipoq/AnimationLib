//
//  OrderDetailGiftViewCell.swift
//  Poq.iOS
//
//  Created by Jun Seki on 10/04/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import UIKit

/// Instantiate a cell to show a gift message of an Order.
open class OrderDetailGiftViewCell: UITableViewCell {

    // MARK: - Variables

    //TODO-GABI optional UILabel?

    @IBOutlet weak var giftMessageTitleLabel: UILabel!
    @IBOutlet weak var giftMessageLabel: UILabel!

    // MARK: - AwakeFromNib

    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        //TODO-GABI move to didSet on each object

        giftMessageTitleLabel.text = AppLocalization.sharedInstance.orderGiftMessageText
        giftMessageTitleLabel.font = AppTheme.sharedInstance.giftMessageTitleLabelFont
        giftMessageTitleLabel.textColor = AppTheme.sharedInstance.giftMessageTitleLabelColor

        giftMessageLabel.font = AppTheme.sharedInstance.giftMessageLabelFont
        giftMessageLabel.textColor = AppTheme.sharedInstance.giftMessageLabelColor
    }

    // MARK: - Setup

    open func setUpData(_ giftMessage: String?) {
        if let message = giftMessage {
            giftMessageLabel.text = String(format:"\"%@\"", message)
            giftMessageLabel.sizeToFit()
        }
    }

}
