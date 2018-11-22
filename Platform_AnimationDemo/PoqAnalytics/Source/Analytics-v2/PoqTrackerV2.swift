//
//  PoqTrackerV2.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 09/11/2017.
//

import Foundation
import PoqUtilities

/**
 You must register the `PoqAnalyticsModule` with the PoqPlatform before using tracking.
 
 TODO: Refactor TrackerV2 into just this class and change it to a non-singleton...
 TODO: Access through `PoqPlatform.shared.module(ofType: PoqAnalytics.self)`.
 
 This PoqTrackerV2 will contain all tracking providers for the App. It will also contain all defualt trackable implementation.
- **Adding Platform Tracking Providers:** In order to add platform default implementation of a tracking provider, you should call the funcion `add(_ providerTypes: [PoqPlatformProvidersType])`
 This method will take in an array of `PoqPlatformProvidersType` and loop through them initilising each one of them by creating a new instance of the Provider. To check what Provider Types are available to use, please check `PoqPlatformProviders`
 
 - **Adding Client Custom Tracking Providers:** In order to add a new custom provider from the client, you will need to create an object implementing the `PoqTrackable` as well as implementing and handling the specific tracking protocols. Please, find below an usage example:
 ## Usage Example: ##
 ````
 class CustomTracking: PoqAdvancedTrackable {
     func logEvent(_ name: String, params: [String : Any]?) {
         print("logEvent")
     }
 
     func initProvider() {
         print("initProvider")
     }
 }

 // This should be managed by the integration's module.
 // But for now this can sit in the AppDelegate's `setupModules`.
 PoqTrackerV2.shared.addProvider(CustomTracking())
 ````
*/
public class PoqTrackerV2 {
    
    /// Get providers publicly but only set them privately
    /// This enables writing extension for Tracker
    /// But also prevents removing tracking providers in runtime
    public private(set) var providers = [PoqTrackable]()

    public static let shared = PoqTrackerV2()
    
    /// Registers the specified tracking provider to receive and handle analytics events.
    /// - Parameter provider: The tracking provider to add.
    public func addProvider(_ provider: PoqTrackable) {
        providers.append(provider)
    }
    
    /// Removes the specified tracking provider from receiving and handling analytics events.
    /// - parameter provider: The tracking provider to remove.
    public func removeProvider(_ provider: PoqTrackable) {
        guard let index = providers.index(where: { $0 === provider }) else {
            Log.error("Unable find and remove the specified notification handler.")
            return
        }
        
        providers.remove(at: index)
    }
    
    /// This method will be called once all AppSettings are fetched so Providers an be initialised since AppSettings contain the Providers IDs, Keys, etc
    func initProviders() {
        for provider in providers {
            provider.initProvider()
        }
    }
    
    /// This method can be used to send custom events to available providers. Tracking providers only supporting key/value should implement this protocol.
    ///
    /// - Parameters:
    ///   - name: Name of the event to send
    ///   - params: An array of parameters to be sent along with the event
    public func logAdvancedEvent(_ name: String, params: [String: Any]) {
        
        let filteredName = filter(string: name)
        let filteredParams = filter(parameters: params)
        
        print("Custom event: \(filteredName)")
        print("Custom event: \(filteredParams)")
        
        providers.forEach {
            ($0 as? PoqAdvancedTrackable)?.logEvent(filteredName, params: filteredParams)
        }
    }
    
    /// This method can be used to send custom events to available providers. Tracking providers only supporting key/value should implement this protocol.
    ///
    /// - Parameters:
    ///   - name: Name of the event to send
    ///   - value: The value to send along with the event
    public func logSimpleEvent(_ name: String, value: Any) {
        
        let filteredName = filter(string: name)
        let filteredValue = filter(string: value as? String) 
        
        print("Custom event: \(filteredName)")
        print("Custom event: \(filteredValue)")
        
        providers.forEach {
            ($0 as? PoqSimpleTrackable)?.logSimpleEvent(filteredName, value: filteredValue)
        }
    }
}

extension PoqTrackerV2: PoqBagTrackable {
    
    public func removeFromBag(productId: Int, productTitle: String) {
        let filteredProductTitle = filter(string: productTitle)
        providers.forEach {
            ($0 as? PoqBagTrackable)?.removeFromBag(productId: productId, productTitle: filteredProductTitle)
        }
    }
    
    public func clearBag() {
        providers.forEach {
            ($0 as? PoqBagTrackable)?.clearBag()
        }
    }
    
