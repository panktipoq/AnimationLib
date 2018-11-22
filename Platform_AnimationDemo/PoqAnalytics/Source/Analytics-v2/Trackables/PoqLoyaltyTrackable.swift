//
//  PoqLoyaltyTrackable.swift
//  PoqPlatform
//
//  Created by Manuel Marcos Regalado on 09/11/2017.
//

import Foundation

public protocol PoqLoyaltyTrackable {
    func loyaltyVoucher(action: String, voucherId: Int)
}

extension PoqLoyaltyTrackable where Self: PoqAdvancedTrackable {

    public func loyaltyVoucher(action: String, voucherId: Int) {
        let voucherInfo: [String: Any] = [TrackingInfo.action: action, TrackingInfo.voucherId: voucherId]
        logEvent(TrackingEvents.Loyalty.voucherAction, params: voucherInfo)
    }
}
