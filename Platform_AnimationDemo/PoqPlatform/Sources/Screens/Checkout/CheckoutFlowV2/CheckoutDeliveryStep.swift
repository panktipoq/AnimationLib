//
//  CheckoutDeliveryStep.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 15/07/2016.
//
//

import Foundation
import PoqNetworking
import PoqNetworking

open class CheckoutDeliveryStep<CFC: CheckoutFlowController>: CheckoutFlowStep<CFC>, TableCheckoutFlowStep, CheckoutStep3LinePresentation, DeliveryMethodSelectionDelegate {

    // CheckoutFlowController
    
    public var stepNumber: Int?
    
    public var deliveryOption: PoqDeliveryOption?
    
    open override var checkoutStep: CheckoutStep {
        return .deliveryMethod
    }
    
    weak public var tableViewOwner: CheckoutTableViewOwner?
    
    // MARK: CheckoutFlowStep
    open override  var status: StepStatus {
        if deliveryOption?.code != nil || deliveryOption?.id != nil {
            return .completed
        }
        
        return .notCompleted(message: AppLocalization.sharedInstance.checkoutSelectDeliveryMethodMessage)
    }
    
    open override func update(_ checkoutItem: CheckoutItemType) {
        deliveryOption = checkoutItem.deliveryOption
    }
    
    open override func populateCheckoutItem(_ checkoutItem: CheckoutItemType) {
        checkoutItem.deliveryOption = deliveryOption
    }
    
    // MARK: TableCheckoutFlowStep
    public func registerReuseViews(_ tableView: UITableView?) {
        
        tableView?.registerPoqCells(cellClasses: [CheckoutOrderSummaryCell.self])
    }
    
    public func numberOfCellInOverviewSection() -> Int {
        return 1
    }
    
    public func overviewCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int) -> UITableViewCell {
        
        let cell = configureCheckoutStepCell(tableView, atIndexPath: indexPath)
        
        cell.accessibilityIdentifier = AccessibilityLabels.deliveryOptionCell
        cell.createAccessoryView()
        
        return cell
    }
    
    open func overviewCellSelected(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int) {

        guard let deliveryStep: AddressCheckoutStep = flowController?.addressStep(.Delivery), let deliveryAddress: PoqAddress = deliveryStep.address else {
            return
        }

        let deliveryOptions = CheckoutDeliveryOptionsViewController(nibName: CheckoutDeliveryOptionsViewController.XibName, bundle: nil)
        deliveryOptions.deliveryAddress = deliveryAddress
        deliveryOptions.delegate = self
        
        flowController?.presentStepDetail(self, viewController: deliveryOptions, modal: false)
    }
    
    /// CheckoutStep3LinePresentation
    /// We have 3 different styles of label,they depends on which line this label is. May be used only one this line
    open var firstLine: String? {
        return "CHECKOUT_DELIVERY_OPTIONS_STEP_FIRST_LINE".localizedPoqString
    }
    
    open var secondLine: String? {
        return nil
    }
    
    open var thirdLine: String? {
        guard let validDeliveryOption = deliveryOption else {
            return AppLocalization.sharedInstance.checkoutOrderSummarySelectDeliveryOptions
        }
        
        return validDeliveryOption.title
    }
    
    open var rightDetailText: String? {
        guard let price = deliveryOption?.price else {
            return nil
        }
        
        return LabelStyleHelper.showFreeForPriceZero(price)
    }
    
    // MARK: DeliveryMethodSelectionDelegate
    public func didSelect(_ deliveryMethod: PoqDeliveryOption) {
        flowController?.stepDidUpdateInformation(self)
    }
}

// MARK: Private

extension CheckoutDeliveryStep {
    
    fileprivate final func configureCheckoutOrderSummaryCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CheckoutOrderSummaryCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        guard let addressStep: AddressCheckoutStep = flowController?.addressStep(.Delivery) else {
            let resCell = UITableViewCell()
            resCell.selectionStyle = .none
            return resCell
        }
        
        var subtitle: String = AppLocalization.sharedInstance.checkoutOrderSummaryDeliveryOptions
        var content: String = ""
        
        var deliveryPrice: Double?
        
        // TODO: prev implemention checned tha country really exists in address - do we need it?
        if addressStep.address != nil {
            // enable selection
            
            if let price = deliveryOption?.price, let title = deliveryOption?.title {
                
                //after user selection: set up selection with prices
                content = title
                deliveryPrice = price
            } else {
                subtitle = ""
                content = AppLocalization.sharedInstance.checkoutOrderSummarySelectDeliveryOptions
            }
            
            cell.createAccessoryView()
            cell.selectionStyle = .default
            cell.isUserInteractionEnabled = true
            
        } else {
            cell.isUserInteractionEnabled = false
            cell.accessoryView = nil
            cell.selectionStyle = .none
        }
        
        cell.setupUI(subtitle, contentDetail: content, price: deliveryPrice)
        
        return cell
    }
}
