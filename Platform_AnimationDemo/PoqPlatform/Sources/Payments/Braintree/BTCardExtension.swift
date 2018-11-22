//
//  BTCardExtension.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 02/08/2016.
//
//

import Braintree
import Foundation
import PoqNetworking

extension BTCard {
    
    /// Update crad with address and mark that card info should be validated with address
    final func updateAddress(withPoqAddress address: PoqAddress) {
        
        firstName = address.firstName
        
        lastName = address.lastName
        
        postalCode = address.postCode
        
        var addressString: String = address.address1 ?? ""
        if let address2 = address.address2 {
            if addressString.count > 0 {
                addressString += ", "
            }
            
            addressString += address2
        }
        
        streetAddress = addressString
        
        locality = address.city
        region = address.county
        
        countryName = address.country
        
        countryCodeAlpha2 = address.countryId
        
        shouldValidate = true
    }
}
