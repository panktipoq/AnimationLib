//
//  PoqAddressExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 30/11/2015.
//  Copyright © 2015 Poq. All rights reserved.
//

import Contacts
import Foundation
import PassKit
import PoqNetworking
import PoqUtilities

public extension PoqAddress {
    
    convenience init(contact: PKContact) {
        self.init()
        
        firstName = contact.name?.givenName
        lastName = contact.name?.familyName
        
        email = contact.emailAddress
        phone = contact.phoneNumber?.stringValue
        
        if let postalAddress: CNPostalAddress = contact.postalAddress {
            city = postalAddress.city
            postCode = postalAddress.postalCode
            
            address1 = postalAddress.street
            county = postalAddress.state
            countryId = postalAddress.isoCountryCode
            
            if countryId == nil || countryId!.isNullOrEmpty() {
                // bad situation - we don't have iso code, and we have only localized country name
                // lets try for while do full run on main thread, each time
                for isoCode in Locale.isoRegionCodes {
                    let localeId = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: isoCode])
                    let locale = Locale(identifier: Locale.current.identifier)
                    let displayName = (locale as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: localeId)
                    
                    if let existedDisplayName = displayName, existedDisplayName == postalAddress.country {
                        countryId = isoCode
                        break
                    }
                }
            }
            
            if let countryCode = countryId {
                country = CountriesHelper.countryByIsoCode(countryCode)?.name
            } else {
                Log.error("we didn't find such country")
            }
        }
    }
    
    convenience init(contact: CNContact, phoneNumberIndex: Int = 0, emailAddressIndex: Int = 0, postalAddressIndex: Int = 0) {
        self.init()
        
        if contact.isKeyAvailable(CNContactGivenNameKey) {
            firstName = contact.givenName
        }
        
        if contact.isKeyAvailable(CNContactFamilyNameKey) {
            lastName = contact.familyName
        }
        
        if contact.isKeyAvailable(CNContactOrganizationNameKey) {
            company = contact.organizationName
        }
        
        if contact.isKeyAvailable(CNContactPhoneNumbersKey), phoneNumberIndex >= 0, contact.phoneNumbers.count > phoneNumberIndex {
            let phoneNumber = contact.phoneNumbers[phoneNumberIndex].value
            
            phone = phoneNumber.stringValue
        }
        
        if contact.isKeyAvailable(CNContactEmailAddressesKey), emailAddressIndex >= 0, contact.emailAddresses.count > emailAddressIndex {
            let emailAddress = contact.emailAddresses[emailAddressIndex].value
            
            email = emailAddress as String
        }
        
        if contact.isKeyAvailable(CNContactPostalAddressesKey), postalAddressIndex >= 0, contact.postalAddresses.count > postalAddressIndex {
            let postalAddress = contact.postalAddresses[postalAddressIndex].value
            
            address1 = postalAddress.street
            
            city = postalAddress.city
            county = postalAddress.state
            postCode = postalAddress.postalCode
            
            countryId = postalAddress.isoCountryCode
            
            if let countryCode = countryId {
                country = CountriesHelper.countryByIsoCode(countryCode)?.name
            }
        }
    }
}