    public func bagUpdate(totalQuantity: Int, totalValue: Double) {
        providers.forEach {
            ($0 as? PoqBagTrackable)?.bagUpdate(totalQuantity: totalQuantity, totalValue: totalValue)
        }
    }
    
    public func removeFromWishlist(productId: Int) {
        providers.forEach {
            ($0 as? PoqBagTrackable)?.removeFromWishlist(productId: productId)
        }
    }
    
    public func clearWishlist() {
        providers.forEach {
            ($0 as? PoqBagTrackable)?.clearWishlist()
        }
    }

    public func applyVoucher(voucher: String) {
        let filteredVoucher = filter(string: voucher)
        providers.forEach {
            ($0 as? PoqBagTrackable)?.applyVoucher(voucher: filteredVoucher)
        }
    }
    
    public func applyStudentDiscount(voucher: String) {
        let filteredVoucher = filter(string: voucher)
        providers.forEach {
            ($0 as? PoqBagTrackable)?.applyStudentDiscount(voucher: filteredVoucher)
        }
    }
}

extension PoqTrackerV2: PoqCatalogueTrackable {
    
    public func visualSearchSubmit(forSource: String, cropped: Bool) {
        let filteredForSource = filter(string: forSource)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.visualSearchSubmit(forSource: filteredForSource, cropped: cropped)
        }
    }
    
    public func visualSearchResults(forResult: String, numberOfCategories: Int) {
        let filteredForResult = filter(string: forResult)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.visualSearchResults(forResult: filteredForResult, numberOfCategories: numberOfCategories)
        }
    }
    
    public func viewProduct(productId: Int, productTitle: String, source: String) {
        let filteredProductTitle = filter(string: productTitle)
        let filteredSource = filter(string: source)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.viewProduct(productId: productId, productTitle: filteredProductTitle, source: filteredSource)
        }
    }
    
    public func viewProductList(categoryId: Int, categoryTitle: String, parentCategoryId: Int) {
        let filteredCategoryTitle = filter(string: categoryTitle)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.viewProductList(categoryId: categoryId, categoryTitle: filteredCategoryTitle, parentCategoryId: parentCategoryId)
        }
    }
    
    public func viewSearchResults(keyword: String, type: String, result: String) {
        let filteredKeyword = filter(string: keyword)
        let filteredType = filter(string: type)
        let filteredResult = filter(string: result)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.viewSearchResults(keyword: filteredKeyword, type: filteredType, result: filteredResult)
        }
    }
    
    public func addToBag(quantity: Int, productId: Int, productTitle: String, productPrice: Double, currency: String) {
        let filteredProductTitle = filter(string: productTitle)
        let filteredCurrency = filter(string: currency)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.addToBag(quantity: quantity, productId: productId, productTitle: filteredProductTitle, productPrice: productPrice, currency: filteredCurrency)
        }
    }
    
    public func addToWishlist(quantity: Int, productTitle: String, productId: Int, productPrice: Double, currency: String) {
        let filteredProductTitle = filter(string: productTitle)
        let filteredCurrency = filter(string: currency)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.addToWishlist(quantity: quantity, productTitle: filteredProductTitle, productId: productId, productPrice: productPrice, currency: filteredCurrency)
        }
    }
    
    public func share(productId: Int, productTitle: String) {
        let filteredProductTitle = filter(string: productTitle)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.share(productId: productId, productTitle: filteredProductTitle)
        }
    }
    
    public func barcodeScan(type: String, result: String, ean: String, productId: Int, productTitle: String) {
        let filteredType = filter(string: type)
        let filteredResult = filter(string: result)
        let filteredEAN = filter(string: ean)
        let filteredProductTitle = filter(string: productTitle)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.barcodeScan(type: filteredType, result: filteredResult, ean: filteredEAN, productId: productId, productTitle: filteredProductTitle)
        }
    }
    
    public func sortProducts(type: String) {
        let filteredType = filter(string: type)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.sortProducts(type: filteredType)
        }
    }
    
    public func filterProducts(type: String, colors: String, categories: String, sizes: String, brands: String, styles: String, minPrice: Int, maxPrice: Int) {
        let filteredType = filter(string: type)
        let filteredColors = filter(string: colors)
        let filteredCategories = filter(string: categories)
        let filteredSizes = filter(string: sizes)
        let filteredBrands = filter(string: brands)
        let filteredStyles = filter(string: styles)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.filterProducts(type: filteredType, colors: filteredColors, categories: filteredCategories, sizes: filteredSizes, brands: filteredBrands, styles: filteredStyles, minPrice: minPrice, maxPrice: maxPrice)
        }
    }
    
    public func peekAndPop(action: String, productId: Int, productTitle: String) {
        let filteredAction = filter(string: action)
        let filteredProductTitle = filter(string: productTitle)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.peekAndPop(action: filteredAction, productId: productId, productTitle: filteredProductTitle)
        }
    }
    
    public func fullScreenImageView(productId: Int, productTitle: String) {
        let filteredProductTitle = filter(string: productTitle)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.fullScreenImageView(productId: productId, productTitle: filteredProductTitle)
        }
    }
    
    public func readReviews(productId: Int, numberOfReviews: Int) {
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.readReviews(productId: productId, numberOfReviews: numberOfReviews)
        }
    }
    
    public func videoPlay(productId: Int, productTitle: String) {
        let filteredProductTitle = filter(string: productTitle)
        providers.forEach {
            ($0 as? PoqCatalogueTrackable)?.videoPlay(productId: productId, productTitle: filteredProductTitle)
        }
    }
}

