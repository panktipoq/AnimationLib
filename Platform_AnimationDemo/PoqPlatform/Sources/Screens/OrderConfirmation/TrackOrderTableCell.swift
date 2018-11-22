//
//  TrackOrderTableCell.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 10/25/16.
//
//

import PoqNetworking
import UIKit

open class TrackOrderTableCell: UITableViewCell {

    // MARK: - Variables

    var trackingUrl: String?
    
    @IBOutlet var trackButton: UIButton? {
        didSet {
            trackButton?.titleLabel?.font = AppTheme.sharedInstance.trackOrderButtonLabelFont
        }
    }
    
    @IBAction func trackButtonClicked(_ sender: AnyObject) {
        guard let trackingUrlUnwrapped = trackingUrl else {
            return
        }
        
        NavigationHelper.sharedInstance.openURL(trackingUrlUnwrapped)
    }
}

// MARK: OrderConfirmationCell
extension TrackOrderTableCell: OrderConfirmationCell {
    public func updateUI<OrderItemType>(_ item: OrderConfirmationItem, order: PoqOrder<OrderItemType>) {
        trackingUrl = order.trackingUrl
    }
}
