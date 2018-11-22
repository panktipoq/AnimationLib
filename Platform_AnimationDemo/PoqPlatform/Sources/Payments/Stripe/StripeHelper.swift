//
//  StripeHelper.swift
//  Poq.iOS
//
//  Created by Gabriel Sabiescu on 05/07/2016.
//
//

import Locksmith
import PoqNetworking
import PoqUtilities
import Stripe
import UIKit

public typealias CardOperationCompletion = (_ error: NSError?) -> Void

struct StripeOperationDef {
    static let StripeErrorDomain: String = "StripeViewModelErrorDomain"
    static let StripeKeychainUser: String = "StripeViewModelKeychainUser"
    static let KeychainCustomerIdKey: String = "CustomerId"
    static let KeychainPreferredPaymentSourceIdKey: String = "PreferredPaymentSourceId"
}

public protocol StripeOperationProtocol: AnyObject {
    /**
     - parameter selectedPaymentSource: can be nil, we failed get create payment source or get info from Stripe API
     */
    func stripeOperationDidUpdateActivePaymentSource( selectedPaymentSource: PoqPaymentSource?, error: NSError?, hasChanged: Bool)
}

public class StripeHelper {
    
    var stripeCustomer: PoqStripeCustomer?
    
    /// Preffered payment source, can be defind by saves source id or by recent
    var preferredStripePaymentSource: PoqPaymentSource? {
        // This source make sence only while we have a customer with source: no customer -> no sources -> no preferred
        guard let customer = stripeCustomer, let sources = customer.sources, sources.count > 0 else {
            return nil
        }
        guard let index = sources.index(where: { return $0.paymentSourceToken == preferredPaymentSourceId }) else {
            preferredPaymentSourceId = sources.first?.paymentSourceToken
            return sources.first
        }
        return sources[index]
    }
    
    public static let sharedInstance = StripeHelper()
    
    // To keep this values between starts call 'updateKeychainValues' after change values
    fileprivate var customerId: String?
    fileprivate var preferredPaymentSourceId: String?
    
    /// StripeHelper should treat it as Logged In status
    internal var locksmithUserName: String? {
        guard let userName: String = LoginHelper.getEmail(), !userName.isNullOrEmpty() else {
            return nil
        }
        
        return StripeOperationDef.StripeKeychainUser + ":" + userName
    }
    
    private static var stripeApiInstance: STPAPIClient?
    
    open class func stripeApiClient() -> STPAPIClient {
        
        guard var stripeApiInstance = StripeHelper.stripeApiInstance else {
            let stripeApiInstance = STPAPIClient(publishableKey: AppSettings.sharedInstance.stripePublishableKey)
            StripeHelper.stripeApiInstance = stripeApiInstance
            return stripeApiInstance
        }
        
        //in case we already have an instance and the stripe key matches the one from MB we return same instance
        if stripeApiInstance.publishableKey != AppSettings.sharedInstance.stripePublishableKey {
            stripeApiInstance = STPAPIClient(publishableKey: AppSettings.sharedInstance.stripePublishableKey)
            StripeHelper.stripeApiInstance  = stripeApiInstance
        }
        
        return stripeApiInstance
    }
    
    public lazy var stripeCardValidator: StripeCardValidator = { [unowned self] in
        let cardValidator = StripeCardValidator()
        return StripeCardValidator()
        }()
    
    // TODO: after migrating network task on operation move it to
    public var delegate: StripeOperationProtocol?
    var addCardCompletion: CardOperationCompletion?
    var removeCardCompletion: CardOperationCompletion?
    