extension PoqTrackerV2: PoqCheckoutTrackable {
    
    public func beginCheckout(voucher: String, currency: String, value: Double, method: String) {
        let filteredVoucher = filter(string: voucher)
        let filteredCurrency = filter(string: currency)
        let filteredMethod = filter(string: method)
        providers.forEach {
            ($0 as? PoqCheckoutTrackable)?.beginCheckout(voucher: filteredVoucher, currency: filteredCurrency, value: value, method: filteredMethod)
        }
    }
    
    public func checkoutUrlChange(url: String) {
        let filteredUrl = filter(string: url)
        providers.forEach {
            ($0 as? PoqCheckoutTrackable)?.checkoutUrlChange(url: filteredUrl)
        }
    }
    
    public func checkoutAddress(type: String, userId: String) {
        let filteredType = filter(string: type)
        let filteredUserId = filter(string: userId)
        providers.forEach {
            ($0 as? PoqCheckoutTrackable)?.checkoutAddress(type: filteredType, userId: filteredUserId)
        }
    }
    
    public func checkoutPayment(type: String, userId: String) {
        let filteredType = filter(string: type)
        let filteredUserId = filter(string: userId)
        providers.forEach {
            ($0 as? PoqCheckoutTrackable)?.checkoutPayment(type: filteredType, userId: filteredUserId)
        }
    }
    public func orderFailed(error: String) {
        let filteredError = filter(string: error)
        providers.forEach {
            ($0 as? PoqCheckoutTrackable)?.orderFailed(error: filteredError)
        }
    }
    
    public func orderSuccessful(voucher: String, currency: String, value: Double, tax: Double, delivery: String, orderId: Int, userId: String, quantity: Int, rrp: Double) {
        let filteredVoucher = filter(string: voucher)
        let filteredCurrency = filter(string: currency)
        let filteredDelivery = filter(string: delivery)
        let filteredUserId = filter(string: userId)
        providers.forEach {
            ($0 as? PoqCheckoutTrackable)?.orderSuccessful(voucher: filteredVoucher, currency: filteredCurrency, value: value, tax: tax, delivery: filteredDelivery, orderId: orderId, userId: filteredUserId, quantity: quantity, rrp: rrp)
        }
    }
}

extension PoqTrackerV2: PoqContentTrackable {
    
    public func onboarding(action: String) {
        let filteredAction = filter(string: action)
        providers.forEach {
            if let firebaseTracker = ($0 as? PoqContentTrackable) as? PoqFirebaseTracking {
                firebaseTracker.logOnboardingEvent(eventType: filteredAction)
            } else {
                ($0 as? PoqContentTrackable)?.onboarding(action: filteredAction)
            }
        }
    }
    
    public func appOpen(method: String, campaign: String) {
        let filteredMethod = filter(string: method)
        let filteredCampaign = filter(string: campaign)
        providers.forEach {
            ($0 as? PoqContentTrackable)?.appOpen(method: filteredMethod, campaign: filteredCampaign)
        }
    }
    
    public func bannerTap(bannerTitle: String, bannerType: String) {
        let filteredBannerTitle = filter(string: bannerTitle)
        let filteredBannerType = filter(string: bannerType)
        providers.forEach {
            ($0 as? PoqContentTrackable)?.bannerTap(bannerTitle: filteredBannerTitle, bannerType: filteredBannerType)
        }
    }
    
    public func lookbookTap(lookbookTitle: String, type: String, productId: Int, screenNumber: Int) {
        let filteredLookbookTitle = filter(string: lookbookTitle)
        let filteredType = filter(string: type)
        providers.forEach {
            ($0 as? PoqContentTrackable)?.lookbookTap(lookbookTitle: filteredLookbookTitle, type: filteredType, productId: productId, screenNumber: screenNumber)
        }
    }
    
