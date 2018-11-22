//
//  OrderConfirmationViewModel.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/23/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import UIKit

enum OrderConfirmationItemType {
    case title
    case spinner
    case trackButton
    case orderNumber
    case empty
    case billing
    case delivery
    case summary
    case bagItem
}

public struct OrderConfirmationItem {
    let identifier: String
    
    /// It will help use remove idention around header
    /// We will set it to screen width - to hide it from screen, on bag items list, for example
    let separatorIndent: CGFloat
    
    /// order item for BagItemsIdentifier
    public let orderItem: OrderItem?
    
    public let text: String?
    
    let itemType: OrderConfirmationItemType
}

public class OrderConfirmationViewModel<OrderItemType: OrderItem>: BaseViewModel {
    
    public typealias OrderType = PoqOrder<OrderItemType>
    
    fileprivate let externalOrderId: String?
    
    var bagItemsStartPosition: Int = 0

    var order: OrderType? {
        didSet {
            setupContent()
        }
    }
    var isOrderConfirmationPage: Bool = true
    var orderStatus: String?
    
    var content = [OrderConfirmationItem]()

    override init() {
        externalOrderId = nil
        super.init()
        
    }
    
    init(extrenalOrderId: String?, viewControllerDelegate: PoqBaseViewController) {
        externalOrderId = nil
        super.init(viewControllerDelegate: viewControllerDelegate)
    }
    
    public override func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        super.networkTaskDidComplete(networkTaskType, result: result)
        if networkTaskType == PoqNetworkTaskType.getOrderSummary {
            
            if let networkResult = result as? [OrderType], networkResult.count > 0 {
                order = networkResult[0]
            }
        }
        
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }

    func setupContent() {
        
        content.removeAll()
        
        guard let existedOrder: PoqOrder = order else {
            return
        }

        let orderTitleItem = OrderConfirmationItem(identifier: OrderConfirmationTitleCell.poqReuseIdentifier, separatorIndent: 0, orderItem: nil, text: nil, itemType: .title)
        content.append(orderTitleItem)
        
        let orderSpinner = OrderConfirmationItem(identifier: OrderStatusSpinnerTableViewCell.poqReuseIdentifier, separatorIndent: 0, orderItem: nil, text: nil, itemType: .spinner)
        content.append(orderSpinner)
        
        if let _ = existedOrder.trackingUrl {
            let trackOrder = OrderConfirmationItem(identifier: TrackOrderTableCell.poqReuseIdentifier, separatorIndent: 0, orderItem: nil, text: nil, itemType: .trackButton)
            content.append(trackOrder)
        }
        
        let emptyHeaderItem = OrderConfirmationItem(identifier: OrderConfirmationEmtyCell.poqReuseIdentifier, separatorIndent: 0, orderItem: nil, text: nil, itemType: .empty)
        content.append(emptyHeaderItem)
        
        if let _ = existedOrder.externalOrderId {
            let orderNumberItem = OrderConfirmationItem(identifier: OrderConfirmationOrderNumberCell.poqReuseIdentifier, separatorIndent: 15, orderItem: nil, text: nil, itemType: .orderNumber)
            content.append(orderNumberItem)
        }

        if let _ = existedOrder.address(forType: .Billing) {
            let billingItem = OrderConfirmationItem(identifier: OrderConfirmationAddressTableViewCell.poqReuseIdentifier, separatorIndent: 15, orderItem: nil, text: nil, itemType: .billing)
            content.append(billingItem)
        }
        
        if let _ = existedOrder.address(forType: .Delivery) {
            let shippingItem = OrderConfirmationItem(identifier: OrderConfirmationAddressTableViewCell.poqReuseIdentifier, separatorIndent: 0, orderItem: nil, text: nil, itemType: .delivery)
            content.append(shippingItem)
        }
        
        // one more space before order detail
        content.append(emptyHeaderItem)
        
        let screenWidth: CGFloat = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        
        let sectionHeaderItem = OrderConfirmationItem(identifier: OrderConfirmationSectionHeader.poqReuseIdentifier, separatorIndent: screenWidth, orderItem: nil, text: AppLocalization.sharedInstance.orderConfirmationSummarySectionTitleText, itemType: .summary)
        content.append(sectionHeaderItem)
        
        if let orderItems = existedOrder.orderItems {
            for orderItem in orderItems {
                let orderItemElement = OrderConfirmationItem(identifier: OrderConfirmationBagItemCell.poqReuseIdentifier,
                                                             separatorIndent: screenWidth,
                                                             orderItem: orderItem,
                                                             text: nil,
                                                             itemType: .bagItem)
                content.append(orderItemElement)
            }
        }

    }

    func getOrderDetails(_ orderKey: String, isRefresh: Bool = false) {

        let service = PoqNetworkService(networkTaskDelegate: self)
        let _: PoqNetworkTask<JSONResponseParser<OrderType>> = service.getOrderSummary(orderKey, isRefresh:isRefresh)
    }
    
    func getCellForBagItemDetails(_ tableView: UITableView, indexPath: IndexPath, itemIndex: Int) -> UITableViewCell {
        guard let bagItems = order?.orderItems, bagItems.count > 0 && itemIndex < bagItems.count else {
            return UITableViewCell()
        }
        
        let cell: CheckoutBagItemsCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        let bagItem = bagItems[itemIndex]
        guard let title = bagItem.productTitle, let price = bagItem.price, let quantity = bagItem.quantity else {
            
            return UITableViewCell()
        }
        var bagProductTitle = title
        if let sizeName = bagItem.size {
            bagProductTitle = String(format: AppLocalization.sharedInstance.checkoutOrderSummaryBagItemFormat, title, sizeName)
        }
        
        cell.titleLabel.text = bagProductTitle
        cell.qtyLabel.text = "\(quantity) x "
        cell.priceLabel.text = price.toPriceString()
        
        cell.isUserInteractionEnabled = false
        
        //show top line for first row
        //show bottom line for last row
        cell.setUp(bagItem.productImageUrl, rowIndex: itemIndex, totalCount: bagItems.count)
        
        if tableView.separatorStyle != UITableViewCellSeparatorStyle.none {
            //if table view has already got this separator single line
            //then change both lines to white
            cell.hideSeparators()
        }
        
        return cell
        
    }
    
}
