//
//  PoqCheckoutTrackable.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 09/11/2017.
//

import Foundation

public protocol PoqCheckoutTrackable {
    
    func beginCheckout(voucher: String, currency: String, value: Double, method: String)
    func checkoutUrlChange(url: String)
    func checkoutAddress(type: String, userId: String)
    func checkoutPayment(type: String, userId: String)
    func orderFailed(error: String)
    func orderSuccessful(voucher: String, currency: String, value: Double, tax: Double, delivery: String, orderId: Int, userId: String, quantity: Int, rrp: Double)
}

extension PoqCheckoutTrackable where Self: PoqAdvancedTrackable {
    
    public func beginCheckout(voucher: String, currency: String, value: Double, method: String) {
        let checkoutInfo: [String: Any] = [TrackingInfo.voucher: voucher, TrackingInfo.currency: currency, TrackingInfo.value: value, TrackingInfo.method: method]
        logEvent(TrackingEvents.Checkout.beginCheckout, params: checkoutInfo)
    }
    
    public func checkoutUrlChange(url: String) {
        let urlInfo: [String: Any] = [TrackingInfo.url: url]
        logEvent(TrackingEvents.Checkout.checkoutUrlChange, params: urlInfo)
    }
    
    public func checkoutAddress(type: String, userId: String) {
        let addressInfo: [String: Any] = [TrackingInfo.type: type, TrackingInfo.userId: userId]
        logEvent(TrackingEvents.Checkout.checkoutAddressChange, params: addressInfo)
    }
    
    public func checkoutPayment(type: String, userId: String) {
        let paymentInfo: [String: Any] = [TrackingInfo.type: type, TrackingInfo.userId: userId]
        logEvent(TrackingEvents.Checkout.checkoutPaymentChange, params: paymentInfo)
    }
    public func orderFailed(error: String) {
        let errorInfo: [String: Any] = [TrackingInfo.error: error]
        logEvent(TrackingEvents.Checkout.orderFailed, params: errorInfo)
    }
    
    public func orderSuccessful(voucher: String, currency: String, value: Double, tax: Double, delivery: String, orderId: Int, userId: String, quantity: Int, rrp: Double) {
        let orderInfo: [String: Any] = [TrackingInfo.voucher: voucher, TrackingInfo.currency: currency, TrackingInfo.value: value, TrackingInfo.tax: tax, TrackingInfo.delivery: delivery, TrackingInfo.transactionId: orderId, TrackingInfo.userId: userId, TrackingInfo.quantity: quantity, TrackingInfo.rrp: rrp]
        logEvent(TrackingEvents.Checkout.orderSuccessful, params: orderInfo)
    }
}