    required public init() {
        
        parseInitialUserData()
        // TODO: I can see here race condition: we may have requests running when logout happen. So we need find way to cancel all running requests
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: PoqUserDidLoginNotification), object: nil, queue: nil) { [weak self] (notification: Notification) in
            self?.parseInitialUserData()
        }
        
        // TODO: I can see here rais condition: we may have requests running when logout happen. So we need find way to cancel all running requests
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: PoqUserDidLogoutNotification), object: nil, queue: nil) { [weak self] (notification: Notification) in
            self?.customerId = nil
            self?.preferredPaymentSourceId = nil
            self?.stripeCustomer = nil
        }
    }
    
    public func checkUserCards(withBillingAddress address: PoqAddress?) {
        guard let billingAddress = address, let validCustomerId = customerId else {
            clearCustomer()
            return
        }
        self.stripeCardValidator.customerId = validCustomerId
        self.stripeCardValidator.billingAddress = billingAddress
        self.stripeCardValidator.checkUserCards()
    }
    
    // FIXME: #PLA-850 remove this when we decide remove reduntant code about post verification of card, which was done after adding froud protection for the first time
    public func removePaymentSourceWithId(_ paymentSourceId: String?) {
        guard let validPreferredPaymentSourceId = paymentSourceId, let validCustomerId = customerId else {
            return
        }
        
        PoqNetworkService(networkTaskDelegate: self).removePaymentSourceCustomer(validPreferredPaymentSourceId, fromCusomer: validCustomerId)
    }
    
    open func removePaymentPrefferedPaymentSource() {
        removePaymentSourceWithId(preferredPaymentSourceId)
    }
}

extension STPSource {
    
    func paymentSource(customerId: String?) -> PoqStripeKlarnaPaymentSource {
        let paymentSource = PoqStripeKlarnaPaymentSource(id: stripeID, customerId: customerId ?? "")
        return paymentSource
    }
    
}

extension StripeHelper: PoqNetworkTaskDelegate {
    
    public func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
    }
    
    public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        var hasChanged: Bool = false
        
        let responseCustomer: PoqStripeCustomer?
        let paymentSourcesList: [PoqPaymentSource]?
        
        switch networkTaskType {
        case PoqNetworkTaskType.stripeGetCards:
            guard let validCustomer = result?.first as? PoqStripeCustomer else {
                return
            }
            responseCustomer = validCustomer
            paymentSourcesList = validCustomer.sources
            
        case PoqNetworkTaskType.stripeAttachCard:
            
            if let paymentSource = result?.first as? PoqStripeCardPaymentSource, let validCustomer = stripeCustomer {
                
                validCustomer.sources?.append(paymentSource)
                
                responseCustomer = validCustomer
                paymentSourcesList = validCustomer.sources
                hasChanged = true
            } else {
                responseCustomer = stripeCustomer
                paymentSourcesList = stripeCustomer?.sources
                hasChanged = false
            }
    
        case PoqNetworkTaskType.stripeCreateSource:
            guard let source = result?.first as? STPSource else {
                return
            }           
            responseCustomer = stripeCustomer
            paymentSourcesList = stripeCustomer?.sources

            let paymentSource = source.paymentSource(customerId: responseCustomer?.id)
            paymentSourcesList?.append(paymentSource)
            
        case PoqNetworkTaskType.stripeCardTokenization:
            guard let token = result?.first as? STPToken else {
                return
            }
            responseCustomer = stripeCustomer
            paymentSourcesList = stripeCustomer?.sources
            if let cardId = token.card?.stripeID {
                attachTokenToCustomer(tokenId: cardId)
            }
    
        case PoqNetworkTaskType.createCustomer:
            
            if let validCustomer = result?.first as? PoqStripeCustomer {
                responseCustomer = validCustomer
                hasChanged = true
            } else {
                responseCustomer = nil
                hasChanged = false
            }
            paymentSourcesList = nil
            
        case PoqNetworkTaskType.stripeAttachCardCreateCustomer:
            
            if let validCustomer = result?.first as? PoqStripeCustomer, let sources = validCustomer.sources, sources.count > 0 {
                responseCustomer = validCustomer
                paymentSourcesList = sources
                hasChanged = true
            } else {
                responseCustomer = nil
                paymentSourcesList = nil
                hasChanged = false
            }
            
        case PoqNetworkTaskType.stripeCheckCardToken,
             PoqNetworkTaskType.stripeDeleteCardToken:
            // FIXME: Most likely we won't use it, since with times all card checked in advance.
            // There was a time when MSG didn't have validation
            guard let paymentSource = result?.first as? PoqStripeCardPaymentSource else {
                return
            }
            delegate?.stripeOperationDidUpdateActivePaymentSource(selectedPaymentSource: paymentSource, error: nil, hasChanged: false)
            responseCustomer = nil
            paymentSourcesList = nil
            hasChanged = networkTaskType == PoqNetworkTaskType.stripeDeleteCardToken
            
        default:
            Log.error("How we  parse unknow for a whil request type: \(networkTaskType)")
            responseCustomer = nil
            paymentSourcesList = nil
        }
        
        handleCustomerResponse(responseCustomer, paymnentSources: paymentSourcesList, selectRecentCard: false)
        
        if hasChanged {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PoqPaymentProviderWasUpdatedNotification), object: self)
        }
        
        if networkTaskType != .stripeCardTokenization {
            callCompletion(forTask: networkTaskType, withError: nil)  
        } 
    }
    
    public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        Log.error("Stripe request did fail")
        // I have to call completion here in this way, because we use delegate, and we can't pass addition info through
        callCompletion(forTask: networkTaskType, withError: error)
        delegate?.stripeOperationDidUpdateActivePaymentSource(selectedPaymentSource: nil, error: error, hasChanged: false)
    }
}

