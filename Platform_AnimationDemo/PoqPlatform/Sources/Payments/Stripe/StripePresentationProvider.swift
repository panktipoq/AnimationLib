//
//  StripePresentationProvider.swift
//  Poq.iOS.Boohoo
//
//  Created by Konstantin Bakalov on 3/29/17.
//
//

import Foundation

public protocol StripePresentationProvider {
    func presentation(for source: PoqStripeCardPaymentSource) -> PoqPaymentSourcePresentation
}

class PlatformStripePresentationProvider: StripePresentationProvider {
    func presentation(for source: PoqStripeCardPaymentSource) -> PoqPaymentSourcePresentation {
        let firstLine = (source.brand ?? "") + " xxxx xxxx xxxx " + (source.last4 ?? "****")
        let singleLine = (source.brand ?? "") + " **** " + (source.last4 ?? "")
        
        return PoqPaymentSourcePresentation(twoLinePresentation: (firstLine, nil), oneLinePresentation: singleLine, paymentMethodIconUrl: nil, cardIcon: nil)
    }
}
