//
//  CheckoutFlow.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 12/07/2016.
//
//

import Foundation
import PoqNetworking
import UIKit

public enum CheckoutStep {
    case billingAddress
    case deliveryMethod
    case orderItems
    case paymentMethod
    case shippingAddress
    case totalPrice
    case voucher
}

public enum CheckoutFlowCanPresentResult {
    case ok
    case cannotPresent(errorMessage: String)
}

public enum StepStatus {
    case completed
    case notCompleted(message: String) // Message will be presented to user
}

/// Basic description of flow controller. First flow is a table, where each step is a cell
/// Later we can introduce other flow, like Amazon one, for example
public protocol CheckoutFlowController: AnyObject {
    
    associatedtype CheckoutItemType: CheckoutItem
    associatedtype OrderItemType: OrderItem where OrderItemType: BagItemConvertable, CheckoutItemType.BagItemType == OrderItemType.BagItemType 

    typealias CheckoutFlowStepType = CheckoutFlowStep<Self>

    /// A lot of other steps need to use address steps
    func addressStep(_ type: AddressType) -> AddressCheckoutStep?
    
    func presentStepDetail(_ step: CheckoutFlowStepType, viewController: PoqBaseViewController, modal: Bool)
    
    func stepDidUpdateInformation(_ step: CheckoutFlowStepType)
}

/// Ideally `CheckoutFlowStep` should be a protocol with 'associatedtype CheckoutItemType: CheckoutItem'
/// But we can't create 'Array<CheckoutFlowStep> where CheckoutFlowStep.CheckoutItemType == PoqChecoutItem'
/// Swift let us down here, so we have to make a class to declare all needed API
/// Subclasses must not call super, all functions/vars must be overriden
open class CheckoutFlowStep<CFC: CheckoutFlowController> {
    
    public typealias BagItemType = CheckoutItemType.BagItemType
    public typealias CheckoutItemType = CFC.CheckoutItemType
    public typealias CheckoutFlowControllerType = CFC

    /// Define specific step type for later usage
    open var checkoutStep: CheckoutStep {
        fatalError("Subclass must override")
    }
    
    /// If user provide all needed info will be '.completed'. 
    /// Otehwise '.notCompleted' with information about missed info.
    open var status: StepStatus {
        fatalError("Subclass must override")
    }
    
    public init() {
    }
    
    weak public var flowController: CheckoutFlowControllerType?
    
    /// Update values with updated checkoutItem, will be called eachtim whne we got such response from API
    open func update(_ checkoutItem: CheckoutItemType) {
    }
    
    /// In some cases we cen't present some step until prev collect enough information
    /// For example, there is no sense navigate to delivery options if there is no delivery address
    open func canFlowPresentsStep(_ step: CheckoutStep) -> CheckoutFlowCanPresentResult {
        return .ok
    }
    
    /// Final part of step: opulate checkout item with user selected detail
    open func populateCheckoutItem(_ checkoutItem: CheckoutItemType) {
        fatalError("Subclass must override")
    }
}

// MARK: - Table based overview flow

public protocol CheckoutTableViewOwner: AnyObject {
    /// Trigger remaking sections, must be called when we update number of cells
    func stepDidUpdateOverviewSection(_ step: TableCheckoutFlowStep)
}

/// Flow where each step presented as a section in UITableView and navigation based on open detail of step and pop back
public protocol TableCheckoutFlowStep: AnyObject {
    
    /// This should be weak.
    var tableViewOwner: CheckoutTableViewOwner? { get  set }
    // We need this for UI rendering of stap number
    var stepNumber: Int? { get set }
    /// Pre-render step, for every step we need present specific UITableView cell
    func registerReuseViews(_ tableView: UITableView?)
    func numberOfCellInOverviewSection() -> Int
    /// Path full index path for fully support of deque. cellIndex in 0..<numberOfCellInOverviewSection()
    func overviewCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int) -> UITableViewCell
    /// Path full index path for fully support of deque. cellIndex in 0..<numberOfCellInOverviewSection()
    func overviewCellSelected(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int)
}

extension TableCheckoutFlowStep {
    
    public func registerReuseViews(_ tableView: UITableView?) {
    }
    
    public func overviewCellSelected(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int) {
    }
}
 
// There is no garantee that checkoutStep value of step is  .BillingAddress or .DeliveryMethod
// But this step contain information about on of address. For example, payment step may contain info about AddressType.Billing 
public protocol AddressCheckoutStep: AnyObject {
    
    var addressType: AddressType { get }
    var address: PoqAddress? { get }
}

public protocol TableCheckoutFlowStepOverViewCell {
    static var reuseIdentifier: String { get }
    static var nibName: String { get }
}

extension TableCheckoutFlowStep where Self: CheckoutStep3LinePresentation {
    /// Default implementation for configuring v2 step cells
    public func configureCheckoutStepCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CheckoutStepCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.update(self)
        
        return cell
    }
}
