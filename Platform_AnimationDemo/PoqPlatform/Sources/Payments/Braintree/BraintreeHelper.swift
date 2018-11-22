//
//  BraintreeHelper.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 18/07/2016.
//
//

import Braintree
import Foundation
import Locksmith
import PassKit
import PoqNetworking
import PoqUtilities

public let braintreeErrorDomain: String = "BraintreeError"

public enum BraintreeErrorCode: Int {
    case unknown = 0
    case incorrectCardInfo = 1
    case incorrectAddressInfo = 2
}

struct BraintreeOperationDef {
    static let BraintreeKeychainUser: String = "BraintreeKeychainUser"
    static let KeychainCustomerIdKey: String = "CustomerId"
    static let KeychainPreferredPaymentSourceIdKey: String = "PreferredPaymentSourceId"
}

open class BraintreeHelper {

    public static let sharedInstance = BraintreeHelper()

    open var braintreeClient: BTAPIClient?
    
    fileprivate(set) var customerId: String?
    fileprivate var isCustomerInKeychain: Bool = false
    fileprivate var preferredPaymentSourceId: String?
    
    fileprivate final var locksmithUserName: String? {
        guard let userName: String = LoginHelper.getEmail(), !userName.isNullOrEmpty() else {
            return nil
        }
        
        return BraintreeOperationDef.BraintreeKeychainUser + ":" + userName
    }
    
    fileprivate var braintreeCustomer: PoqBraintreeCustomer?
    
    /// We need our own queue to create queue from operations. For example: Create token -> Create Payment Method nonse -> Add payment method to customer
    public final let operationQueue = OperationQueue()
    
    /// Keep ref to operation to avoid multiple operations run at the same time
    open weak var tokenGenerationOperation: BraintreeTokenGenerationOperation?

    required public init() {
        Log.verbose("Register for app switch with \(BraintreeHelper.paymentsURlScheme)")
        BTAppSwitch.setReturnURLScheme(BraintreeHelper.paymentsURlScheme)
        
        parseInitialUserData()
        
        // TODO: I can see here race condition: we may have requests running when logout happen. So we need find way to cancel all running requests
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: PoqUserDidLoginNotification), object: nil, queue: nil) { [weak self] _ in
            self?.parseInitialUserData()
        }
        
        // TODO: I can see here rais condition: we may have requests running when logout happen. So we need find way to cancel all running requests
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: PoqUserDidLogoutNotification), object: nil, queue: nil) { [weak self] _ in
            self?.clearCustomer()
        }
    }
    
    /// Parse data from keychain for current user and send request to API
    fileprivate func parseInitialUserData() {
        guard let locksmithUserName = locksmithUserName else {
            return
        }
        
        guard let keychainData = Locksmith.loadDataForUserAccount(userAccount: locksmithUserName) else {
            return
        }
        
        guard let customerId = keychainData[BraintreeOperationDef.KeychainCustomerIdKey] as? String else {
            return
        }
        
        isCustomerInKeychain = true
        
        self.customerId = customerId
        self.preferredPaymentSourceId = keychainData[BraintreeOperationDef.KeychainPreferredPaymentSourceIdKey] as? String
        
        createTokenGenerationOperationIfNeeded()
        getCurrentCustomerDetailsIfNeeded()
    }
    
    /// Remove customer details from keychain.
    fileprivate func clearCustomer() {
        braintreeCustomer = nil
        customerId = nil
        preferredPaymentSourceId = nil
        
        isCustomerInKeychain = false
        
        guard let locksmithUserName = locksmithUserName else {
            return
        }
        
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: locksmithUserName)
        } catch {
            Log.error("Unable to clear Braintree customer data from locksmith.")
        }
    }
}

// MARK: - API
extension BraintreeHelper {
    
    static var paymentsURlScheme: String {
        return "\(UIApplication.shared.bundleIdentifier).payments"
    }
    
    /**
     Load Customer detail if needed.
     Won't load anything if we already got customer information
     */
    final func getCurrentCustomerDetailsIfNeeded() {
        guard let validCustomerId = customerId, customer == nil else {
            return
        }
        
        PoqNetworkService(networkTaskDelegate: self).getBraintreeCustomer(validCustomerId)
    }
    
