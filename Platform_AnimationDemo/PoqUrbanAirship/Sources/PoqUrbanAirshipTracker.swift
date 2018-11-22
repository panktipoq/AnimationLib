//
//  PoqUrbanAirshipTracker.swift
//  PoqUrbanAirship
//
//  Created by Joshua White on 14/06/2018.
//

import AirshipKit
import Foundation
import PoqAnalytics

/// The Urban Airship analytics tracker to be added as a provider to the Analytics layer.
/// TODO: We are only tracking those that we originally used to track. We should refactor this.
public class PoqUrbanAirshipTracker: PoqTrackable {
    
    /// Whether or not Urban Airship should send tags tracking abandoned basket notifications.
    public var isAbandonedBagTaggingEnabled = false
    
    public func initProvider() {
    }
    
    /// Adds tags to the Urban Airship push object for this device.
    /// - parameter tags: The tag or tags to add.
    public func addTags(_ tags: String...) {
        UAirship.push()?.addTags(tags)
        UAirship.push()?.updateRegistration()
    }
    
    /// Removes tags from the Urban Airship push object for this device.
    /// - parameter tags: The tag or tags to remove.
    public func removeTags(_ tags: String...) {
        UAirship.push()?.removeTags(tags)
        UAirship.push()?.updateRegistration()
    }
    
}

// NOTE: Many below functions are unimplemented as previous implementation only tracked the specifically implemented events.
// TODO: We could hook up the advanced tracker and send all events to UA, but this needs investigation as to whether we should or not?
extension PoqUrbanAirshipTracker: PoqCatalogueTrackable {
    
    public func viewProduct(productId: Int, productTitle: String, source: String) {
    }
    
    public func viewProductList(categoryId: Int, categoryTitle: String, parentCategoryId: Int) {
    }
    
    public func viewSearchResults(keyword: String, type: String, result: String) {
    }
    
    public func addToBag(quantity: Int, productId: Int, productTitle: String, productPrice: Double, currency: String) {
        UAirship.analytics()?.add(UACustomEvent(name: "item_to_bag"))
        
        if isAbandonedBagTaggingEnabled {
            addTags("ItemsInBag", "NotCompletedCheckout")
        }
    }
    
    public func addToWishlist(quantity: Int, productTitle: String, productId: Int, productPrice: Double, currency: String) {
        UAirship.analytics()?.add(UACustomEvent(name: "add_to_wishlist"))
    }
    
    public func share(productId: Int, productTitle: String) {
        UAirship.analytics()?.add(UACustomEvent(name: "shared"))
    }
    
    public func barcodeScan(type: String, result: String, ean: String, productId: Int, productTitle: String) {
    }
    
    public func sortProducts(type: String) {
    }
    
    public func filterProducts(type: String, colors: String, categories: String, sizes: String, brands: String, styles: String, minPrice: Int, maxPrice: Int) {
    }
    
    public func peekAndPop(action: String, productId: Int, productTitle: String) {
    }
    
    public func fullScreenImageView(productId: Int, productTitle: String) {
    }
    
    public func readReviews(productId: Int, numberOfReviews: Int) {
    }
    
    public func videoPlay(productId: Int, productTitle: String) {
    }
    
    public func visualSearchSubmit(forSource: String, cropped: Bool) {
    }
    
    public func visualSearchResults(forResult: String, numberOfCategories: Int) {
    }
    
}

// NOTE: Many below functions are unimplemented as previous implementation only tracked the specifically implemented events.
// TODO: We could hook up the advanced tracker and send all events to UA, but this needs investigation as to whether we should or not?
extension PoqUrbanAirshipTracker: PoqBagTrackable {
    
    public func removeFromBag(productId: Int, productTitle: String) {
    }
    
    public func clearBag() {
        if isAbandonedBagTaggingEnabled {
            removeTags("ItemsInBag", "NotCompletedCheckout")
        }
    }
    
    public func bagUpdate(totalQuantity: Int, totalValue: Double) {
    }
    
    public func removeFromWishlist(productId: Int) {
    }
    
    public func clearWishlist() {
    }
    
    public func applyVoucher(voucher: String) {
    }
    
    public func applyStudentDiscount(voucher: String) {
    }
    
}

// NOTE: Many below functions are unimplemented as previous implementation only tracked the specifically implemented events.
// TODO: We could hook up the advanced tracker and send all events to UA, but this needs investigation as to whether we should or not?
extension PoqUrbanAirshipTracker: PoqCheckoutTrackable {
    
    public func beginCheckout(voucher: String, currency: String, value: Double, method: String) {
    }
    
    public func checkoutUrlChange(url: String) {
    }
    
    public func checkoutAddress(type: String, userId: String) {
    }
    
    public func checkoutPayment(type: String, userId: String) {
    }
    
    public func orderFailed(error: String) {
    }
    
    public func orderSuccessful(voucher: String, currency: String, value: Double, tax: Double, delivery: String, orderId: Int, userId: String, quantity: Int, rrp: Double) {
        if isAbandonedBagTaggingEnabled {
            removeTags("ItemsInBag", "NotCompletedCheckout")
        }
    }
    
}

extension PoqUrbanAirshipTracker: PoqMyAccountTrackable {
    
    public func signUp(userId: String, marketingOptIn: Bool, dataOptIn: Bool) {
        addTags("SignedUp")
    }
    
    public func login(userId: String) {
        addTags("LoggedIn")
    }
    
    public func logout(userId: String) {
        removeTags("LoggedIn")
    }
    
    public func addressBook(action: String, userId: String) {
    }
    
    public func editDetails(userId: String) {
    }
    
    public func switchCountry(countryCode: String) {
        let countryCodesForRemoval = Locale.isoRegionCodes.filter({ $0 != countryCode })
        UAirship.push()?.removeTags(countryCodesForRemoval)
        addTags(countryCode)
    }
    
}