extension StripeHelper: PoqPaymentProvider {
    
    final public var paymentProviderType: PoqPaymentProviderType {
        return .Stripe
    }

    final public var customer: PoqPaymentCustomer? {
        return stripeCustomer
    }
    
    final public var preferredPaymentSource: PoqPaymentSource? {
        get {
            return preferredStripePaymentSource
        }
        set(newPreferredPaymentSource) {
            preferredPaymentSourceId = newPreferredPaymentSource?.paymentSourceToken
            updateKeychainValues(stripeCustomer?.id, prefferedSourceId: preferredPaymentSourceId)
            NotificationCenter.default.post(name: Notification.Name(rawValue: PoqPaymentProviderWasUpdatedNotification), object: self)
        }
    }
    
    final public func createApplePayToken(forPayment payment: PKPayment, completion: @escaping (_ token: String?, _ error: NSError?) -> Void) {
        StripeHelper.stripeApiClient().createToken(with: payment) { (stripeToken: STPToken?, error: Error?) in
            completion(stripeToken?.tokenId, error as NSError?)
        }
    }
    
    final public func createPaymentSource(_ paymentSourceParameters: PoqPaymentSourceParameters, completion: @escaping (_ error: NSError?) -> Void) {
        addCardCompletion = completion
        
        switch paymentSourceParameters {
        case .card(let card):
            guard card.expirationYear != nil, card.expirationMonth != nil, !card.cardNumber.isEmpty && !card.cvv.isEmpty else {
                DispatchQueue.main.async {
                    completion(NSError.errorWithMessage("Invalid card info"))
                }
                return
            }
            createPaymentSource(card: card, stripeClient: StripeHelper.stripeApiClient())
        case .klarna(let klarnaSource):
            createKlarnaPaymentSource(source: klarnaSource, stripeClient: StripeHelper.stripeApiClient())
        }
    }
    
    public func deletePaymentSource(_ paymentSource: PoqPaymentSource, completion: @escaping (_ error: NSError?) -> Void) {
        
        guard let validCustomerId = customerId else {
            
            DispatchQueue.main.async {
                completion(NSError.errorWithMessage("Invalid card info"))
            }
            return
        }
        
        removeCardCompletion = {
            [customer = stripeCustomer]
            (error: NSError?) in
            
            if let index: Int = customer?.sources?.index(where: { $0.paymentSourceToken == paymentSource.paymentSourceToken }) {
                customer?.sources?.remove(at: index)
            }
            
            completion(error)
        }
        
        // Here we use hidden knowledge that 'paymentSourceToken' is 'id' of stripe payment source
        PoqNetworkService(networkTaskDelegate: self).removePaymentSourceCustomer(paymentSource.paymentSourceToken, fromCusomer: validCustomerId)
    }
    
    final public func createCardCreationUIProvider() -> PoqPaymentCardCreationUIProvider? {
        return StripeCartCreationUIProvider()
    }
    
