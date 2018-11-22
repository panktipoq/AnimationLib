//
//  OrderConfirmationPresenter.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 01/08/2016.
//
//

import Foundation
import PoqNetworking
import PoqUtilities

public protocol OrderConfirmationPresenter: AnyObject {
    
    associatedtype OrderItemType: OrderItem where OrderItemType: BagItemConvertable 
    associatedtype CheckoutItemType: CheckoutItem where CheckoutItemType.BagItemType == OrderItemType.BagItemType

    /**
     Unify present orderConfirmation for native checkout
     If Bag presented midally - just push, otherwise present modally
     - parameter viewController: view controller from which we should navigate to confirmation, for example order complete
     - parameter externalOrderId: External id of order, in case of MSG or PB, this is magento id, which lays in PoqMessage.magentoMessage
     - parameter checkoutItem: checkout item, which were send to API
     */
    
    func presentOrderConfirmation(_ viewController: PoqBaseViewController?, externalOrderId: String, checkoutItem: CheckoutItemType?, order: PoqOrder<OrderItemType>?)
}

extension OrderConfirmationPresenter {
    
    public func presentOrderConfirmation(_ viewController: PoqBaseViewController?, externalOrderId: String, checkoutItem: CheckoutItemType?, order: PoqOrder<OrderItemType>?) {
        
        guard let existedVC: PoqBaseViewController = viewController else {
            Log.error("How we wan't present anything without view controller???")
            return
        }
        
        var orderConfirmation: OrderConfirmationViewController<OrderItemType>?

        if let validOrder = order {
            orderConfirmation = OrderConfirmationViewController(order: validOrder)
        } else if let validCheckoutItem = checkoutItem {
            
            let order = PoqOrder<OrderItemType>(checkoutItem: validCheckoutItem)
            order.externalOrderId = externalOrderId
            order.orderKey = nil
            
            orderConfirmation = OrderConfirmationViewController(order: order)

        } else {
            orderConfirmation = OrderConfirmationViewController(orderKey: externalOrderId, externalOrderId: externalOrderId)
        }
        
        guard let validConfirmation = orderConfirmation else {
            return
        }
        
        validConfirmation.isOrderConfirmationPage = true
        
        if  let _ = existedVC.navigationController?.presentingViewController {
            existedVC.navigationController?.pushViewController(validConfirmation, animated: true)
        } else {
            
            let confirmationNavController: PoqNavigationViewController  = PoqNavigationViewController(rootViewController: validConfirmation)
            existedVC.present(confirmationNavController, animated: true) {
                // we need reset whole stack about bag - so
                _ = existedVC.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
