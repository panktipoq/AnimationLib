//
//  BraintreePayPalPresentationProvider.swift
//  Poq.iOS.Boohoo
//
//  Created by Konstantin Bakalov on 3/29/17.
//
//

import Foundation

public protocol BraintreePayPalPresentationProvider {
    func presentation(for source: PoqBraintreePayPalPaymentSource) -> PoqPaymentSourcePresentation
}

class PlatformBraintreePayPalPresentationProvider: BraintreePayPalPresentationProvider {
    func presentation(for source: PoqBraintreePayPalPaymentSource) -> PoqPaymentSourcePresentation {
        let firstLine: String = "Paypal: " + (source.email ?? "")
        
        return PoqPaymentSourcePresentation(twoLinePresentation: (firstLine, nil), oneLinePresentation: firstLine, paymentMethodIconUrl: nil, cardIcon: nil)
    }
}