    /// Clear customer detail from keychain
    final public func clearCustomer() {
        
        stripeCustomer = nil
        preferredPaymentSourceId = nil
        customerId = nil
        
        guard let calidLosksmithUsername = locksmithUserName else {
            return
        }
        
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: calidLosksmithUsername)
            
        } catch {
            // Ignore this error
            Log.error("unable to remove data")
        }
    }
}

// MARK: - Private

extension StripeHelper {
    
    /**
     Hadle parsed response from API
     - parameter customerOrNil: Just arrived customer object if it existes in response.
     If some actions done on customer and response doesn't contain it - pass nil, we will pick up existed one
     - parameter paymnentSources: Parsed sources from API response, when user are not provided, if user provided from response, its sources will be used
     - parameter selectRecentCard: If true - we will change preffered source, if not, we will just update data and trying to keep preffered source
     */
    fileprivate final func handleCustomerResponse(_ customerOrNil: PoqStripeCustomer?, paymnentSources: [PoqPaymentSource]?, selectRecentCard: Bool) {
        
        // We have or we got custer, withiut it any action is meaningless
        guard let existedCustomer = (customerOrNil ?? stripeCustomer) else {
            Log.error("no customer")
            clearCustomer()
            return
        }
        
        stripeCustomer = existedCustomer
        
        // FIXME: check status codes for zipcode and cvv, and drop card if one of check failed
        if let providedSources = paymnentSources {
            stripeCustomer?.sources = providedSources
        }
        
        // We should update 'preferredStripePaymentSource'
        // For case of update - find saved method, in this case selectRecentCard == false
        // In case of adding new source, selectRecentCard == true and we get first
        if let sources: [PoqPaymentSource] = stripeCustomer?.sources {
            
            if selectRecentCard {
                
                preferredPaymentSourceId = sources.last?.paymentSourceToken
            }
        }
        
        customerId = stripeCustomer?.id
        
        if preferredPaymentSourceId == nil {
            preferredPaymentSourceId = stripeCustomer?.sources?.first?.paymentSourceToken
        }
        
        updateKeychainValues(customerId, prefferedSourceId: preferredPaymentSourceId)
    }
    
    /// Save data to keychain. Parameters are optional to simply usage, but if customerId == nil, nothing happen
    /// Note: we don't update inner help state, just values in keychain
    fileprivate final func updateKeychainValues(_ customerId: String?, prefferedSourceId: String?) {
        
        guard let existedCustomerId = customerId, let validLosksmithUsername = locksmithUserName else {
            // No customer id - no save operation
            return
        }
        
        var paymentMethodInfo = [String: AnyObject]()
        
        paymentMethodInfo[StripeOperationDef.KeychainCustomerIdKey] = existedCustomerId as AnyObject?
        
        if let selectedMethodId: String = preferredStripePaymentSource?.paymentSourceToken {
            paymentMethodInfo[StripeOperationDef.KeychainPreferredPaymentSourceIdKey] = selectedMethodId as AnyObject?
        }
        
        do {
            
            if let _ = Locksmith.loadDataForUserAccount(userAccount: validLosksmithUsername) {
                try Locksmith.updateData(data: paymentMethodInfo, forUserAccount: validLosksmithUsername)
            } else {
                try Locksmith.saveData(data: paymentMethodInfo, forUserAccount: validLosksmithUsername)
            }
            
        } catch {
            // Ignore this error
            Log.error("error during update info in keychain")
        }
    }
    
    /// Parse data from keychail for current user and sed request to API
    fileprivate final func parseInitialUserData() {
        guard let validLocksmithUsername = locksmithUserName else {
            return
        }
        
        let keychaindData: [String: Any]? = Locksmith.loadDataForUserAccount(userAccount: validLocksmithUsername)
        
        guard let existedData = keychaindData,
            let existedCustomerId: String = existedData[StripeOperationDef.KeychainCustomerIdKey] as? String else {
                return
        }
        
        customerId = existedCustomerId
        preferredPaymentSourceId = existedData[StripeOperationDef.KeychainPreferredPaymentSourceIdKey] as? String
        getCurrentCustomerDetails()
    }
    
