//
//  CheckoutSelectPaymentOptionViewController.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 19/07/2016.
//
//

import Braintree
import Foundation
import PoqUtilities
import PoqNetworking
import PoqAnalytics

// TODO: this view controller should have delegate. And delegate is payment step

public protocol SelectPaymentOptionDelegate: AnyObject {
    func didSelect(paymentSource: PoqPaymentSource)
}

open class CheckoutSelectPaymentOptionViewController: PoqBaseViewController {
    
    enum State {
        case `default` // When we have at least on payment option
        case editing   // Edit button pressed
        case loading   // We are updating data or logging to  paypal. Loading indicator is presented
        case deleting  // Some intersection of loading and editing - we are removing card, so UI blocked and loading indicator presentd + we are in editing state
        
        static let stateWithAddCells: [State] = [.default, .loading]
    }

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var topInfoView: PaymentsEncriptionInfoView?

    @IBOutlet weak var spinnerView: PoqSpinner?
    
    public weak var delegate: SelectPaymentOptionDelegate?
    
    public typealias CheckoutItem = PoqCheckoutItem<PoqBagItem>
    public typealias CheckoutFlowControllerType = CheckoutOrderSummaryViewController<CheckoutItem, PoqOrderItem>
    public typealias BillingAddressStep = CheckoutAddressStep<CheckoutFlowControllerType>
    
    lazy public var billingAddressStep = BillingAddressStep(addressType: .Billing)
    
    lazy var viewModel: CheckoutSelectPaymentOptionViewModel = {
        [weak self, providersMap = self.paymentProvidersMap ] in
        return CheckoutSelectPaymentOptionViewModel(paymentProvidersMap: providersMap, viewControllerDelegate: self)
        
    } ()
    private var currentPaymentMethodType: PoqPaymentMethod?
    
    /// View controller works only with 2 payment methods for now, so we will filter 'paymentProvidersMap' to validPaymentMethods
    fileprivate static let validPaymentMethods: [PoqPaymentMethod] = [.Card, .PayPal, .Klarna]
    
    public init(paymentProvidersMap: [PoqPaymentMethod: PoqPaymentProvider], preselectedPaymentSource: PoqPaymentSource?) {
        
        let filteredTuples: [(PoqPaymentMethod, PoqPaymentProvider)] = paymentProvidersMap.filter({ return CheckoutSelectPaymentOptionViewController.validPaymentMethods.contains($0.0) })
        var filteredProvidersMap = [PoqPaymentMethod: PoqPaymentProvider]()
        filteredTuples.forEach({ filteredProvidersMap[$0.0] = $0.1 })
        self.paymentProvidersMap = filteredProvidersMap
        self.selectedPaymentSource = preselectedPaymentSource
        super.init(nibName: "CheckoutSelectPaymentOptionView", bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.paymentProvidersMap = [:]
        self.selectedPaymentSource = nil
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        tableView?.sectionFooterHeight = CheckoutSelectPaymentOptionViewModel.paymentSectionsIndent
        tableView?.sectionHeaderHeight = 0.1
        
        subscribeToPaymentSourcesUpdates()
        
        navigationItem.titleView = NavigationBarHelper.setupTitleView("Paying with".localizedPoqString)
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)

        tableView?.registerPoqCells(cellClasses: [CheckoutSelectPaymentOptionCell.self])
        
        viewModel.regenerateSectionItems(selectedPaymentSource)
        self.state = .default
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTableViewLayout()
    }
    
