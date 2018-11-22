//
//  CountriesHelper.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 11/9/15.
//  Copyright © 2015 Poq. All rights reserved.
//

import Foundation

open class CountriesHelper {

    public static func convertCountrytoLongName(_ country: String?) -> String? {
        if country == CountryForValidate.USAShort.rawValue {
            return CountryForValidate.USA.rawValue
        }
        if country == CountryForValidate.UKShort.rawValue {
            return CountryForValidate.UK.rawValue
        }
        return country
    }
    
    public static func countryByIsoCode(_ isoCode: String) -> Country? {
        
        for country: Country in Countries.allValues {
            if country.isoCode.caseInsensitiveCompare(isoCode) ==  ComparisonResult.orderedSame {
                return country
            }
        }
        
        return nil
    }
    
    public static func countryByLongName(_ longName: String) -> Country? {
        
        for country: Country in Countries.allValues {
            if country.name.caseInsensitiveCompare(longName) ==  ComparisonResult.orderedSame {
                return country
            }
        }
        
        return nil
    }
}