    /// We have a one bad place - we save here completions, instead of attach it to operations
    /// To call callback from 3 differend responces we need one place to check is it correct operationfor completion
    fileprivate static func isAddCardOperation(_ networkTaskType: PoqNetworkTaskTypeProvider) -> Bool {
        let addCardOperations: [PoqNetworkTaskTypeProvider] = [PoqNetworkTaskType.stripeCardTokenization,
                                                               PoqNetworkTaskType.stripeAttachCard,
                                                               PoqNetworkTaskType.stripeAttachCardCreateCustomer]
        return addCardOperations.contains(where: { $0 == networkTaskType })
    }
    
    fileprivate static func isAddSourceOperation(_ networkTaskType: PoqNetworkTaskTypeProvider) -> Bool {
        let addCardOperations: [PoqNetworkTaskTypeProvider] = [PoqNetworkTaskType.stripeCreateSource,
                                                               PoqNetworkTaskType.stripeAttachCard,
                                                               PoqNetworkTaskType.createCustomer]
        return addCardOperations.contains(where: { $0 == networkTaskType })
    }
    
    fileprivate static func isRemoveCardOperation(_ networkTaskType: PoqNetworkTaskTypeProvider) -> Bool {
        return networkTaskType == PoqNetworkTaskType.stripeDeleteCardToken
    }
    
    /// This is one place to reduce damage from workaround, where we have to store completion just by type: add/remove
    /// Ideally later attach to task or make map: [PoqNetworkTaskTypeProvider: CardOperationCompletion]
    fileprivate final func callCompletion(forTask networkTaskType: PoqNetworkTaskTypeProvider, withError error: NSError?) {
        
        if StripeHelper.isRemoveCardOperation(networkTaskType) {
            removeCardCompletion?(error)
            removeCardCompletion = nil
        }
        
        if StripeHelper.isAddCardOperation(networkTaskType) || StripeHelper.isAddSourceOperation(networkTaskType) {
            addCardCompletion?(error)
            addCardCompletion = nil
        }
    }

    func createPaymentSource(card: PoqCard, stripeClient: STPAPIClient) {
        PoqNetworkService(networkTaskDelegate: self).createTokenWithPoqCard(card: card, stripeClient: stripeClient)
    }
    
    func createKlarnaPaymentSource(source: PoqKlarnaSource, stripeClient: STPAPIClient) {
        PoqNetworkService(networkTaskDelegate: self).createKlarnaTokenFromSource(source: source, stripeClient: stripeClient)
    }
    
    @nonobjc
    func attachTokenToCustomer( tokenId: String ) {
        if let existedCustomerId: String = customerId, !existedCustomerId.isNullOrEmpty() {
            let stripeTokenBody = PoqStripeTokenBody()
            stripeTokenBody.token = tokenId
            PoqNetworkService(networkTaskDelegate: self).attachTokenToCustomer(tokenId, toCustomer: existedCustomerId, tokenBody: stripeTokenBody)
        } else {
            let customerBody = PoqStripeCustomerBody()
            if let account = LoginHelper.getAccounDetails() {
                let fullName = String.combineComponents([account.firstName, account.lastName], separator: " ") ?? ""
                customerBody.token = tokenId
                customerBody.fullName = fullName
                customerBody.email = account.email?.nilForEmptyString()
                customerBody.dob = account.birthday?.nilForEmptyString()
                customerBody.customerNo = account.customerNo?.nilForEmptyString()
                customerBody.loyaltyCardNumber = account.loyaltyCardNumber?.nilForEmptyString()
            }
            PoqNetworkService(networkTaskDelegate: self).createCustomer(customerBody)
        }
    }
    
    @nonobjc
    public final func getCurrentCustomerDetails() {
        
        guard let existedCustomerId: String = customerId else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 0 )) {
                let error = NSError.errorWithMessage("There is no saved customer")
                guard let validDelegate = self.delegate, let validPreferredPaymentSource = self.preferredPaymentSource as? PoqStripeCardPaymentSource else {
                    return
                }
                validDelegate.stripeOperationDidUpdateActivePaymentSource(selectedPaymentSource: validPreferredPaymentSource, error: error, hasChanged: false )
            }
            return
        }
        PoqNetworkService(networkTaskDelegate: self).fetchStripeCustomerPaymentSources(forCustomerId: existedCustomerId)
    }
}