    /// Add payment method to customer or create new one with this payment source
    /// - parameter card: card information from braintree card form
    /// - parameter completion: will be called ehwn all network task completed. If error is nil - all is ok, otherwise error containt information about error
    final func addPaymentMethodSource(_ card: BTCard, completion: @escaping BraintreeOperationCompletion) {
        
        createTokenGenerationOperationIfNeeded()
        
        let creatingCardOperation = BraintreeAddCardPaymentSourceOperation(card: card, completion: completion)
        
        if let dependencyOperation = tokenGenerationOperation {
            creatingCardOperation.addDependency(dependencyOperation)
        }

        operationQueue.addOperation(creatingCardOperation)
    }
    
    /// Create login with PayPay operation and later add paypal token to customer
    public final func loginWithPayPal(_ presentingDelegate: BTViewControllerPresentingDelegate, completion: @escaping BraintreeOperationCompletion) {
        createTokenGenerationOperationIfNeeded()
        
        let paypalLogin = BraintreeAddPayPalPaymentSourceOperation(completion: completion)
        paypalLogin.presentingDelegate = presentingDelegate
        
        if let dependencyOperation = tokenGenerationOperation {
            paypalLogin.addDependency(dependencyOperation)
        }
        
        operationQueue.addOperation(paypalLogin)
    }
    
    /// Just replace saved customer with updated, send notifications about changes
    final func updateBraintreeCustomer(_ updatedCustomer: PoqBraintreeCustomer) {
        braintreeCustomer = updatedCustomer
        
        customerId = braintreeCustomer?.customerId
        // We didn't fuind method wich correspond to this id in updated client, may be removed, may be magic
        if preferredPaymentSource == nil {
            preferredPaymentSourceId = braintreeCustomer?.paymentMethods?.first?.token
        }
        
        updateKeychainData()
        NotificationCenter.default.post(name: Notification.Name(rawValue: PoqPaymentProviderWasUpdatedNotification), object: self)
    }
}

extension BraintreeHelper: PoqNetworkTaskDelegate {

    final public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        guard let customer: PoqBraintreeCustomer = result?.first as? PoqBraintreeCustomer else {
            Log.error("We got response  from server, but htere is no client")
            return
        }

        updateBraintreeCustomer(customer)
    }

    final public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {}
}

extension BraintreeHelper: PoqPaymentProvider {
    
    final public var paymentProviderType: PoqPaymentProviderType {
        return .Braintree
    }
    
    final public var customer: PoqPaymentCustomer? {
        return braintreeCustomer
    }
    
