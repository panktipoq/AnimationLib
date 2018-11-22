//
//  AddressHelper.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 9/11/15.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation
import PoqNetworking

public enum AddressType: String {
    case Billing = "Billing"
    case Delivery = "Delivery"
    case AddressBook = "Address Book"
    case NewAddress = "New Address"
}

public class AddressHelper {
    
    public static func getTitle(_ addressType: AddressType, newBookAddress: Bool = true) -> String {

        if addressType == .Billing {
            return newBookAddress ? AppLocalization.sharedInstance.selectBillingAddressTitle : AppLocalization.sharedInstance.newBillingAddressTitle
        }
        
        if addressType == .Delivery{
            return newBookAddress ? AppLocalization.sharedInstance.selectDeliveryAddressTitle : AppLocalization.sharedInstance.newDeliveryAddressTitle
        }
        return addressType == .NewAddress ? AppLocalization.sharedInstance.newAddressTitle : AppLocalization.sharedInstance.editAddressTitle
    }
    
    public static func createFullAddress(_ address: PoqAddress?, showName: Bool = true) -> String {
        
        var nameComponents:[String] = []
        var addressComponents:[String] = []
        
        guard let validAddress = address else {
            return ""
        }

        if let firstName = validAddress.firstName, !firstName.isNullOrEmpty() && showName {
            nameComponents.append(firstName)
        }
        
        if let lastName = validAddress.lastName, !lastName.isNullOrEmpty() && showName {
            nameComponents.append(lastName)
        }
        
        if let address1 = validAddress.address1, !address1.isNullOrEmpty() {
            addressComponents.append(address1)
        }
        
        if let address2 = validAddress.address2, !address2.isNullOrEmpty() {
            addressComponents.append(address2)
        }
        
        if let city = validAddress.city, !city.isNullOrEmpty() {
            addressComponents.append(city)
        }
        
        if AppSettings.sharedInstance.shouldDisplayAddressState,
            let state = validAddress.state, !state.isNullOrEmpty() {
            addressComponents.append(state)
        }
        
        if let postCode = validAddress.postCode, !postCode.isNullOrEmpty() {
            addressComponents.append(postCode)
        }
        
        if AppSettings.sharedInstance.shouldDisplayAddressCountry,
            let country = validAddress.country, !country.isNullOrEmpty() {
            addressComponents.append(country)
        }
        
        guard let fullAddress = String.combineComponents([nameComponents.joined(separator: " "),addressComponents.joined(separator: ", ")], separator: "\n") else {
            return ""
        }

        return fullAddress
    }
}



