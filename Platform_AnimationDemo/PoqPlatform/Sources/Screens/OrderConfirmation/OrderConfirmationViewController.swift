//
//  OrderConfirmationViewController.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/23/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import PoqModuling
import PoqNetworking
import PoqUtilities
import StoreKit
import UIKit

public protocol OrderConfirmationCell {
    func updateUI<OrderItemType>(_ item: OrderConfirmationItem, order: PoqOrder<OrderItemType>)
}

open class OrderConfirmationViewController<OrderItemType: OrderItem>: PoqBaseViewController, UITableViewDelegate, UITableViewDataSource {

    public typealias OrderType = OrderConfirmationViewModel<OrderItemType>.OrderType

    override open var screenName: String {
        // Missguided is reusing the order summary screen for order history details page
        if AppSettings.sharedInstance.orderDetailViewType == OrderDetailViewType.missguided.rawValue {
            return "Order History Details Screen"
        }

        return "Checkout - Order Confirmation Screen"
    }

    open var isOrderConfirmationPage: Bool = true

    override open class var XibName: String { return "OrderConfirmationViewController" }

    @IBOutlet weak var orderConfirmationTableView: UITableView?

    @IBOutlet var separatorViews: [UIView]?
    @IBOutlet var separatorViewsHeights: [NSLayoutConstraint]?

    @IBOutlet weak var pricesInfoStackView: UIStackView?
    @IBOutlet weak var pricesInfoHeigth: NSLayoutConstraint?

    @IBOutlet weak var totalPaySeparatorView: UIView?
    @IBOutlet weak var totalPayTitleLabel: UILabel? {
        didSet {
            totalPayTitleLabel?.font = AppTheme.sharedInstance.confirmationOrderTotalPayLabelFont
            totalPayTitleLabel?.textColor  = AppTheme.sharedInstance.confirmationBlackColor
        }
    }
    @IBOutlet weak var totalPayValueLabel: UILabel? {
        didSet {
            totalPayValueLabel?.font = AppTheme.sharedInstance.confirmationOrderTotalPayValueFont
            totalPayValueLabel?.textColor  = AppTheme.sharedInstance.confirmationBlackColor
        }
    }

    @IBOutlet weak var continueShoppingButton: CheckoutButton?
    @IBOutlet weak var continueShoppingButtonHeight: NSLayoutConstraint?

    fileprivate lazy var viewModel: OrderConfirmationViewModel<OrderItemType> = {
        [unowned self] in
        return OrderConfirmationViewModel(extrenalOrderId: self.externalOrderId, viewControllerDelegate: self)
    }()

    public let orderKey: String?
    fileprivate let externalOrderId: String?
    fileprivate let order: OrderType?

    public init(orderKey: String, externalOrderId: String?) {
        self.orderKey = orderKey
        self.externalOrderId = externalOrderId
        self.order = nil

        super.init(nibName: OrderConfirmationViewController.XibName, bundle: nil)
    }

    public init(order: OrderType) {
        self.order = order
        self.externalOrderId = order.externalOrderId
        self.orderKey = order.orderKey

        super.init(nibName: OrderConfirmationViewController.XibName, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        orderConfirmationTableView?.rowHeight = UITableViewAutomaticDimension
        OrderConfirmationViewController.registerCells(withTableView: orderConfirmationTableView)

        continueShoppingButton?.setTitle(AppLocalization.sharedInstance.orderConfirmationContinueShoppingText, for: UIControlState())

        viewModel.viewControllerDelegate = self
        navigationItem.leftBarButtonItem = isOrderConfirmationPage ? NavigationBarHelper.setupCloseButton(self) : NavigationBarHelper.setupBackButton(self)
        navigationItem.rightBarButtonItem = nil

        if AppLocalization.sharedInstance.checkoutOrderConfirmationTitle.isEmpty == false {
            // set up navigation title
            self.navigationItem.title = AppLocalization.sharedInstance.checkoutOrderConfirmationTitle
            self.navigationItem.titleView = nil
        }

        viewModel.isOrderConfirmationPage = isOrderConfirmationPage

        if let validOrder = order {
            viewModel.order = validOrder

        } else if let validOrderKey = orderKey {
            viewModel.getOrderDetails(validOrderKey)
        }

        updateTotalsAndSubtotals(withOrder: viewModel.order)

        if !isOrderConfirmationPage {
            continueShoppingButtonHeight?.constant = 0
        }

        // separators
        for separatorView in (separatorViews ?? []) {
            separatorView.backgroundColor = orderConfirmationTableView?.separatorColor
        }

        for separatorViewHeight in (separatorViewsHeights ?? []) {
            separatorViewHeight.constant = 1.0/UIScreen.main.scale
        }

    }

    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        super.networkTaskDidComplete(networkTaskType)
        orderConfirmationTableView?.reloadData()
        updateTotalsAndSubtotals(withOrder: viewModel.order)
    }

