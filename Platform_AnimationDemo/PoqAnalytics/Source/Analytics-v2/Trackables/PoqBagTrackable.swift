//
//  PoqBagTrackable.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 09/11/2017.
//

import Foundation

public protocol PoqBagTrackable {
    func removeFromBag(productId: Int, productTitle: String)
    func clearBag()
    func bagUpdate(totalQuantity: Int, totalValue: Double)
    func removeFromWishlist(productId: Int)
    func clearWishlist()
    func applyVoucher(voucher: String)
    func applyStudentDiscount(voucher: String)
}

extension PoqBagTrackable where Self: PoqAdvancedTrackable {
    
    public func removeFromBag(productId: Int, productTitle: String) {
        let productInfo: [String: Any] = [TrackingInfo.productId: productId, TrackingInfo.productTitle: productTitle]
        logEvent(TrackingEvents.Bag.removeFromBag, params: productInfo)
    }
    
    public func clearBag() {
        logEvent(TrackingEvents.Bag.clearBag, params: nil)
    }
    
    public func bagUpdate(totalQuantity: Int, totalValue: Double) {
        let productInfo: [String: Any] = [TrackingInfo.quantity: totalQuantity, TrackingInfo.total: totalValue]
        logEvent(TrackingEvents.Bag.bagUpdate, params: productInfo)
    }
    
    public func removeFromWishlist(productId: Int) {
        let productInfo: [String: Any] = [TrackingInfo.productId: productId]
        logEvent(TrackingEvents.Bag.removeFromWishlist, params: productInfo)
    }
    
    public func clearWishlist() {
        logEvent(TrackingEvents.Bag.clearWishlist, params: nil)
    }
    
    public func applyVoucher(voucher: String) {
        let voucherInfo: [String: Any] = [TrackingInfo.voucher: voucher]
        logEvent(TrackingEvents.Bag.applyVoucher, params: voucherInfo)
    }
    
    public func applyStudentDiscount(voucher: String) {
        let voucherInfo: [String: Any] = [TrackingInfo.voucher: voucher]
        logEvent(TrackingEvents.Bag.applyStudentDiscount, params: voucherInfo)
    }
}
