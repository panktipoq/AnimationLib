//
//  Currency.swift
//  Poq.iOS.Platform
//
//  Created by Andrei Mirzac on 09/05/2018.
//

import Foundation

public struct Currency: Codable {
    
    /// Country
    public var countryName: String
    public var countryCode: String
    /// Currency
    public var code: String
    public var symbol: String
    
    enum CodingKeys: String, CodingKey {
        case code = "currencyCode"
        case countryName
        case countryCode
        case symbol
    }
    
    public init(countryName: String, countryCode: String, currencyCode: String, symbol: String) {
        self.countryCode = countryCode
        self.code = currencyCode
        self.countryName = countryName
        self.symbol = symbol
    }
    
//    public var description: String {
//        return [countryName, countryCode, code, symbol].joined(separator: ",")
//    }
}
