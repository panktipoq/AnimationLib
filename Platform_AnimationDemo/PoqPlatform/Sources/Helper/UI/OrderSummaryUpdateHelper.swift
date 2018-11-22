//
//  OrderSummaryUpdateHelper.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 10/13/16.
//
//

import Foundation


public class OrderSummaryUpdateHelper {
    
    // Pop up message should be shown only when we have proper pop up message for the step update
    public static func showSuccessPopUpMessage(_ step: CheckoutStep) {

        guard let updatedInformationMessage = messageForStep(step) else{
            return
        }
        PopupMessageHelper.showMessage("icn-done", message: updatedInformationMessage)
        
    }
    
    fileprivate static func messageForStep(_ step: CheckoutStep) -> String? {
        switch step{
        case .paymentMethod:
            return AppLocalization.sharedInstance.orderSummaryPaymentMethodMessageUpdate
        case .billingAddress:
            return AppLocalization.sharedInstance.orderSummaryBillingAddressMessageUpdate
        case .shippingAddress:
            return AppLocalization.sharedInstance.orderSummaryShippingAddressMessageUpdate
        case .deliveryMethod:
            return AppLocalization.sharedInstance.orderSummaryDeliveryMethodMessageUpdate
        default:
            return nil
        }
    }
}
