//
//  MockProviderExtension.swift
//  PoqTesting
//
//  Created by Joshua White on 28/09/2017.
//

import Foundation
import ObjectMapper

@testable import PoqNetworking

// MARK: Optional Convenience Functions
public extension MockProvider {
    
    /// Parses an object from the specified json file located within this test's resources bundle.
    /// - parameter json: The name of the json file within this test's `resourcesBundleName`.bundle.
    /// - parameter type: The type of response object.
    /// - returns: The response object or nil if there was an issue.
    func responseObject<Type: Mappable>(forJson json: String, ofType type: Type.Type = Type.self) -> Type? {
        guard let data = responseData(forJson: json) else {
            return nil
        }
        
        let parsedResult = JSONResponseParser<Type>.parseResponse(from: data)
        
        guard let response = parsedResult.first as? Type else {
            print("ERROR::JSON:: ParsedResult has wrong type")
            return nil
        }
        
        return response
    }
    
    func responseObjects<Type: Mappable>(forJson json: String, ofType type: Type.Type = Type.self) -> [Type]? {
        guard let data = responseData(forJson: json) else {
            return nil
        }
        
        let parsedResult = JSONResponseParser<Type>.parseResponse(from: data)
        
        guard let response = parsedResult as? [Type] else {
            print("ERROR::JSON:: ParsedResult has wrong type")
            return nil
        }
        
        return response
    }
    
    func responseObjects<Type: Codable>(forJson json: String, ofType type: Type.Type = Type.self) -> [Type]? {
        guard let data = responseData(forJson: json) else {
            return nil
        }
        
        return try? JSONDecoder().decode([Type].self, from: data)
    }
}
