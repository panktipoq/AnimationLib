//
//  OrderConfirmationSectionHeader.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 9/26/16.
//
//

import PoqNetworking
import UIKit

class OrderConfirmationSectionHeader: UITableViewCell {
    
    static let XibName: String = "OrderConfirmationSectionHeader"

    @IBOutlet weak var sectionTitleLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        sectionTitleLabel?.textColor = AppTheme.sharedInstance.mainColor
    }
    
}

extension OrderConfirmationSectionHeader: OrderConfirmationCell {

    func updateUI<OrderItemType>(_ item: OrderConfirmationItem, order: PoqOrder<OrderItemType>) {
        sectionTitleLabel?.text = item.text
    }

}