    public func storeFinder(action: String, storeName: String) {
        let filteredAction = filter(string: action)
        let filteredStoreName = filter(string: storeName)
        providers.forEach {
            ($0 as? PoqContentTrackable)?.storeFinder(action: filteredAction, storeName: filteredStoreName)
        }
    }
    
    public func appStories(action: String, storyTitle: String, cardTitle: String) {
        let filteredAction = filter(string: action)
        let filteredStoryTitle = filter(string: storyTitle)
        let filteredCardTitle = filter(string: cardTitle)
        providers.forEach {
            ($0 as? PoqContentTrackable)?.appStories(action: filteredAction, storyTitle: filteredStoryTitle, cardTitle: filteredCardTitle)
        }
    }
}

extension PoqTrackerV2: PoqLoyaltyTrackable {

    public func loyaltyVoucher(action: String, voucherId: Int) {
        let filteredAction = filter(string: action)
        providers.forEach {
            ($0 as? PoqLoyaltyTrackable)?.loyaltyVoucher(action: filteredAction, voucherId: voucherId)
        }
    }
}

extension PoqTrackerV2: PoqMyAccountTrackable {
    
    public func signUp(userId: String, marketingOptIn: Bool, dataOptIn: Bool) {
        let filteredUserId = filter(string: userId)
        providers.forEach {
            ($0 as? PoqMyAccountTrackable)?.signUp(userId: filteredUserId, marketingOptIn: marketingOptIn, dataOptIn: dataOptIn)
        }
    }
    
    public func login(userId: String) {
        let filteredUserId = filter(string: userId)
        providers.forEach {
            ($0 as? PoqMyAccountTrackable)?.login(userId: filteredUserId)
        }
    }
    
    public func logout(userId: String) {
        let filteredUserId = filter(string: userId)
        providers.forEach {
            ($0 as? PoqMyAccountTrackable)?.logout(userId: filteredUserId)
        }
    }
    
    public func addressBook(action: String, userId: String) {
        let filteredAction = filter(string: action)
        let filteredUserId = filter(string: userId)
        providers.forEach {
            ($0 as? PoqMyAccountTrackable)?.addressBook(action: filteredAction, userId: filteredUserId)
        }
    }
    
    public func editDetails(userId: String) {
        let filteredUserId = filter(string: userId)
        providers.forEach {
            ($0 as? PoqMyAccountTrackable)?.editDetails(userId: filteredUserId)
        }
    }
    
    public func switchCountry(countryCode: String) {
        let filteredCountryCode = filter(string: countryCode)
        providers.forEach {
            ($0 as? PoqMyAccountTrackable)?.switchCountry(countryCode: filteredCountryCode)
        }
    }
}

public protocol PoqSimpleTrackable: PoqTrackable {
    
    /// This method can be used to send custom events to available providers. Tracking providers only supporting key/value should implement this protocol.
    ///
    /// - Parameters:
    ///   - name: Name of the event to send
    ///   - value: The value to send along with the event
    func logSimpleEvent(_ name: String, value: Any)
}

public protocol PoqAdvancedTrackable: PoqTrackable {
    
    /// This method can be used to send custom events to available providers. Tracking providers only supporting key/value should implement this protocol.
    ///
    /// - Parameters:
    ///   - name: Name of the event to send
    ///   - params: An array of parameters to be sent along with the event
    func logEvent(_ name: String, params: [String: Any]?)
}

extension PoqTrackerV2 {
    
    /// Parses all parameter values that are strings in the dictionary to filter out emails, replacing them with {email}.
    internal final func filter(parameters: [String: Any]) -> [String: Any] {
        var parametersUnwrapped = parameters
        for pair in parametersUnwrapped {
            if let paramValue = pair.value as? String {
                parametersUnwrapped[pair.key] = filter(string: paramValue)
            }
        }
        return parametersUnwrapped
    }
    
    /// Parses the specified tracking string to filter out emails, replacing them with {email}.
    public final func filter(string: String?) -> String {
        
        guard let filterString = string else {
            return ""
        }
        
        let mutableString = NSMutableString(string: filterString)
        
        // Parse all emails in the tracking string and replace them with {email}
        if let emailRegex = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}") {
            let range = NSRange(location: 0, length: mutableString.length)
            emailRegex.replaceMatches(in: mutableString, options: [], range: range, withTemplate: "{email}")
        }
        
        return mutableString as String
    }
}
