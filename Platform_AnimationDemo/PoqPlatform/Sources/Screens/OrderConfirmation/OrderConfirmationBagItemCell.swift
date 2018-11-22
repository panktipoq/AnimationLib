//
//  OrderConfirmationBagItemCell.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 9/26/16.
//
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit

class OrderConfirmationBagItemCell: UITableViewCell {

    static let XibName: String = "OrderConfirmationBagItemCell"
    
    @IBOutlet weak var bagItemImage: PoqAsyncImageView?
    @IBOutlet weak var bagItemNameLabel: UILabel?
    @IBOutlet weak var bagItemCountLabel: UILabel?
    @IBOutlet weak var bagItemTotalPice: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        bagItemNameLabel?.font = AppTheme.sharedInstance.confirmationOrderProductNameFont
        bagItemNameLabel?.textColor = AppTheme.sharedInstance.confirmationBlackColor
        
        bagItemCountLabel?.font = AppTheme.sharedInstance.confirmationOrderProductQuantityFont
        bagItemCountLabel?.textColor = AppTheme.sharedInstance.confirmationGrayColor
        
        bagItemTotalPice?.font = AppTheme.sharedInstance.confirmationOrderProductPriceFont
        bagItemTotalPice?.textColor = AppTheme.sharedInstance.confirmationBlackColor
    }
}

extension OrderConfirmationBagItemCell: OrderConfirmationCell {
    func updateUI<OrderItemType>(_ item: OrderConfirmationItem, order: PoqOrder<OrderItemType>) {
        guard let orderItem = item.orderItem else {
            Log.error("How we can show order item without order item???")
            bagItemImage?.prepareForReuse()
            bagItemNameLabel?.text = nil
            bagItemCountLabel?.text = nil
            bagItemTotalPice?.text = nil
            return
        }
        if let urlString = orderItem.productImageUrl, let imageUrl = URL(string: urlString), !urlString.isEmpty {
            bagItemImage?.getImageFromURL(imageUrl, isAnimated: false, showLoadingIndicator: true, resetConstraints: false, completion: nil)
        } else {
            bagItemImage?.prepareForReuse()
        }
        
        if let quantity: Int = orderItem.quantity, let price: Double = orderItem.price {
            bagItemCountLabel?.text = "\(quantity) X \(price.toPriceString())"
        } else {
            bagItemCountLabel?.text = nil
        }
        
        if let price: Double = orderItem.price {
            bagItemTotalPice?.text = price.toPriceString()
        } else {
            bagItemTotalPice?.text = nil
        }
        
        guard let productTitle = orderItem.productTitle else {
            return
        }
        
        if let color = orderItem.color {
            bagItemNameLabel?.text = "\(productTitle) \(color)"
        } else {
            bagItemNameLabel?.text = orderItem.productTitle
            
        }
    }
}
