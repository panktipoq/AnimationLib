//
//  BraintreeCartCreationUIProvider.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 02/08/2016.
//
//

import Braintree
import Foundation

/**
 Will be used to provide Braintree SDK UI to create cards
 
 Note: Subclass from NSObject to confirm NSObjectProtocol for BTUICardFormViewDelegate
 */
class BraintreeCartCreationUIProvider: NSObject {
    var card: PoqCard = PoqCard()

    var isValid: Bool = false
    
    weak var delegate: PoqPaymentCardInputChangesDelegate?
}

extension BraintreeCartCreationUIProvider: PoqPaymentCardCreationUIProvider {
    
    final func registerReuseViews(withTableView tableView: UITableView?) {
        tableView?.register(BraintreeCardDetailTextFieldsCell.self, forCellReuseIdentifier: BraintreeCardDetailTextFieldsCell.ReuseIdentifier)
    }
    
    final func cardCreationCell(_ tableView: UITableView) -> UITableViewCell {

        let cell: BraintreeCardDetailTextFieldsCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: BraintreeCardDetailTextFieldsCell.ReuseIdentifier) as? BraintreeCardDetailTextFieldsCell {
            cell = dequeuedCell
            cell.braintreeCardForm?.delegate = self
        } else {

            cell = BraintreeCardDetailTextFieldsCell()
            cell.braintreeCardForm?.delegate = self
        }

        cell.braintreeCardForm?.number = card.cardNumber
        cell.braintreeCardForm?.cvv = card.cvv

        if let monthInt: Int = card.expirationMonth, let yearInt: Int = card.expirationYear {
            cell.braintreeCardForm?.setExpirationMonth(monthInt, year: yearInt)
        }

        return cell
    }
}

extension BraintreeCartCreationUIProvider: BTUICardFormViewDelegate {

    final func cardFormViewDidChange(_ cardFormView: BTUICardFormView?) {
        
        card.cardNumber = cardFormView?.number ?? ""
        
        card.cvv = cardFormView?.cvv ?? ""
        
        let expirationMonthString: String? = cardFormView?.expirationMonth
        let expirationYearString: String? = cardFormView?.expirationYear
        
        if let month: String = expirationMonthString, let year: String = expirationYearString,
            let monthInt: Int = Int(month), let yearInt: Int = Int(year) {
            card.expirationMonth = monthInt
            card.expirationYear = yearInt
        } else {
            card.expirationMonth = nil
            card.expirationYear = nil
        }
        
        isValid = cardFormView?.valid ?? false
        
        delegate?.cardInputWasChanged(self)
    }
    
    final func cardFormViewDidBeginEditing(_ cardFormView: BTUICardFormView?) { }
    
    final func cardFormViewDidEndEditing(_ cardFormView: BTUICardFormView?) { }
}