    fileprivate var firstAppearence: Bool = true
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstAppearence {
            firstAppearence = false
            
            // We just navigated to screen, and we can add only cards + we don't have card
            if !viewModel.hasValidPaymentSources() && Array(paymentProvidersMap.keys) == [.Card] {
                openAddCardPaymentSourceScreen()
            }
        }
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateTableViewLayout()
    }
    
    @objc func editButtonAction() {
        if tableView?.isEditing == true {
            tableView?.setEditing(false, animated: true)
            viewModel.regenerateSectionItems(selectedPaymentSource, showAddItems: true)
            state = .default
        } else {
            viewModel.regenerateSectionItems(selectedPaymentSource, showAddItems: false)
            tableView?.setEditing(true, animated: true)
            state = .editing
        }
    }

    public let paymentProvidersMap: [PoqPaymentMethod: PoqPaymentProvider]
    
    // TODO: to make sure that delegate know about all we need unify selected address with Payment method step
    fileprivate var selectedPaymentSource: PoqPaymentSource?
    
    /// Have to use this name, because prev name 'editButtonItem' used by system
    internal var customEditButtonItem: UIBarButtonItem?
    
    fileprivate var state: State = .default {
        
        didSet {
            
            let hasValidPaymentSources = viewModel.hasValidPaymentSources()
            
            if hasValidPaymentSources {
                createEditButton()
            } else {
                navigationItem.rightBarButtonItem = nil
            }

            switch state {

            case .default:
                stopSpinnerAnimation()
            case .editing:
                customEditButtonItem?.title = "Done"
                customEditButtonItem?.isEnabled = true
                stopSpinnerAnimation()
            case .loading:
                startSpinnerAnimation()
                customEditButtonItem?.isEnabled = false
            case .deleting:
                startSpinnerAnimation()
                customEditButtonItem?.isEnabled = false
            }
            updateTableViewLayout()
            tableView?.reloadData()
        }
    }
    
    open func openKlarnaBillingAddressScreen() {
        let addressSection = CheckoutSelectAddressViewController(nibName: CheckoutSelectAddressViewController.XibName, bundle: nil)
        addressSection.addressType = .Billing
        addressSection.delegate = self
        navigationController?.pushViewController(addressSection, animated: true)
    }
        
    open func openAddCardPaymentSourceScreen() {
        guard let cardPaymentProvider: PoqPaymentProvider = paymentProvidersMap[.Card] else {
            Log.error("Unable to find proper payment provider for card payment method")
            return
        }
        let createPaymentController = CreateCardPaymentMethodViewController(cardPaymentProvider: cardPaymentProvider)
        createPaymentController.billingAddressStep = billingAddressStep
        createPaymentController.delegate = self
        
        if let index: Int = navigationController?.viewControllers.index(of: self), index > 0 {
            createPaymentController.popToViewController = navigationController?.viewControllers[index - 1]
        }
        
        navigationController?.pushViewController(createPaymentController, animated: true)
    }
}

extension CheckoutSelectPaymentOptionViewController: AddressSelectionDelegate {
    
    public func selectAddress(_ responder: CheckoutSelectAddressResponder, didSelectedAddress adrdess: PoqAddress) {
        if let unwrappedResponder = responder as? CheckoutSelectAddressViewController, let unwrappedCurrentPaymentMethodType = currentPaymentMethodType, unwrappedCurrentPaymentMethodType == .Klarna, unwrappedResponder.addressType == AddressType.Billing {
            startKlarnaAuthorization(adrdess)
        }
    }
}

extension CheckoutSelectPaymentOptionViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].count
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard isNonEmptyCardsSection(section) else {
            return nil
        }
        
        let title = AppLocalization.sharedInstance.checkoutPaymentOptionsSectionCardTitle
        
        var view: CheckoutSelectPaymentHeaderView?
        if title.isEmpty == false {
            view = NibInjectionResolver.loadViewFromNib()
        }
        
        view?.titleLabel?.text = title
        return view
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: CheckoutSelectPaymentOptionCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.delegate = self
        cell.isEditing = tableView.isEditing
        
        let item: PaymentOptionItem = viewModel.sections[indexPath.section][indexPath.row]
        
        var selected: Bool = false
        if let paymentMethod = item.paymentSource, let preferredMethods = selectedPaymentSource, paymentMethod == preferredMethods {
            selected = true
        }

        cell.setPaymentOptionItem(item, selected: selected)
        return cell
    }
}

extension CheckoutSelectPaymentOptionViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isNonEmptyCardsSection(section) {
            return 40.0
        }
        
        // Always indent the PayPal Section (regardless of existance of valid payment sources)
        // Always indent every section when any payment sources are available
        let item = viewModel.sections[section].first
        if item?.method == .PayPal || viewModel.hasValidPaymentSources() {
            return CheckoutSelectPaymentOptionViewModel.paymentSectionsIndent
        }
        
        return 0.1
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item: PaymentOptionItem = viewModel.sections[indexPath.section][indexPath.row]
        
        if let validSource = item.paymentSource {
            
            delegate?.didSelect(paymentSource: validSource)

            _ = navigationController?.popViewController(animated: true)
            return
        }
        
        currentPaymentMethodType = item.method
        
        switch item.method {
        case .Card:
            openAddCardPaymentSourceScreen()
        case .PayPal:
            startPaypalAuthorization()
        case .Klarna:
            openKlarnaBillingAddressScreen()
        default:
            Log.error("Some unexpected method: \(item.method)")
        }
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension CheckoutSelectPaymentOptionViewController: CreateCardPaymentMethodDelegate {
    
    public func cardPaymentController(didAddedPaymentSource paymentSource: PoqPaymentSource) {
        selectedPaymentSource = paymentSource
        
        if viewModel.paymentProvidersMap[paymentSource.paymentMethod] != nil {
            delegate?.didSelect(paymentSource: paymentSource)
        }
        
        viewModel.regenerateSectionItems(selectedPaymentSource)
        self.state = .default
    }
}

extension CheckoutSelectPaymentOptionViewController: BTViewControllerPresentingDelegate {
    