    /// Will return payment method if at leas one exists in customer vault
    final public var preferredPaymentSource: PoqPaymentSource? {
        get {
            var allMethods = [PoqPaymentSource]()
            
            if let cards = braintreeCustomer?.paymentMethods {
                allMethods.append(contentsOf: cards.map({ $0 as PoqPaymentSource }))
            }
            
            if let paypals = braintreeCustomer?.payPalAccounts {
                allMethods.append(contentsOf: paypals.map({ $0 as PoqPaymentSource }))
            }
            
            let index: Int? = allMethods.index(where: { return $0.paymentSourceToken == preferredPaymentSourceId })
            
            guard let validIndex = index else {
                return allMethods.first
            }
            
            return allMethods[validIndex]
        }
        
        set {
            preferredPaymentSourceId = newValue?.paymentSourceToken
            updateKeychainData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: PoqPaymentProviderWasUpdatedNotification), object: self)
        }
    }
    
    final public func createApplePayToken(forPayment payment: PKPayment, completion: @escaping (_ token: String?, _ error: NSError?) -> Void) {
        
        createTokenGenerationOperationIfNeeded()
        
        let applePayTokenization = BraintreeApplePayPaymentTokenizationOperation(payment: payment, completion: completion)
        
        if let dependencyOperation = tokenGenerationOperation {
            applePayTokenization.addDependency(dependencyOperation)
        }
        
        operationQueue.addOperation(applePayTokenization)
    }
    
    public func createPaymentSource(_ paymentSourceParameters: PoqPaymentSourceParameters, completion: @escaping (NSError?) -> Void) {
        switch paymentSourceParameters {
        case .card(let validCard):
            let cardNumber: String = validCard.cardNumber
            let cvv: String = validCard.cvv
            guard let month: Int = validCard.expirationMonth, let year: Int = validCard.expirationYear else {
                DispatchQueue.main.async {
                    completion(self.createError(BraintreeErrorCode.incorrectCardInfo))
                }
                return
            }
            
            guard let address = validCard.billingAddress else {
                DispatchQueue.main.async {
                    completion(self.createError(BraintreeErrorCode.incorrectAddressInfo))
                }
                return
            }
            
            let card = BTCard(number: cardNumber, expirationMonth: "\(month)", expirationYear: "\(year)", cvv: cvv)
            card.updateAddress(withPoqAddress: address)
            
            addPaymentMethodSource(card) { (error: NSError?) in
                PoqTracker.sharedInstance.trackCheckoutAction(CheckoutActionType.PaymentOptions.step, option: CheckoutActionType.PaymentOptions.option)
                
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        case .klarna(_):
            // Nothing to do 
            assertionFailure("Braintree requires a valid card when creating the source")
        }  
    }
    
    public func deletePaymentSource(_ paymentSource: PoqPaymentSource, completion: @escaping (_ error: NSError?) -> Void) {
        let operation = BraintreeDeletePaymentSourceOperation(paymentSource: paymentSource, completion: {
            [weak self]
            (error: NSError?) in
            guard let strongSelf = self else {
                completion(error)
                return
            }
            
            // Since we don't get customer in response - lets remove source manually
            if let existedCustomer: PoqBraintreeCustomer = strongSelf.braintreeCustomer, error == nil {
                
                // Card case
                if let cardPaymentSource: PoqBraintreeCardPaymentSource = paymentSource as? PoqBraintreeCardPaymentSource,
                    let index: Int = existedCustomer.paymentMethods?.index(where: { return $0.token == cardPaymentSource.token }) {
                        existedCustomer.paymentMethods?.remove(at: index)
                } else {
                
                    // Paypal case
                    if let paypalPaymentSource: PoqBraintreePayPalPaymentSource = paymentSource as? PoqBraintreePayPalPaymentSource,
                        let index: Int = existedCustomer.payPalAccounts?.index(where: { return $0.token == paypalPaymentSource.token }) {
                        existedCustomer.payPalAccounts?.remove(at: index)
                    }
                }
            }
            
            completion(error)
            
        })
        
        operationQueue.addOperation(operation)
    }
    
    final public func createCardCreationUIProvider() -> PoqPaymentCardCreationUIProvider? {
        return BraintreeCartCreationUIProvider()
    }
}

// MARK: - Private
extension BraintreeHelper {

    /// Update record in keychain with current customerId and preferredPaymentSourceId
    fileprivate final func updateKeychainData() {
        guard let validLocksmithUserName = locksmithUserName else {
            Log.error("We trying to save data into keychain while can't create locksmith username. May be user are not logged in")
            return
        }

        // Customer id and source id to keychain
        var paymentMethodInfo = [String: AnyObject]()
        if let validCustomerId: String = customerId {
            paymentMethodInfo[BraintreeOperationDef.KeychainCustomerIdKey] = validCustomerId as AnyObject?
        }
        
        if let validPreferredPaymentSourceId: String = preferredPaymentSourceId {
            paymentMethodInfo[BraintreeOperationDef.KeychainPreferredPaymentSourceIdKey] = validPreferredPaymentSourceId as AnyObject?
        }
        
        do {
            if isCustomerInKeychain {
                try Locksmith.updateData(data: paymentMethodInfo, forUserAccount: validLocksmithUserName)
                
            } else {
                try Locksmith.saveData(data: paymentMethodInfo, forUserAccount: validLocksmithUserName)
            }
            
        } catch {
            // Ignore this error
            Log.error("error during update info in keychain")
        }
    }
    
    public final func createTokenGenerationOperationIfNeeded() {
        guard tokenGenerationOperation == nil && braintreeClient == nil else {
            return
        }

        let operation = BraintreeTokenGenerationOperation()
        operationQueue.addOperation(operation)
        tokenGenerationOperation = operation
    }
    
    fileprivate final func createError(_ errorCode: BraintreeErrorCode) -> NSError {
        
        let message: String
        
        switch errorCode {
        case .unknown:
            message = "Please try again later"
            
        case .incorrectCardInfo:
            message = "Incorrect card info"
            
        case .incorrectAddressInfo:
            message = "Incorrect billing address info"
        }

        let userInfo: [String: AnyObject] = [NSLocalizedDescriptionKey: message as AnyObject]
        
        let res = NSError(domain: braintreeErrorDomain, code: errorCode.rawValue, userInfo: userInfo)
        
        return res
    }
}
