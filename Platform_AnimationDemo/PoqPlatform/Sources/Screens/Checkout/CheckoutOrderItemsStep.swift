//
//  CheckoutOrderItemsStep.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 13/07/2016.
//
//

import Foundation
import PoqNetworking

open class CheckoutOrderItemsStep<CFC: CheckoutFlowController>: CheckoutFlowStep<CFC> {
    
    public var stepNumber: Int?
    
    open override var checkoutStep: CheckoutStep {
        return .orderItems
    }
    
    weak public var tableViewOwner: CheckoutTableViewOwner?
    
    public var checkoutItem: CheckoutItemType?
    
    public var bagItems: [BagItemType] {
        return checkoutItem?.bagItems ?? []
    }
    
    /// Top sec in section is accordion, we can open hide detail of order and left only overview
    public var detailCellsCollapsed: Bool = false
    
    open override var status: StepStatus {
        return .completed
    }

    open override func update(_ checkoutItem: CheckoutItemType) {
        self.checkoutItem = checkoutItem
        
        detailCellsCollapsed = AppSettings.sharedInstance.minimumBagItemsCountForAccordionView < Double(bagItems.count)
    }

    open override func populateCheckoutItem(_ checkoutItem: CheckoutItemType) {
        // we really need nothing to fill, since this infor server generated. User select nothing here
    }
}

extension CheckoutOrderItemsStep: TableCheckoutFlowStep {
    
    public func registerReuseViews(_ tableView: UITableView?) {
        
        tableView?.registerPoqCells(cellClasses: [CheckoutBagItemsCell.self])
    }
    
    public func numberOfCellInOverviewSection() -> Int {
        let itemsCount = bagItems.count
        guard !detailCellsCollapsed else {
            return (itemsCount > 0 ? 1 : 0)
        }
        // TODO: we really need here some items, otherwise we wont even show total. Find the way to handle 0 items
        
        return itemsCount > 0 ? itemsCount + 1 : 0
    }
    
    public func overviewCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int) -> UITableViewCell {
        
        if cellIndex == 0 {
            return itemsSummaryCell(tableView, atIndexPath: indexPath)
        }
        
        let index: Int = cellIndex - 1
        guard index < bagItems.count else {
            
            return UITableViewCell()
        }
        
        let cell: CheckoutBagItemsCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        let bagItem = bagItems[index]

        guard let title = bagItem.product?.title, let price = bagItem.priceOfOneItem, let quantity = bagItem.quantity else {
            
            return UITableViewCell()
        }
        
        let bagProductTitle: String?
        if let product = bagItem.product {
            let size = CheckoutHelper.getProductSize(bagItem.productSizeId, product: product)
            bagProductTitle = String(format: AppLocalization.sharedInstance.checkoutOrderSummaryBagItemFormat, title, size)
        } else {
            bagProductTitle = nil
        }
        
        cell.titleLabel.text = bagProductTitle
        cell.qtyLabel.text = "\(quantity) x "
        cell.priceLabel.text = price.toPriceString()
        
        cell.isUserInteractionEnabled = false
        
        // show top line for first row
        // show bottom line for last row
        cell.setUp(bagItem.product?.thumbnailUrl, rowIndex: index, totalCount: bagItems.count)
        
        if tableView.separatorStyle != UITableViewCellSeparatorStyle.none {
            //if table view has already got this separator single line
            //then change both lines to white
            cell.hideSeparators()
        }
        
        cell.accessibilityIdentifier = AccessibilityLabels.checkoutProductCell
        
        return cell
    }
    
    public func overviewCellSelected(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int) {
        
        guard cellIndex == 0 else {
            
            return
        }
        
        // from hre forget about cellIndex, is is 0
        
        detailCellsCollapsed = !detailCellsCollapsed
        
        let firstProductCellIndex = indexPath.row + 1
        
        let indexPaths: [IndexPath] = bagItems.enumerated().map { (pair: (index: Int, element: BagItemType)) -> IndexPath in
            return IndexPath(row: firstProductCellIndex + pair.index, section: indexPath.section)
        }
        
        let cell: AccordionTableViewCell? = tableView.cellForRow(at: indexPath) as? AccordionTableViewCell
        
        tableView.beginUpdates()
        if detailCellsCollapsed {
            tableView.deleteRows(at: indexPaths, with: UITableViewRowAnimation.fade)
            cell?.setClose(animated: true)
        } else {
            tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.fade)
            cell?.setOpen(animated: true)
        }
        
        tableViewOwner?.stepDidUpdateOverviewSection(self)
        tableView.endUpdates()
    }
}

// MARK: hidden
extension CheckoutOrderItemsStep {
    
    fileprivate final func itemsSummaryCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CheckoutOrderSummaryTotalBagItemsCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        let totalItems = CheckoutHelper.getNumberOfBagItems(bagItems)
        cell.totalLabel?.text = "\(totalItems) Item" + (totalItems != 1 ? "s" : "")
        
        if detailCellsCollapsed {
            cell.setClose(animated: false)
        } else {
            cell.setOpen(animated: false)
        }
        
        if let subtotalPrice = checkoutItem?.subTotalPrice {
            cell.totalPriceLabel?.text = subtotalPrice.toPriceString()
        }
        
        return cell
    }
}