    public func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        
        // TODO: we should use navigation with custom presentation instead
        present(viewController, animated: true, completion: nil)
    }
    
    public func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension CheckoutSelectPaymentOptionViewController: PaymentOptionCellDelegate {
    
    public func deleteButtonPressed(onItem item: PaymentOptionItem) {
        guard let paymentSource: PoqPaymentSource = item.paymentSource,
            let paymentProvider: PoqPaymentProvider = paymentProvidersMap[paymentSource.paymentMethod] else {
            return
        }
        
        state = .deleting
        paymentProvider.deletePaymentSource(paymentSource) { [weak self] (error: NSError?) in
            
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.selectedPaymentSource?.paymentSourceToken == paymentSource.paymentSourceToken {
                strongSelf.selectedPaymentSource = paymentProvider.preferredPaymentSource
            }
            
            strongSelf.viewModel.regenerateSectionItems(strongSelf.selectedPaymentSource, showAddItems: false)
            if strongSelf.viewModel.hasValidPaymentSources() {
                
                strongSelf.state = .editing
            } else {
                // We have to regenerate one more time
                strongSelf.viewModel.regenerateSectionItems(strongSelf.selectedPaymentSource, showAddItems: true)
                strongSelf.tableView?.setEditing(false, animated: false)
                strongSelf.state = .default
            }
        }
    }
}

// MARK: - Private

extension CheckoutSelectPaymentOptionViewController {
    
    fileprivate final func startKlarnaAuthorization( _ billingAddress: PoqAddress ) {
        // TODO: Add klarna authorization logic
    }
    
    fileprivate final func startPaypalAuthorization() {
        state = .loading
        
        // TODO: find way even here use PoqPaymentProvider
        BraintreeHelper.sharedInstance.loginWithPayPal(self, completion: { [weak self] (error: NSError?) in
            
            if let payPalPaymentProvider: PoqPaymentProvider = self?.paymentProvidersMap[.PayPal],
                let prefferedPayPal = payPalPaymentProvider.customer?.paymentSources(forMethod: .PayPal).first {
                self?.selectedPaymentSource = prefferedPayPal
                self?.delegate?.didSelect(paymentSource: prefferedPayPal)
            }
            
            DispatchQueue.main.async {
                self?.viewModel.regenerateSectionItems(self?.selectedPaymentSource)
                self?.state = .default
                
                PoqTrackerV2.shared.checkoutPayment(type: CheckoutPaymentMethod.paypal.rawValue, userId: User.getUserId())
                _ = self?.navigationController?.popViewController(animated: true)
            }
        })
    }

    fileprivate final func subscribeToPaymentSourcesUpdates() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: PoqPaymentProviderWasUpdatedNotification), object: nil, queue: nil) { [weak self] (_: Notification) in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.viewModel.regenerateSectionItems(strongSelf.selectedPaymentSource, showAddItems: State.stateWithAddCells.contains(strongSelf.state))
            if !strongSelf.viewModel.hasValidPaymentSources() {
                strongSelf.viewModel.regenerateSectionItems(strongSelf.selectedPaymentSource, showAddItems: true)
                strongSelf.state = .default
            }
            strongSelf.tableView?.reloadData()
        }
    }
    
    fileprivate final func isNonEmptyCardsSection(_ section: Int) -> Bool {
        
        guard let firstInSection: PaymentOptionItem = viewModel.sections[section].first else {
            return false
        }
        
        let res: Bool = (firstInSection.method == .Card) && (firstInSection.paymentSource != nil)
        
        return res
    }
    
    // FIXME: it should be some base functionality in base view controller
    fileprivate final func startSpinnerAnimation() {
        spinnerView?.isHidden = false
        spinnerView?.startAnimating()
    }
    
    fileprivate final func stopSpinnerAnimation() {
        
        spinnerView?.stopAnimating()
        spinnerView?.isHidden = true
    }
    
    fileprivate final func updateTableViewLayout() {
        guard viewModel.hasValidPaymentSources() else {
            tableView?.isScrollEnabled = false
            
            // We  will put top indent in UITableView to place 2 cells on bottom of screen
            let topInset = (tableView?.bounds.size.height ?? 0) - CGFloat(viewModel.sections.count) * CheckoutSelectPaymentOptionViewModel.paymentMathodCellHeight - 2.0 * CheckoutSelectPaymentOptionViewModel.paymentSectionsIndent
            
            tableView?.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
            return
        }
        
        tableView?.isScrollEnabled = true
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    /// Create UIBarButtonItem with "Edit" title and put it in right slot
    fileprivate final func createEditButton() {
        // FIXME: localize title
        customEditButtonItem = NavigationBarHelper.createButtonItem(withTitle: "Edit", target: self, action: #selector(CheckoutSelectPaymentOptionViewController.editButtonAction))
        navigationItem.rightBarButtonItem = customEditButtonItem
    }
}
