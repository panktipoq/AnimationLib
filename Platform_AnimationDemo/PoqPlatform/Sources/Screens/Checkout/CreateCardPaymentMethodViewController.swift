//
//  CreateCardPaymentMethodViewController.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 11/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

public protocol CreateCardPaymentMethodDelegate: AnyObject { 
    
    func cardPaymentController(didAddedPaymentSource paymentSource: PoqPaymentSource)
}

private enum Section {
    case cardDetail
    case billingAddress
}

// TODO: We need improve UI state switching by introucing state
// Aka, loading state, modifiing state and unify all UI changes by changing of state

// TODO: rename all CreateCardPaymentMethod to CreatePaymentSource

open class CreateCardPaymentMethodViewController: PoqBaseViewController, UITableViewDataSource, UITableViewDelegate, KeyboardEventsListener {
    
    override open var screenName: String {
        return "Checkout - Enter Card Details Screen"
    }
    
    fileprivate let sections: [Section] = [.cardDetail, .billingAddress]

    /// Since payment source really new nothing about checkout, this step needed only for  address selection
    /// So lets hardcode here some item
    public typealias CheckoutItem = PoqCheckoutItem<PoqBagItem>
    public typealias CheckoutFlowControllerType = CheckoutOrderSummaryViewController<CheckoutItem, PoqOrderItem>
    
    public typealias BillingAddressStep = CheckoutAddressStep<CheckoutFlowControllerType>
    lazy public var billingAddressStep = BillingAddressStep(addressType: .Billing)
    var activityIndicator: PoqSpinner?

    // We will use one of them depends on settings in AppSettings
    @IBOutlet weak var saveButton: UIButton?
    weak var saveBarButton: UIBarButtonItem?

    /// Header with save button
    @IBOutlet weak var saveBottomConstraint: NSLayoutConstraint?

    @IBOutlet weak var paymentsEncryptionInfoView: PaymentsEncriptionInfoView?
    @IBOutlet weak var tableView: UITableView?

    public weak var delegate: CreateCardPaymentMethodDelegate?
    
    /// In case of success we should navigate to this view controller
    /// If nil ot not presented in stack - just pop to prev view controller
    public weak var popToViewController: UIViewController?

    // MARK: - private state ivars
    fileprivate final var keyboardPresented: Bool = false
    fileprivate final var isCreatingPaymentSource: Bool = false
    
    fileprivate let paymentProvider: PoqPaymentProvider

    // Make it optional, since I don't know what to do in init if paymentProvider return nil...
    fileprivate let cardCreationUIProvider: PoqPaymentCardCreationUIProvider?
    
    /// Init with payment provider, which supprt card
    /// CardPaymentProvider will be used for UI and later saving card to customer
    required public init(cardPaymentProvider: PoqPaymentProvider) {

        self.paymentProvider = cardPaymentProvider        
        self.cardCreationUIProvider = paymentProvider.createCardCreationUIProvider()
        
        super.init(nibName: CreateCardPaymentMethodViewController.XibName, bundle: nil)
        KeyboardHelper.addKeyboardNotification(self, iPhoneOnly: false)

        self.cardCreationUIProvider?.delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        // I will be surprised if this method will be ever called...
        assert(false)
        paymentProvider = BraintreeHelper.sharedInstance
        cardCreationUIProvider = paymentProvider.createCardCreationUIProvider()
        
        super.init(coder: aDecoder)
        KeyboardHelper.addKeyboardNotification(self, iPhoneOnly: false)
        
        cardCreationUIProvider?.delegate = self
    }

