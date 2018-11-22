//
//  CheckoutPaymentMethodStep.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 27/07/2016.
//
//

import Foundation
import PoqNetworking
import PoqUtilities

/// We should have viriuos beahviour, depends on flow type/version
public enum PaymentStepDetailType {
    /// Present list of cards and paypal
    case sourcesSelection
    
    /// On selection of step: create new card will be presented. Can be used only with cards  
    case createCard
}

private let preferredPaymentProviderKey: String = "PreferredPaymentProvider"

/**
 CheckoutPaymentMethodStep serve as payment method selection step.
 May accept different payment providers for different type of payment sources. Exmaple, cards from stripe, paypal from braintree, Apple Pay from shopify
 
 Step is completed if we have payment source
 */
open class CheckoutPaymentMethodStep<CFC: CheckoutFlowController>: CheckoutFlowStep<CFC>, TableCheckoutFlowStep {
    
    public var stepNumber: Int?
    
    open override var checkoutStep: CheckoutStep {
        return .paymentMethod
    }
    
    weak public var tableViewOwner: CheckoutTableViewOwner?

    public var paymentSource: PoqPaymentSource? {
        return _preferredPaymentProvider?.preferredPaymentSource
    }
    
    public let stepDetailType: PaymentStepDetailType
    
    /// Create payment step with possible payment types and payment provider for each type
    /// - parameter paymentsConfiguration: Dictionary, which list all possible payment options
   public init(paymentsConfiguration: [PoqPaymentMethod: PoqPaymentProvider], stepDetailType: PaymentStepDetailType = .sourcesSelection) {
        
        self.paymentProvidersMap = paymentsConfiguration
        self.stepDetailType = stepDetailType
        
        var uniqProviders = [PoqPaymentProvider]()
        paymentsConfiguration.values.forEach { (provider: PoqPaymentProvider) in
            if uniqProviders.contains(where: { return $0.paymentProviderType == provider.paymentProviderType }) {
                return
            }
            
            uniqProviders.append(provider)
        }
        allPaymentProviders = uniqProviders
    
        super.init()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: PoqPaymentProviderWasUpdatedNotification),
                                                                object: nil,
                                                                queue: nil) {
            [weak self]
            (_: Notification) in
            guard let existedStep = self else {
                return
            }
            existedStep.flowController?.stepDidUpdateInformation(existedStep)
        }
    }
    
    /// Ideally we should save preferred method to userDefault, but from getting perspective easiest wasy get preferredPaymentSource from customer in PoqPyamnetProvider
    fileprivate var _preferredPaymentProvider: PoqPaymentProvider? {
        get {
            // Special case - if only one provider - we can just takes it preffered
            if allPaymentProviders.count < 2 {
                return allPaymentProviders.first
            }
            let userDefaults = UserDefaults.standard
            
            let preferredPaymentProviderString: String? = userDefaults.string(forKey: preferredPaymentProviderKey)
            
            // Here we do extra checks - we need check that we found correct provider with existed payment sources
            // I'm pretty shamed for this long and not beauty approach
            let filteredProviders = paymentProvidersMap.filter({ (tuple: (PoqPaymentMethod, PoqPaymentProvider)) in
                let paymentSources = tuple.1.customer?.paymentSources(forMethod: tuple.0)
                guard let existedSource = paymentSources,
                    tuple.1.paymentProviderType.rawValue == preferredPaymentProviderString &&
                        existedSource.count > 0 else {
                            return false
                }

                return true
            })
            var provider: PoqPaymentProvider? = filteredProviders.first?.1         

            if provider != nil {
                return provider
            }
            
            // Looks like we never save any data source, lets select first one with payment source
            for (paymentMethod, someProvider): (PoqPaymentMethod, PoqPaymentProvider) in paymentProvidersMap {
                if let sourcesCount = someProvider.customer?.paymentSources(forMethod: paymentMethod).count, sourcesCount > 0 {
                    provider = someProvider
                    
                    CheckoutPaymentMethodStep.setPreferredPaymentProvider(paymentProvider: someProvider)
                    break
                }
            }
            
            return provider
        }
        
        set(value) {
            guard let existedValue = value else {
                return
            }
            
            CheckoutPaymentMethodStep.setPreferredPaymentProvider(paymentProvider: existedValue)
        }
    }
    
    /// Update last last selected payment provider
    /// In case of one payment provider - always will be the same
    static func setPreferredPaymentProvider(paymentProvider: PoqPaymentProvider) {

        UserDefaults.standard.setValue(paymentProvider.paymentProviderType.rawValue, forKey: preferredPaymentProviderKey)
        UserDefaults.standard.synchronize()
    }
    
    open override func populateCheckoutItem(_ checkoutItem: CheckoutItemType) {
        
        guard let validPaymentSource = paymentSource, let paymentProvider = paymentProvidersMap[validPaymentSource.paymentMethod] else {
                return
        }
        
        let paymentOption = PoqPaymentOption()
        
        paymentOption.stripeCustomerId = paymentProvider.customer?.identifier
        paymentOption.paymentMethod = validPaymentSource.paymentMethod.rawValue
        paymentOption.paymentMethodToken = validPaymentSource.paymentSourceToken
        paymentOption.paymentType = validPaymentSource.paymentProvidaer.rawValue
        
        checkoutItem.paymentOption = paymentOption
    }
    
    public let paymentProvidersMap: [PoqPaymentMethod: PoqPaymentProvider]
    fileprivate let allPaymentProviders: [PoqPaymentProvider]
    
    // MARK: - CheckoutFlowStep override
    open override var status: StepStatus {
        if paymentSource != nil {
            return .completed
        }
        
        return .notCompleted(message: AppLocalization.sharedInstance.checkoutSelectPaymentMessage)
    }
    
    open override func update(_ checkoutItem: CheckoutItemType) { 
    }

    // MARK: - TableCheckoutFlowStep
    
    public func numberOfCellInOverviewSection() -> Int {
        return 1
    }
    
    public func overviewCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int) -> UITableViewCell {
        
        let cell = configureCheckoutStepCell(tableView, atIndexPath: indexPath)

        cell.createAccessoryView()
        
        cell.accessibilityIdentifier = AccessibilityLabels.paymentOptionCell
        
        return cell
    }
    
    open func overviewCellSelected(_ tableView: UITableView, atIndexPath indexPath: IndexPath, cellIndex: Int) {
        
        var detailViewController: PoqBaseViewController? = nil
        switch stepDetailType {
        case .sourcesSelection:
            let paymentMethodSelectionViewController = CheckoutSelectPaymentOptionViewController(paymentProvidersMap: paymentProvidersMap, preselectedPaymentSource: paymentSource)
            paymentMethodSelectionViewController.delegate = self
            detailViewController = paymentMethodSelectionViewController
            
        case .createCard:
            guard let cardPyamentProvider: PoqPaymentProvider = paymentProvidersMap[.Card] else {
                Log.error("We don't have provider for car payments, doesn't sounds right")
                break
            }
            let createPaymentController = CreateCardPaymentMethodViewController(cardPaymentProvider: cardPyamentProvider)
            createPaymentController.delegate = self
            detailViewController = createPaymentController
        }
        
        if let validDetailViewController = detailViewController {
            flowController?.presentStepDetail(self, viewController: validDetailViewController, modal: false)
        } else {
            Log.error("We didn't get detail view controller for \(stepDetailType) detail tyle")
        }
    }
}

