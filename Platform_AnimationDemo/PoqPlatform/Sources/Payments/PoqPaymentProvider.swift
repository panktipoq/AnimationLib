//
//  PoqPaymentProvider.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 26/07/2016.
//
//

import Foundation
import PassKit
import PoqNetworking
import PoqUtilities
import ObjectMapper

/// Should be used to get information about changes in payment provider information. Any changes - custome, oreffered method, billing address
/// Object will be PoqPaymentProvider
public let PoqPaymentProviderWasUpdatedNotification: String = "PoqPaymentProviderWasUpdated"

/// List of all supported payments providers
public enum PoqPaymentProviderType: String {
    case Stripe = "stripe"
    case Braintree = "braintree"
    case Custom = "custom"
}

/// Available payment methods
public enum PoqPaymentMethod: String {
    case Card = "card"
    case PayPal = "paypal"
    case ApplePay = "applePay"
    case Klarna = "klarna"
}

public enum PoqCardNetwork: String {
    case Visa = "visa"
    case AmEx = "amex"
    case MasterCard = "mastercard"
    
    /// Return one of valid PKPaymentNetwok's constants
    public var pkPaymentNetwork: PKPaymentNetwork {
        switch self {
        case .Visa:
            return PKPaymentNetwork.visa
            
        case .AmEx:
            return PKPaymentNetwork.amex
            
        case .MasterCard:
            return PKPaymentNetwork.masterCard
        }
    }
}

public enum PoqPaymentSourceParameters {
    case card(PoqCard)
    case klarna(PoqKlarnaSource)
}

/// Simple card presentation to be passed between creation and payment provider
public struct PoqCard {
    
    public var cardNumber: String = ""
    
    public var cvv: String = ""
    
    public var expirationMonth: Int?
    public var expirationYear: Int?
    
    public var billingAddress: PoqAddress?
    
    public init() {
        // Stub
    }
}

public struct PoqKlarnaSource {
    
    public var amount: Double
    public var currency: String
    public var product: String = "payment"
    public var purchaseCountry: String
    public var email: String?
    public var shippingAddress: PoqAddress?
    public var billingAddress: PoqAddress
    
    public init(amount: Double, currency: String, purchaseCountry: String, email: String?, shippingAddress: PoqAddress?, billingAddress: PoqAddress) {
        self.amount = amount
        self.currency = currency
        self.purchaseCountry = purchaseCountry
        self.email = email
        self.shippingAddress = shippingAddress
        self.billingAddress = billingAddress
    }
}

public protocol PoqPaymentProvider: AnyObject {
    
    var paymentProviderType: PoqPaymentProviderType { get }
    
    /// Customer object, if we saved before any customer related information. Otherwise customer probable will be nil
    var customer: PoqPaymentCustomer? { get }
    
    /// If we didn't save any payment method, preferred method will be nil
    var preferredPaymentSource: PoqPaymentSource? { get set }
    
    /// Create one time token from Apple Pay payment.
    /// - parameter completion: will be called when token is ready or error occured
    func createApplePayToken(forPayment payment: PKPayment, completion: @escaping (_ token: String?, _ error: NSError?) -> Void)
    
    /// May return nil, if current provider doesn't support card payments, otherwise should not be nil
    /// Should be received once and used for car creation
    func createCardCreationUIProvider() -> PoqPaymentCardCreationUIProvider?
    
    /// Create card token and add to customer - it allow us use this card payment source any time later
    /// - parameter card: must be a valid card with valid billing address
    /// - parameter completion: will be called when token is ready or error occured
    func createPaymentSource(_ paymentSourceParameters: PoqPaymentSourceParameters, completion: @escaping (_ error: NSError?) -> Void)
    
    /// Delete payment source
    func deletePaymentSource(_ paymentSource: PoqPaymentSource, completion: @escaping (_ error: NSError?) -> Void)
}

/// Payment provider customer. Will be used to keep id and provide payment sources
public protocol PoqPaymentCustomer {
    
    var identifier: String { get }
    
    func paymentSources(forMethod method: PoqPaymentMethod) -> [PoqPaymentSource]
}

/// Payment source which can be added, deleted or used by user
/// Now supports Cards, Klarna, PayPal, Apple Pay
public protocol PoqPaymentSource: Mappable {

    /// Return privader type, aka breaintree or stripe. For paypal it always braintree
    var paymentProvidaer: PoqPaymentProviderType { get }

    // The payment source's customer id
    var sourceCustomerId: String { get }
    
