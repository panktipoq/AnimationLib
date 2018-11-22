//
//  CheckoutOrderSummaryViewController.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 21/10/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import PassKit
import Braintree
import PoqNetworking

final public class CheckoutOrderSummaryViewController<CI: CheckoutItem, OI: OrderItem>: PoqBaseViewController, UITableViewDataSource, UITableViewDelegate, CheckoutFlowController, CheckoutTableViewOwner, BTViewControllerPresentingDelegate
where OI: BagItemConvertable, CI.BagItemType == OI.BagItemType {
    
    public typealias CheckoutItemType = CI
    public typealias OrderItemType = OI
    public typealias ViewModel = CheckoutOrderSummaryViewModel<CheckoutOrderSummaryViewController<CheckoutItemType, OrderItemType>>
    
    override public var screenName: String {
        return "Checkout - Order Summary Screen"
    }
    
    var isUpdating: Bool = false
    let rowHeight = CGFloat(80)
    
    public var navigationTitleView: UIView = NavigationBarHelper.setupTitleView(AppLocalization.sharedInstance.checkoutOrderSummaryPageTitle)
    
    public final var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "CheckoutOrderSummaryView", bundle: nil)
        viewModel.viewControllerDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    @IBOutlet weak var placeOrderButton: CheckoutButton? {
        didSet {
            placeOrderButton?.setTitle(AppLocalization.sharedInstance.checkoutPlaceOrderText, for: .normal)
        }
    }

    @IBOutlet weak var termsAndConditionsLabel: UILabel? {
        didSet {
            termsAndConditionsLabel?.textColor = AppTheme.sharedInstance.checkoutOrderSummaryTnCLabelTextColor
            termsAndConditionsLabel?.font = AppTheme.sharedInstance.checkoutOrderSummaryTnCLabelFont
            
            let attributes = [NSAttributedStringKey.font: AppTheme.sharedInstance.orderSummaryTermsAndConditionsFont,
                              NSAttributedStringKey.foregroundColor: AppTheme.sharedInstance.orderSummaryTermsAndConditionsLabelColor] 

            let attributedString = NSMutableAttributedString(string: AppLocalization.sharedInstance.orderSummaryTermsAndConditionsLabelText)
            guard let range: Range<String.Index> = attributedString.string.range(of: AppLocalization.sharedInstance.orderSummaryTermsAndConditionsClickableText) else {
                return
            }
            
            let start = attributedString.string.distance(from: attributedString.string.startIndex, to: range.lowerBound)
            let length = attributedString.string.distance(from: range.lowerBound, to: range.upperBound)

            let nsRange = NSRange(location: start, length: length)
            attributedString.setAttributes(attributes, range: nsRange)
            
            termsAndConditionsLabel?.attributedText = attributedString
        }
    }
    
    @IBOutlet weak var tableView: UITableView? {
        
        didSet {
            
            // Hide empty cells
            tableView?.tableFooterView = UIView(frame: CGRect.zero)
            
            tableView?.dataSource = self
            tableView?.delegate = self
            
            tableView?.rowHeight = UITableViewAutomaticDimension
            tableView?.estimatedRowHeight = rowHeight
            
            tableView?.registerPoqCells(cellClasses: [CheckoutOrderSummaryCell.self, CheckoutDeliveryOptionsCell.self, CheckoutOrderSummaryTotalBagItemsCell.self, CheckoutSummaryHeaderCell.self, CheckoutStepCell.self])
            setupPullToRefresh()
        }
    }
    
    func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(CheckoutOrderSummaryViewController.startRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView?.addSubview(refreshControl)
    }
    
    @objc func startRefresh(_ refreshControl: UIRefreshControl) {
        viewModel.getCheckoutItems(true)
        refreshControl.endRefreshing()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        tableView?.backgroundView = nil
        tableView?.backgroundColor = AppTheme.sharedInstance.checkoutOrderSummaryTableViewBackgroundColor

        setupPullToRefresh()
        PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.OrderSummary.step, option: CheckoutActionType.OrderSummary.option)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getCheckoutItems(true)
    }
    
    func initNavigationBar() {
        
        navigationItem.titleView = navigationTitleView
        
        if let navigationControllerUnwrapped = navigationController, navigationControllerUnwrapped.viewControllers.count > 1 {
            navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
        }
        
        navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func checkoutButtonClicked(_ sender: AnyObject) {
        enableUserInteraction(!viewModel.placeOrder())
    }
    
    // MARK: - Networking events
    override public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        placeOrderButton?.isEnabled = false
    }
    
    override public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        isUpdating = false
        tableView?.reloadData()
        enableUserInteraction(true)
    }

    override public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider) {

        isUpdating = false

        for step in viewModel.allCheckoutSteps {
            step.flowController = self
            
            guard let tableBasedCheckoutStep = step as? TableCheckoutFlowStep else {
                assert(false, "All steps must be confirmed to `TableCheckoutFlowStep`")
                continue
            }

            tableBasedCheckoutStep.tableViewOwner = self
            tableBasedCheckoutStep.registerReuseViews(tableView)
        }
        
        let checkoutButtonTitle: String
        if let total: Double = viewModel.checkoutItem?.totalPrice {
            // FIXME: localizeah
            checkoutButtonTitle = String(format: AppLocalization.sharedInstance.checkoutOrderSummaryPayTotalFormat, arguments: [total.toPriceString()]) 
        } else {
            checkoutButtonTitle = AppLocalization.sharedInstance.checkoutPlaceOrderText
        }
        placeOrderButton?.setTitle(checkoutButtonTitle, for: UIControlState())

        tableView?.reloadData()
        enableUserInteraction(true)
    }
    
    func enableUserInteraction(_ isEnabled: Bool) {
        placeOrderButton?.isEnabled = isEnabled
        tableView?.isUserInteractionEnabled = isEnabled
        navigationItem.leftBarButtonItem?.isEnabled = isEnabled
    }
    
    @IBAction func termsConditionsButtonAction(_ sender: AnyObject) {
        let pageIdString = AppSettings.sharedInstance.checkoutOrderSummaryTermsAndConditionPageId
        guard let pageId = pageIdString.toInt(), !pageIdString.isNullOrEmpty() else {
            return
        }
        
        let pageDetail = PageDetailViewController(nibName: "PageDetailView", bundle: nil)
        pageDetail.selectedPageTitle = "Terms & Conditions"
        pageDetail.isModalView = false
        
        pageDetail.selectedPageId = pageId
        
        self.navigationController?.pushViewController(pageDetail, animated: true)
    }

    // MARK: - UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.checkoutItems.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = viewModel.checkoutItems[indexPath.row]
        
        var cellOrNil: UITableViewCell? = nil
        switch item.type {
        case .headerCell:
            if let cell: CheckoutSummaryHeaderCell = tableView.dequeueReusablePoqCell() {
                cell.titleLabel?.text = item.text
                cellOrNil = cell
            }
        case .stepCell:
            if let step = item.step as? TableCheckoutFlowStep, let index: Int = item.cellIndex {
                cellOrNil = step.overviewCell(tableView, atIndexPath: indexPath, cellIndex: index)
            }
        }
        
        let cell = cellOrNil ?? UITableViewCell()
        if let leftSeparatorIndent = item.leftSeparatorIndent {
            var insets = cell.separatorInset
            insets.left = leftSeparatorIndent
            cell.separatorInset = insets
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets(top: CGFloat(30), left: CGFloat(0), bottom: CGFloat(30), right: CGFloat(0))
    }
    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = viewModel.checkoutItems[indexPath.row]
        if let step = item.step as? TableCheckoutFlowStep, let index: Int = item.cellIndex {
            step.overviewCellSelected(tableView, atIndexPath: indexPath, cellIndex: index)
        }
    }
    // MARK: - CheckoutFlowController
    public func addressStep(_ type: AddressType) -> AddressCheckoutStep? {
        for checkoutStep: CheckoutFlowStep in viewModel.allCheckoutSteps {
            if let addressStep: AddressCheckoutStep = checkoutStep as? AddressCheckoutStep {
                if addressStep.addressType == type {
                    return addressStep
                }
            }
        }
        
        return nil
    }
    
    public func presentStepDetail(_ step: ViewModel.StepType, viewController: PoqBaseViewController, modal: Bool) {
        
        for checkoutStep: CheckoutFlowStep in viewModel.allCheckoutSteps {
            let canPresentResult: CheckoutFlowCanPresentResult = checkoutStep.canFlowPresentsStep(step.checkoutStep)
            guard case .ok = canPresentResult else {
                if case let .cannotPresent(errorMessage) = canPresentResult {
                    viewModel.showAlert(errorMessage)
                }
                
                return
            }
        }
        
        // TODO: 'modal' ignored, should be used to modify presentation
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    public func stepDidUpdateInformation(_ step: ViewModel.StepType) {
        OrderSummaryUpdateHelper.showSuccessPopUpMessage(step.checkoutStep)
        
        // TODO: make better relaod, for now fast way
        tableView?.reloadData()
    }
    
    // MARK: - CheckoutTableViewOwner
    public func stepDidUpdateOverviewSection(_ step: TableCheckoutFlowStep) {
        viewModel.regenerateCheckoitItems()
    }
    
    // MARK: - BTViewControllerPresentingDelegate
    
    public func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    public func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
}
