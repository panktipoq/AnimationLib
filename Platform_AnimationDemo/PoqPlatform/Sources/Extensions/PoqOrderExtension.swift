//
//  PoqOrderExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 09/03/2016.
//
//

import Foundation
import CoreLocation
import PoqNetworking
import PoqUtilities

public protocol BagItemConvertable {
    associatedtype BagItemType: BagItem
    
    init(bagItem: BagItemType)
}

extension PoqOrder where OrderItemType: BagItemConvertable {

    public convenience init(bagItems: [OrderItemType.BagItemType]) {
        self.init()

        platform = "iOS"
        orderItems = []
        
        for bagItem in bagItems {
            
            let orderItem = OrderItemType(bagItem: bagItem)
            orderItems?.append(orderItem)
        }
        
        totalPrice = CheckoutHelper.getBagItemsTotal(bagItems)
    }
    
    public convenience init<CheckoutItemType: CheckoutItem>(checkoutItem: CheckoutItemType) where CheckoutItemType.BagItemType == OrderItemType.BagItemType {
        
        self.init()

        platform = "iOS"
        orderItems = []
        
        let bagItems = checkoutItem.bagItems
        
        for bagItem in bagItems {
            
            let orderItem = OrderItemType(bagItem: bagItem)
            orderItems?.append(orderItem)
        }
        
        totalPrice = checkoutItem.totalPrice ?? CheckoutHelper.getBagItemsTotal(bagItems)
        subtotalPrice = checkoutItem.subTotalPrice

        if let existedVoucher: PoqVoucher = checkoutItem.vouchers?.first {
            voucherAmount = existedVoucher.value
            voucherCode = existedVoucher.voucherCode
            voucherTitle = existedVoucher.id

        }
        
        fullBillingAddress = AddressHelper.createFullAddress(checkoutItem.billingAddress)
        fullShippingAddress = AddressHelper.createFullAddress(checkoutItem.shippingAddress)
        
        updateAddressFields(withAddress: checkoutItem.billingAddress, typeOf: .Billing)
        updateAddressFields(withAddress: checkoutItem.shippingAddress, typeOf: .Delivery)
        
        deliveryOption = checkoutItem.deliveryOption?.title
        deliveryCost = checkoutItem.deliveryOption?.price
        
        // email parsed in the end bacause address updates, to avoud any overrides
        email = checkoutItem.shippingAddress?.email ?? checkoutItem.billingAddress?.email
    }
    
    public func updateOderWithUserLocation(_ location: CLLocation?) {
        
        if let existingLocation =  location {
                self.latitude = existingLocation.coordinate.latitude
                self.longitude = existingLocation.coordinate.longitude
        }
    }

}

extension PoqOrder {
    
    /// create address based on ivars. PoqAddress.id will be nil, most probably as well as countryId
    /// NOTE: works only with address in [.Billing, .Delivery]
    public func address(forType type: AddressType) -> PoqAddress? {
        let address = PoqAddress()
        
        switch type {
        case .Billing:
            // minor validation
            if firstName == nil && lastName == nil && self.address == nil && address2 == nil && city == nil && country == nil {
                return nil
            }
            address.email = email
            address.firstName = firstName
            address.lastName = lastName
            
            address.phone = phone
            
            address.address1 = self.address
            address.address2 = address2
            
            address.city = city
            address.county = state
            
            address.postCode = postCode
            
            address.county = country
            
            address.countryId = countryCode
            
            break
            
        case .Delivery:
            // minor validation
            if deliveryFirstName == nil && deliveryLastName == nil && deliveryAddress == nil && deliveryAddress2 == nil && deliveryCity == nil && deliveryCountry == nil {
                return nil
            }
            
            address.firstName = deliveryFirstName
            address.lastName = deliveryLastName
            
            address.phone = deliveryPhone
            
            address.address1 = deliveryAddress
            address.address2 = deliveryAddress2
            
            address.city = deliveryCity
            address.county = deliveryState
            
            address.postCode = deliveryPostCode
            
            address.county = deliveryCountry
            
            address.countryId = deliveryCountryCode
            break
            
        default:
            Log.error("We trying to get address of unsupported type: \(type). Supported: [.Billing, .Delivery]")
            return nil
        }
        
        return address
    }
    
    /// Update coresponded address fields. If adress is nil, all firlds become nil 
    open func updateAddressFields(withAddress address: PoqAddress?, typeOf type: AddressType) {
        
        switch type {
        case .Billing:
            
            email = address?.email
            firstName = address?.firstName
            lastName = address?.lastName
            
            phone = address?.phone
            
            self.address = address?.address1
            address2 = address?.address2
            
            city = address?.city
            state = address?.county
            
            postCode = address?.postCode
            
            country = address?.county
            
            countryCode = address?.countryId
            
            break
            
        case .Delivery:
            
            deliveryFirstName = address?.firstName
            deliveryLastName = address?.lastName
            
            deliveryPhone = address?.phone
            
            deliveryAddress = address?.address1
            deliveryAddress2 = address?.address2
            
            deliveryCity = address?.city
            deliveryState = address?.county
            
            deliveryPostCode = address?.postCode
            
            deliveryCountry = address?.county
            
            deliveryCountryCode = address?.countryId
            break
            
        default:
            Log.error("We trying to update address of unsupported type: \(type). Supported: [.Billing, .Delivery]")
        }
    }
}