    // close the view
    override open func closeButtonClicked() {
        dissmissViewAndClearBagItems()
        
        // once order is completed ask for a rating from the user
        SKStoreReviewController.requestReview()
    }

    @IBAction func continueShoppingButtonAction() {
        dissmissViewAndClearBagItems()
        
        // once order is completed ask for a rating from the user
        SKStoreReviewController.requestReview()
    }

    // MARK: - UITableViewDelegate Implementation
    // __________________________
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // honestly, just rando number
        return 60

    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // TODO: make it cinst and equal to height of empty cell height
        return 5.0
    }

    // MARK: - UITableViewDataSource Implementation
    // __________________________

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.content.count
        //return viewModel.getNumberOfRows()
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item: OrderConfirmationItem = viewModel.content[indexPath.row]

        guard let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: item.identifier),
                let existedOrder: PoqOrder =  viewModel.order else {
            Log.error("We can't get cell for identifuer \(item.identifier)")
            return UITableViewCell()
        }

        cell.separatorInset = UIEdgeInsets(top: 0, left: item.separatorIndent, bottom: 0, right: 0)

        if let checkoutConfirmationCell: OrderConfirmationCell = cell as? OrderConfirmationCell {
            checkoutConfirmationCell.updateUI(item, order: existedOrder)
        }

        return cell
    }

}

// MARK: Private
// __________________________

extension OrderConfirmationViewController {
    //continue shopping

    // Every time when we dissmiss the view we are sure that we set badge value to zero
    fileprivate func dissmissViewAndClearBagItems() {
        BadgeHelper.setBadge(for: Int(AppSettings.sharedInstance.shoppingBagTabIndex), value: 0)
        dismissNavigationThenPopToRoot()
    }

    fileprivate func dismissNavigationThenPopToRoot() {

        if let navigationController = self.navigationController {
            navigationController.dismiss(animated: true, completion: { () -> Void in
                navigationController.popToRootViewController(animated: true)

                if !AppSettings.sharedInstance.checkoutContinueShoppingDeepLink.isEmpty {
                    NavigationHelper.sharedInstance.openURL(AppSettings.sharedInstance.checkoutContinueShoppingDeepLink)
                }
            })
        }
    }

    fileprivate static func registerCells(withTableView tableView: UITableView?) {

        tableView?.registerPoqCells(cellClasses: [MyProfileAddressBookTitleTableViewCell.self,
            OrderConfirmationEmailTableViewCell.self,
            OrderConfirmationOrderNumberCell.self,
            OrderConfirmationAddressTableViewCell.self,
            OrderConfirmationSectionHeader.self,
            OrderConfirmationBagItemCell.self,
            OrderConfirmationEmtyCell.self,
            OrderConfirmationTitleCell.self,
            OrderStatusSpinnerTableViewCell.self,
            TrackOrderTableCell.self
            ])

    }

    fileprivate final func updateTotalsAndSubtotals(withOrder order: OrderType?) {

        totalPayTitleLabel?.text = AppLocalization.sharedInstance.orderConfirmationTotalPaidTitle
        totalPayValueLabel?.text = order?.totalPrice?.toPriceString()

        guard let stackView = pricesInfoStackView else {
            totalPaySeparatorView?.isHidden = true
            pricesInfoHeigth?.constant = 0

            return
        }

        totalPayTitleLabel?.isHidden = (order == nil)
        totalPayValueLabel?.isHidden = (order == nil)

        let prices: [Double?] = [order?.subtotalPrice, order?.voucherAmount, order?.deliveryCost]

        // FIXME: Localize
        let titles: [String] = ["Subtotal Order", "Discount", "Delivery Charges"]

        // remove subviews existed, just in casse

        for view in stackView.arrangedSubviews {
            pricesInfoStackView?.removeArrangedSubview(view)
        }

        for i in 0..<prices.count {
            guard let price: Double = prices[i] else {
                continue
            }

            guard let priceView: OrderConfirmationTitlePriceView = NibInjectionResolver.loadViewFromNib() else {
                Log.error("Unable to load nib OrderConfirmationTitlePriceView ")
                continue
            }

            priceView.titleLabel?.text = titles[i]
            priceView.priceValueLabel?.text = price.toPriceString()

            pricesInfoStackView?.addArrangedSubview(priceView)

        }

        pricesInfoHeigth?.constant = CGFloat(stackView.arrangedSubviews.count) * TitlePriceViewHeight
        totalPaySeparatorView?.isHidden = stackView.arrangedSubviews.count == 0

    }
}