    /// Return presentation of the payment source
    var presentation: PoqPaymentSourcePresentation { get }

    var paymentMethod: PoqPaymentMethod { get }

    /// It will be used for 2 reason - identify source and for sending as payment token
    var paymentSourceToken: String { get }
    
    var billingAddress: PoqAddress? { get }
}

/// While we modifing different values in card , wonna get update about card info and isValid changes
public protocol PoqPaymentCardInputChangesDelegate: AnyObject {
    
    func cardInputWasChanged(_ sender: PoqPaymentCardCreationUIProvider)
}

/// We have creation screen, which need some UI, usually it depends on payment provider, each of them provides its own UI
public protocol PoqPaymentCardCreationUIProvider {
    
    var card: PoqCard { get }
    
    var isValid: Bool { get }
    
    /// This should be weak.
    var delegate: PoqPaymentCardInputChangesDelegate? { get set }
    
    func registerReuseViews(withTableView tableView: UITableView?)
    
    func cardCreationCell(_ tableView: UITableView) -> UITableViewCell
}

/// Default presentation in list of card or in native checkout
public typealias TwoLinePaymentSourcePresentation = (firstLine: String, secondLine: String?)

public protocol PoqPaymentSourcePresentationable {
	/// Most likley for cards: first line is number, secon additional info
	/// For paypal will be only one line with email
	var twoLinePresentation: TwoLinePaymentSourcePresentation { get set }
	
	/// Put whole needed information in one line: type, number, postal code
	 var oneLinePresentation: String? { get set }
	
	/// Http link to icon of card, or paypal icon
	 var paymentMethodIconUrl: String? { get set }
		/// Local image asset of card icon
	 var cardIcon: UIImage? { get set }
}

/// Struct describe specifically presentation information
public struct PoqPaymentSourcePresentation: PoqPaymentSourcePresentationable {
    /// Most likley for cards: first line is number, secon additional info
    /// For paypal will be only one line with email
   public var twoLinePresentation: TwoLinePaymentSourcePresentation
    
    /// Put whole needed information in one line: type, number, postal code
   public var oneLinePresentation: String?
    
    /// Http link to icon of card, or paypal icon
   public var paymentMethodIconUrl: String?
    
    /// Local image asset of card icon
   public var cardIcon: UIImage?
    
    public init(twoLinePresentation: TwoLinePaymentSourcePresentation, oneLinePresentation: String?, paymentMethodIconUrl: String?, cardIcon: UIImage?) {
        
        self.twoLinePresentation = twoLinePresentation
        self.oneLinePresentation = oneLinePresentation
        self.paymentMethodIconUrl = paymentMethodIconUrl
        self.cardIcon = cardIcon
    }
	
	public init() {
		self.twoLinePresentation = (firstLine: "", secondLine: "")
	}
}

// MARK: - Implementations: Default and operators

public func == (left: PoqPaymentSource, right: PoqPaymentSource) -> Bool {

    /// Just in case compare providers too
    return left.paymentSourceToken == right.paymentSourceToken && left.paymentProvidaer == right.paymentProvidaer
}

/// Return map, where listed all available payment mthods, with corresponded payment provider for each of them
public func ParsePaymentProvidersMap() -> [PoqPaymentMethod: PoqPaymentProvider] {
    var res = [PoqPaymentMethod: PoqPaymentProvider]()
    
    guard let existedStringsMap: [String: String] = PListHelper.sharedInstance.paymentProviderMap() else {
        assert(false, "Looks like app interested in payment options, but plist doen't provide such information")
        return res
    }
    
    for (key, value) in existedStringsMap {
        
        guard let method = PoqPaymentMethod(rawValue: key), let providerType = PoqPaymentProviderType(rawValue: value) else {
                
                assert(false, "Unable to parse values in payment methods map. key = \(key), value = \(value)")
                continue
        }
        
        var provider: PoqPaymentProvider?
        switch providerType {
        case .Stripe:
            provider = StripeHelper.sharedInstance
            
        case .Braintree:
            provider = BraintreeHelper.sharedInstance
            
        case .Custom:
            Log.error("Custom payment provider refrenced but none provided. Use your own implementation of the ParsePaymentProvidersMap in bespoke app module to manage a separate payment provider")
        }

        guard let validProvider = provider else {
            continue
        }
        res[method] = validProvider
    }
    
    return res
}

public extension PoqPaymentSource {
    
    /// Lets assume that by defult we don't have info about billing address
    var billingAddress: PoqAddress? {
        return nil
    }
}
