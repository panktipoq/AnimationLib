//
//  CheckoutBagViewModel.swift
//  Poq.iOS
//
//  Created by Mahmut Canga on 03/09/2015.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import PassKit
import PoqNetworking
import Stripe

public class CheckoutBagViewModel: BagViewModel {

    public typealias CheckoutItemType = PoqCheckoutItem<PoqBagItem>

    public var checkoutItem: CheckoutItemType?

    // use this value to  keep request which we use to create
    public var lastUsedPaymentSummaryItems: [PKPaymentSummaryItem] = []

    override public func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {

        if networkTaskType == PoqNetworkTaskType.getCheckoutDetails {

            if let responeCheckoutItem = result?.first as? CheckoutItemType {

                let bagItemsResult = responeCheckoutItem.bagItems
                checkoutItem = responeCheckoutItem

                bagItems = bagItemsResult

                BagHelper().saveOrderId(responeCheckoutItem.poqOrderId)
                BadgeHelper.setNumberOfBagItems(bagItemsResult)

            } else {

                bagItems = []
            }
        } else if networkTaskType == PoqNetworkTaskType.postBag ||
            networkTaskType == PoqNetworkTaskType.removeVoucher ||
            networkTaskType == PoqNetworkTaskType.deleteBagItem ||
            networkTaskType == PoqNetworkTaskType.postDeliveryOption {

            getBag(true)
        }

        // Call super to hide activity indicator
        super.networkTaskDidComplete(networkTaskType, result: [])
    }

    override public func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {

        super.networkTaskDidFail(networkTaskType, error: error)
    }

    override public func setupPullToRefresh(_ tableView: UITableView?) {

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = AppTheme.sharedInstance.mainColor
        refreshControl.addTarget(self, action: #selector(CheckoutBagViewModel.startCheckoutRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView?.addSubview(refreshControl)
    }

    @objc fileprivate func startCheckoutRefresh(_ refreshControl: UIRefreshControl) {

        getBag(true)
        refreshControl.endRefreshing()
    }

    public func loadApplyVoucher() {

        let applyVoucherViewController: ApplyVoucherViewController = ApplyVoucherViewController(nibName: ApplyVoucherViewController.XibName, bundle: nil)
        applyVoucherViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        applyVoucherViewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        applyVoucherViewController.voucherDelegate =  self
        viewControllerDelegate?.present(applyVoucherViewController, animated: true, completion: nil)
    }

    public func loadLoginOptions() {

        let loginOptionsViewController: LoginOptionsViewController = LoginOptionsViewController(nibName: LoginOptionsViewController.XibName, bundle: nil)
        loginOptionsViewController.delegate = viewControllerDelegate
        //let navigationController:PoqNavigationViewController = PoqNavigationViewController(rootViewController: loginOptionsViewController)
        viewControllerDelegate?.present(loginOptionsViewController, animated: true, completion: nil)
    }

    public func applyVoucherCode(_ voucherCode: String) {

        let postVoucher: PoqPostVoucher = PoqPostVoucher()
        postVoucher.code = voucherCode
        postVoucher.orderId = BagHelper().getOrderId()

        PoqNetworkService(networkTaskDelegate: self).postVoucher(postVoucher)
    }

    public func getCheckoutTotal() -> Double? {

        guard let total = checkoutItem?.totalPrice else {

            return nil
        }

        return total
    }

    public func getCheckoutSubtotal() -> Double? {

        guard let total = checkoutItem?.subTotalPrice else {

            return nil
        }

        return total
    }

    public func getVoucherCode() -> String? {

        guard let vouchers = checkoutItem?.vouchers, vouchers.count > 0 else {

            return nil
        }

        guard let voucherCode = vouchers[0].voucherCode else {

            return nil
        }

        let voucher = voucherCode.contains(AppSettings.sharedInstance.studentVoucherCode) ? AppLocalization.sharedInstance.studentDiscountViewText : voucherCode

        return "\(voucher) :"
    }

    public func getVoucherAmount() -> String? {
        guard let vouchers = checkoutItem?.vouchers, vouchers.count > 0 else {

            return nil
        }

        guard let voucherValue = vouchers[0].value else {

            return nil
        }

        return voucherValue.toPriceString()
    }

    // if there is no items - return true
    public func isAllItemsInStockAndAvailable() -> Bool {

        var res: Bool = true

        for bagItem: PoqBagItem in bagItems {

            if let existedProduct: PoqProduct = bagItem.product, existedProduct.isOutOfStock() {

                res = false
                break
            }

            if bagItem.isUnavailable() {
                res = false
                break
            }
        }

        return res
    }
    override open func getBag(_ isRefresh: Bool = false) {
        let service = PoqNetworkService(networkTaskDelegate: self)
        let orderId = BagHelper().getOrderId()
        let _: PoqNetworkTask<JSONResponseParser<CheckoutItemType>> = service.getCheckoutDetails(orderId, isRefresh: isRefresh)

    }
}

// MARK: API communication

extension CheckoutBagViewModel {

    public func deleteVoucher() {
        if let orderId = BagHelper().getOrderId() {
            PoqNetworkService(networkTaskDelegate: self).deleteVoucher(orderId)
        }
    }

    public func getShipingMethods(_ deliveryAddress: PoqPostAddress) {

        guard let countryCode: String = deliveryAddress.shippingAddress?.countryId, !countryCode.isNullOrEmpty() else {
            // just ignore request - we know result
            self.networkTaskDidComplete(PoqNetworkTaskType.postAddresses, result: [])
            return
        }

        let orderid: Int = BagHelper().getOrderId() ?? 0
        let orderIdString: String = "\(orderid)"
        PoqNetworkService(networkTaskDelegate: self).postCheckoutAddress(orderIdString, postAddress: deliveryAddress)
    }

    public func postDeliveryOption(_ postDeliveryOption: PoqDeliveryOption) {

        postDeliveryOption.orderId = BagHelper().getOrderId()
        PoqNetworkService(networkTaskDelegate: self).postDeliveryOption(postDeliveryOption)
    }

}

extension CheckoutBagViewModel: ApplyVoucherDelegate {
    public func voucherAdded() {
        getBag(true)
    }
}
