//
//  StripeCartCreationUIProvider.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 02/08/2016.
//
//

import Foundation
import Stripe

/**
 Will be used to provide stripe SDK UI to create cards
 */
class StripeCartCreationUIProvider: NSObject {
    
    //var card: PoqCard = PoqCard()

    var stripeCard: STPCardParams?
    
    var isValid: Bool = false {
        didSet(oldValue) {
            if isValid != oldValue {
                delegate?.cardInputWasChanged(self)
            }
        }
    }
    
    weak var delegate: PoqPaymentCardInputChangesDelegate?
}

extension StripeCartCreationUIProvider: PoqPaymentCardCreationUIProvider {

    final func registerReuseViews(withTableView tableView: UITableView?) {
        tableView?.register(StripeCardDetailTextFieldsCell.self, forCellReuseIdentifier: StripeCardDetailTextFieldsCell.ReuseIdentifier)
    }
    
    final func cardCreationCell(_ tableView: UITableView) -> UITableViewCell {
        let cell: StripeCardDetailTextFieldsCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: StripeCardDetailTextFieldsCell.ReuseIdentifier) as? StripeCardDetailTextFieldsCell {
            cell = dequeuedCell
            cell.stripeCardFom?.delegate = self
        } else {
            cell = StripeCardDetailTextFieldsCell()
            cell.stripeCardFom?.delegate = self
        }
        
        if let validCardInfo = stripeCard {
            cell.stripeCardFom?.cardParams = validCardInfo
        }
        return cell
    }
    
    var card: PoqCard {
        var result = PoqCard()
        
        guard let validCardInfo = stripeCard else {
            return result
        }
        
        result.cardNumber = validCardInfo.number ?? ""
        
        result.cvv = validCardInfo.cvc ?? ""
        
        result.expirationMonth = Int(validCardInfo.expMonth)
        result.expirationYear = Int(validCardInfo.expYear)
        
        return result
    }
}

extension StripeCartCreationUIProvider: STPPaymentCardTextFieldDelegate {

    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {

        isValid = textField.isValid
        
        stripeCard = textField.cardParams
    }
    
    func paymentCardTextFieldDidBeginEditingNumber(_ textField: STPPaymentCardTextField) {
    }
    
    func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
    }
    
    func paymentCardTextFieldDidBeginEditingExpiration(_ textField: STPPaymentCardTextField) {
    }
}
