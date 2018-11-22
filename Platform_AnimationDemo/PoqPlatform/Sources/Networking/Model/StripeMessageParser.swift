//
//  StripeMessageParsere.swift
//  Poq.iOS.Belk
//
//  Created by Nikolay Dzhulay on 11/17/16.
//
//

import Foundation
import PoqNetworking

class StripeMessageParser: PoqNetworkResponseParser {
    /// Convert string to sutable for 'delegate' type
    /// If response is a single object - just create array with one item
    static func parseResponse(from data: Data) -> [Any] {
        return []
    }
}
 