    deinit {
        KeyboardHelper.removeKeyboardNotification(self)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.estimatedRowHeight = 65
        tableView?.rowHeight = UITableViewAutomaticDimension
        
        tableView?.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView?.estimatedSectionHeaderHeight = 44

        initNavigationBar()

        billingAddressStep.registerReuseViews(tableView)
        saveButton?.isEnabled = false
        saveBarButton?.isEnabled = false

        cardCreationUIProvider?.registerReuseViews(withTableView: tableView)

        // Modify save button
        switch CheckoutSaveButtonLocation.saveButtonLocation {
        case.Bottom:
            saveButton?.titleLabel?.font = AppTheme.sharedInstance.addPaymentMethodSaveButtonFont
            let saveTitle: String = AppLocalization.sharedInstance.createCardPaymentSaveButtonText
            saveButton?.setTitle(saveTitle, for: UIControlState())
            saveButton?.setTitleColor(AppTheme.sharedInstance.addPaymentMethodSaveButtonNormalColor, for: UIControlState())
            saveButton?.setTitleColor(AppTheme.sharedInstance.addPaymentMethodSaveButtonDisabledColor, for: UIControlState.disabled)
            saveButton?.heightAnchor.constraint(equalToConstant: 55).isActive = true
        case .TopRight:
            saveButton?.heightAnchor.constraint(equalToConstant: 0).isActive = true
            saveButton?.isHidden = true
            
            // FIXME: localize button title
            navigationItem.rightBarButtonItem = NavigationBarHelper.createButtonItem(withTitle: "Save", target: self, action: #selector(CreateCardPaymentMethodViewController.saveButtonAction))
            saveBarButton = navigationItem.rightBarButtonItem
        }
    }
    
    open func loadAddressSelection() {
        let addressSection = CheckoutSelectAddressViewController(nibName: CheckoutSelectAddressViewController.XibName, bundle: nil)
        addressSection.addressType = .Billing
        addressSection.delegate = billingAddressStep
        navigationController?.pushViewController(addressSection, animated: true)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView?.reloadData()
        updateSaveButtonState()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpLoadingIndicator()
    }

// MARK: - Actions + API
    
    @IBAction func saveButtonAction() {
        
        guard let validUIProvider: PoqPaymentCardCreationUIProvider = cardCreationUIProvider,
            let address: PoqAddress = billingAddressStep.address, validUIProvider.isValid else {
                Log.error("How we press save without card??")
                saveButton?.isEnabled = false
                return
        }

        isCreatingPaymentSource = true
        updateSaveButtonState()
        startActivityAnimation()
        
        var card: PoqCard = validUIProvider.card
        card.billingAddress = address
        
        PoqTrackerV2.shared.checkoutPayment(type: CheckoutPaymentMethod.card.rawValue, userId: User.getUserId())
        let cardPaymentSourceParameters: PoqPaymentSourceParameters = .card(card)
        
        paymentProvider.createPaymentSource(cardPaymentSourceParameters) { [weak self] (error: NSError?) in
            guard let strongSelf = self else {
                Log.error("we should not destroy view controller before we finish card creation")
                return
            }
            strongSelf.stopActivityAnimation()
            
            Log.verbose("New method was created")
            
            strongSelf.isCreatingPaymentSource = false
            strongSelf.updateSaveButtonState()
            if let existedError = error {
                strongSelf.presentErrorAlertConstroller(strongSelf, messages: existedError.localizedDescription)
            } else {
                
                strongSelf.notifyDelegateAndPop()
            }
        }
    }

    // MARK: - UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: for address ask directly billing info step
        let section: Section = sections[section]
        if section == .billingAddress {
            return billingAddressStep.numberOfCellInOverviewSection()
        }
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section: Section = sections[indexPath.section]
        let cell: UITableViewCell
        switch section {
        case .cardDetail:
            guard let validUIProvider = cardCreationUIProvider else {
                cell = UITableViewCell()
                break
            }
            cell = validUIProvider.cardCreationCell(tableView)
            
        case .billingAddress:
            cell = billingAddressStep.overviewCell(tableView, atIndexPath: indexPath, cellIndex: indexPath.row)
        }
        return cell
    }

    // MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var text: String?
        switch sections[section] {
        case .cardDetail:
            text = AppLocalization.sharedInstance.checkoutPaymentCardTitle
        case .billingAddress:
            text = AppLocalization.sharedInstance.checkoutBillingAddressTitle
        }
        var view: CheckoutSelectPaymentHeaderView?
        if let textUnwrapped = text, !textUnwrapped.isEmpty {
            view = NibInjectionResolver.loadViewFromNib()
        }
        view?.titleLabel?.text = text
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section: Section = sections[indexPath.section]
        guard case .billingAddress = section else {
            return
        }
        
