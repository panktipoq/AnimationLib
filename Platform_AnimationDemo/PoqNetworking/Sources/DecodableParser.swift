//
//  DecodableParser.swift
//  PoqNetworking
//
//  Created by Balaji Reddy on 18/06/2018.
//

import Foundation

import PoqUtilities

/**
 This is a generic class that conforms to the PoqNetworkResponseParser. It can be used to parse the network
 response provided by PoqNetworkTask into any Decodable type that the class is constrained to, using the Swift JSONDecoder.
 */
public class DecodableParser<T: Decodable>: PoqNetworkResponseParser {
    
    public static func parseResponse(from data: Data) -> [Any] {
        
        do {

            let parsedResult = try JSONDecoder().decode(T.self, from: data)
            return [parsedResult as Any]
            
        } catch {
            Log.error(error.localizedDescription)
        }

        return []
    }
}
