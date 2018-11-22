//
//  BraintreeCardPresentationProvider.swift
//  Poq.iOS.Boohoo
//
//  Created by Konstantin Bakalov on 3/29/17.
//
//

import Foundation

public protocol BraintreeCardPresentationProvider {
    func presentation(for source: PoqBraintreeCardPaymentSource) -> PoqPaymentSourcePresentation
}

class PlatformBraintreeCardPresentationProvider: BraintreeCardPresentationProvider {
    func presentation(for source: PoqBraintreeCardPaymentSource) -> PoqPaymentSourcePresentation {
        let firstLine: String = (source.cardType ?? "").capitalized + " " + (source.last4 ?? "****")
        
        // FIXME: localize
        let secondLine: String = source.isDebit == true ? "DEBIT" : "CREDIT"
        
        var singleLine: String = (source.cardType ?? "").capitalized + " **** " + (source.last4 ?? "")
        if let postCode = source.billingAddress?.postCode, postCode.count > 0 {
            singleLine += " | \(postCode.capitalized)"
        }
        
        return PoqPaymentSourcePresentation(twoLinePresentation: (firstLine, secondLine), oneLinePresentation: singleLine, paymentMethodIconUrl: source.cardImageUrl, cardIcon: nil)
    }
}
