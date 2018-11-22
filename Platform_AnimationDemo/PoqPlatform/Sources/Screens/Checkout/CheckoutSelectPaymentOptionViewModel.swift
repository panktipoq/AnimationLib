//
//  CheckoutSelectPaymentOptionViewModel.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 19/07/2016.
//
//

import UIKit

/// PaymentOptionItem repesents model object for a cell
/// We have 'method' separately from 'paymentSource' for add source cell, where 'paymentSource' is nil and better to know which souce we wonna add
public struct PaymentOptionItem {
    public let method: PoqPaymentMethod
    public let paymentSource: PoqPaymentSource?
    public let isOnlyAddItemForWholeMethodSection: Bool
}

// TODO: refactor to make sections: [PaymentMethod: PoqPaymentProvider]. It means we can configure and make cards from Stripe, paypal from Braintree
class CheckoutSelectPaymentOptionViewModel: BaseViewModel {
    
    static let paymentMathodCellHeight: CGFloat = 65.0
    static let paymentSectionsIndent: CGFloat = 10.0
    
    /// we making sections by types
    var sections: Array<[PaymentOptionItem]> = []
    
    // reason to be a 'var': we will modify it with just selected paymentSource, to make it preffered
    var paymentProvidersMap: [PoqPaymentMethod: PoqPaymentProvider]
    
    init(paymentProvidersMap: [PoqPaymentMethod: PoqPaymentProvider], viewControllerDelegate: PoqBaseViewController?) {
        self.paymentProvidersMap = paymentProvidersMap
        if let validDelegate = viewControllerDelegate {
            super.init(viewControllerDelegate: validDelegate)
        } else {
            super.init()
        }
    }
}

// Mark: UIView configurations
extension CheckoutSelectPaymentOptionViewModel {
    
    /// regenerate payment options. Return true if we have at least 1 added payment source
    final func regenerateSectionItems(_ selectedPaymentSource: PoqPaymentSource?, showAddItems: Bool = true) {
        sections = CheckoutSelectPaymentOptionViewModel.createSectionItems(fromProvides: paymentProvidersMap, selectedPaymentSource: selectedPaymentSource, showAddItems: showAddItems)

    }
    
    /// Check sections array and all items inside for valid payment sources
    final func hasValidPaymentSources() -> Bool {
        let paymentSources: [PaymentOptionItem] = sections.flatMap({return $0}).filter({ return $0.paymentSource != nil })
        return paymentSources.count > 0
    }
}

// MARK: Private
extension CheckoutSelectPaymentOptionViewModel {
    fileprivate final class func createSectionItems(fromProvides providers: [PoqPaymentMethod: PoqPaymentProvider], selectedPaymentSource: PoqPaymentSource?, showAddItems: Bool = true) -> Array<[PaymentOptionItem]> {
        
        
        let useCards: Bool = providers[.Card] != nil
        let usePayPal: Bool = providers[.PayPal] != nil
        let useKlarna: Bool = providers[.Klarna] != nil
        
        var resArray = Array<[PaymentOptionItem]>()

        if useCards {
            var cardsArray = [PaymentOptionItem]()
            if let existedCards = providers[.Card]?.customer?.paymentSources(forMethod: .Card) {
                for cradPaymentSource in existedCards {
                    cardsArray.append(PaymentOptionItem(method: .Card, paymentSource: cradPaymentSource, isOnlyAddItemForWholeMethodSection: false))
                }
            }
            
            if showAddItems {
                let addCardItem  = PaymentOptionItem(method: .Card, paymentSource: nil, isOnlyAddItemForWholeMethodSection: cardsArray.count == 0)
                cardsArray.append(addCardItem)
            }
            
            resArray.append(cardsArray)
        }
        
        
        if usePayPal {
            var paypalArray = [PaymentOptionItem]()
            if let existedPaypals = providers[.PayPal]?.customer?.paymentSources(forMethod: .PayPal), existedPaypals.count > 0 {
                for paypalPaymentSource in existedPaypals {
                    paypalArray.append(PaymentOptionItem(method: .PayPal, paymentSource: paypalPaymentSource, isOnlyAddItemForWholeMethodSection: false))
                }
            } else {
                if (showAddItems) {
                    paypalArray.append(PaymentOptionItem(method: .PayPal, paymentSource: nil, isOnlyAddItemForWholeMethodSection: true))
                }
                
            }
            resArray.append(paypalArray)
        }
        
        if useKlarna {
            var klarnaArray = [PaymentOptionItem]()
            if let existedKlarnas = providers[.Klarna]?.customer?.paymentSources(forMethod: .Klarna), existedKlarnas.count > 0, let klarnaPaymentSource = existedKlarnas.first {
                    klarnaArray.append(PaymentOptionItem(method: .Klarna, paymentSource: klarnaPaymentSource, isOnlyAddItemForWholeMethodSection: true))
            } else {
                if (showAddItems) {
                    klarnaArray.append(PaymentOptionItem(method: .Klarna, paymentSource: nil, isOnlyAddItemForWholeMethodSection: true))
                }
            }
            resArray.append(klarnaArray)
        }
        
        
        if let validSelectedPaymentSource = selectedPaymentSource, validSelectedPaymentSource.paymentMethod != .Card {
            // even if only Pay pal available, [1] = [1].reverted(), so all is ok
            resArray = resArray.reversed()
        }
        
        return resArray
    }
}