        loadAddressSelection()
    }

    // MARK: - KeyboardEventsListener 
    public func keyboardWillShow(_ notification: Notification) {
        keyboardPresented = true
        
        guard let userInfo = notification.userInfo, let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
        let keyboardOffset = frameValue.cgRectValue.size.height
        
        saveBottomConstraint?.constant = keyboardOffset
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    public func keyboardWillHide(_ notification: Notification) {
        keyboardPresented = false
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
        
        saveBottomConstraint?.constant = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}

extension CreateCardPaymentMethodViewController: PoqPaymentCardInputChangesDelegate {
    
    final public func cardInputWasChanged(_ sender: PoqPaymentCardCreationUIProvider) {
        updateSaveButtonState()
    }
}

// MARK: - Error handling
extension CreateCardPaymentMethodViewController {
    
    /// If messages is nil - default message will be resented. localized "TRY_AGAIN"
    func presentErrorAlertConstroller(_ presenter: UIViewController, messages: String?) {
        
        let errorMessage: String = messages ?? "TRY_AGAIN".localizedPoqString
        let okText = "OK".localizedPoqString
        
        alertController = UIAlertController(title: errorMessage, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController?.addAction(UIAlertAction.init(title: okText, style: UIAlertActionStyle.default, handler: nil))
        
        guard let validAlertController = alertController else {
            return
        }
        present(validAlertController, animated: true) { 
            // Completion handler once everything is dismissed
        }
    }
}

// MARK: - Private
extension CreateCardPaymentMethodViewController {
    
    /// Update UI elements for not loading state
    fileprivate final func completeNetworkTaskVisuals() {
        saveButton?.isHidden = false
        saveBarButton?.isEnabled = false
        activityIndicator?.stopAnimating()
    }
    
    fileprivate final func initNavigationBar() {
        navigationItem.titleView = NavigationBarHelper.setupTitleView(AppLocalization.sharedInstance.createCardPaymentMethodTitle)
        navigationItem.leftBarButtonItem = NavigationBarHelper.setupBackButton(self)
    }

    fileprivate final var braintreeCardDetailCell: BraintreeCardDetailTextFieldsCell? {
        guard let sectionIndex: Int = sections.index(of: .cardDetail) else {
            return nil
        }
        
        let indexPath = IndexPath(row: 0, section: sectionIndex)
        return tableView?.cellForRow(at: indexPath) as? BraintreeCardDetailTextFieldsCell
    }
    
    /// Enable/disable save button according to entered values
    fileprivate final func updateSaveButtonState() {
        guard let uiProvider: PoqPaymentCardCreationUIProvider = cardCreationUIProvider,
              case .completed = billingAddressStep.status,
              uiProvider.isValid else {
            saveButton?.isEnabled = false
            saveBarButton?.isEnabled = false
            return
        }
        saveButton?.isEnabled = !isCreatingPaymentSource
        saveBarButton?.isEnabled = !isCreatingPaymentSource
    }
    
    fileprivate final func startActivityAnimation() {
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
    }
    
    fileprivate final func stopActivityAnimation() {
        activityIndicator?.stopAnimating()
        activityIndicator?.isHidden = true
    }
    
    fileprivate final func notifyDelegateAndPop() {
        var createdPaymentSource: PoqPaymentSource?
        if let paymentSource: PoqPaymentSource = paymentProvider.preferredPaymentSource, paymentSource.paymentMethod == .Card {
            createdPaymentSource = paymentSource
        } else if let paymentSource = paymentProvider.customer?.paymentSources(forMethod: .Card).first {

            createdPaymentSource = paymentSource
        }
        if let validPaymentSource = createdPaymentSource {
            delegate?.cardPaymentController(didAddedPaymentSource: validPaymentSource)
        }
        if let validViewController = popToViewController, navigationController?.viewControllers.contains(validViewController) == true {
            _ = navigationController?.popToViewController(validViewController, animated: true)
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate final func setUpLoadingIndicator() {
        guard self.activityIndicator == nil else {
            return
        }
        let activityIndicator = PoqSpinner(frame: CGRect.zero)
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.applyCenterPositionConstraints()
        self.activityIndicator = activityIndicator
    }
}

// FIXME: what this method and class extrension doing here???
extension PoqCheckoutItem {
    func getPrettyAddress() -> String {
        guard let validBillingAddress = self.billingAddress, validBillingAddress.postCode != nil, let validAddress1 = validBillingAddress.address1, let validCountry = validBillingAddress.country, let validPostCode = validBillingAddress.postCode else {
            return AppLocalization.sharedInstance.noBillingAddressSelectedMessage
        }
        return "\(validAddress1), \(validCountry), \(validPostCode)"
    }
}