extension CheckoutPaymentMethodStep: CreateCardPaymentMethodDelegate {

    public func cardPaymentController(didAddedPaymentSource: PoqPaymentSource) {
        
        flowController?.stepDidUpdateInformation(self)
    }
}

extension CheckoutPaymentMethodStep: SelectPaymentOptionDelegate {
    
    public func didSelect(paymentSource: PoqPaymentSource) {

        let paymentMethod = paymentSource.paymentMethod

        if let paymentProvider = paymentProvidersMap[paymentMethod] {
            paymentProvider.preferredPaymentSource = paymentSource
            CheckoutPaymentMethodStep<CFC>.setPreferredPaymentProvider(paymentProvider: paymentProvider)
        }
    }
}

extension CheckoutPaymentMethodStep: CheckoutStep3LinePresentation {

    /// We have 3 different styles of label,they depends on which line this label is. May be used only one this line
    public var firstLine: String? {
        return "CHECKOUT_PAYMENT_STEP_FIRST_LINE".localizedPoqString
    }
    
    public var secondLine: String? {
        return nil
    }
    
    public var thirdLine: String? {
        guard let validPaymentSource = paymentSource else {
            return AppLocalization.sharedInstance.checkoutSelectPaymentMethodTitle
        }
        
        return validPaymentSource.presentation.oneLinePresentation
    }
    
    public var rightDetailText: String? {
        return nil
    }
}

// MARK: - Private
extension CheckoutPaymentMethodStep {
    
    fileprivate final func configureCheckoutOrderSummaryCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CheckoutOrderSummaryCell = tableView.dequeueReusablePoqCell(forIndexPath: indexPath)
        
        cell.accessibilityIdentifier = AccessibilityLabels.paymentOptionCell
        
        if let paymentSource = self.paymentSource {
            cell.setupUI( AppLocalization.sharedInstance.checkoutPaymentMethodsTitle, contentDetail: paymentSource.presentation.twoLinePresentation.firstLine)
        } else {
            cell.setupUI("", contentDetail: AppLocalization.sharedInstance.checkoutSelectPaymentMethodTitle)
        }
        
        return cell
    }
}
