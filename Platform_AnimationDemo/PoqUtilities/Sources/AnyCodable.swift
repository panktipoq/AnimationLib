//
//  AnyCodable.swift
//  PoqNetworking
//
//  Created by Balaji Reddy on 12/06/2018.
//  Copyright © 2018 Balaji Reddy. All rights reserved.
//

import Foundation

/**
 A type-erased Codable value
 The `AnyCodable` type decodes and encodes to and from String, Int, Float, Bool, Dictionary<String, AnyCodable> and Array<AnyCodable>
 You can decode and encode arbitrary types using AnyCodable
 
 ````
 let dictionaryJson: String = """
    {
     "merchandiseTotal": 128.0,
     "totalVoucherSavings": 0.0,
     "shippingSurcharge": 0.0,
     "estimatedShipping": 0.0,
     "estimatedSalesTax": 10.57
     }
 """
 
 if let dictionaryJsonData = dictionaryJson.data(using: .utf8) {
 
    let decodedAnyCodable = try? JSONDecoder().decode(AnyCodable.self, from: dictionaryJsonData)
 }
 
 ````
*/
public struct AnyCodable: Codable {
    
    private(set) public var value: Any?
    
    public init(_ value: Any? = nil) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode([String: AnyCodable].self) {
            self.value = value
        } else if let value = try? container.decode([AnyCodable].self) {
            self.value = value
        } else if let value = try? container.decode(String.self) {
            self.value = value
        } else if let value = try? container.decode(Int.self) {
            self.value = value
        } else if let value = try? container.decode(Float.self) {
            self.value = value
        } else if let value = try? container.decode(Bool.self) {
            self.value = value
        } else if container.decodeNil() {
            self.value = nil
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Invalid Json. Could not decode to AnyCodable"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.singleValueContainer()
        
        switch value {
        case let dict as [String: AnyCodable]:
            try? container.encode(dict)
        case let arr as [AnyCodable]:
            try? container.encode(arr)
        case let str as String:
            try? container.encode(str)
        case let int as Int:
            try? container.encode(int)
        case let float as Float:
            try? container.encode(float)
        case let bool as Bool:
            try? container.encode(bool)
        case nil :
            try? container.encodeNil()
        default:
           throw EncodingError.invalidValue(self, .init(codingPath: container.codingPath, debugDescription: "Cannot encode value as AnyCodable"))
        }
    }
    
    /// This is a generic convenience method to decode an AnyCodable type to the type it the method is constrained to
    /// It encodes the AnyCodable into json and decodes it back to the type inferred
    public func decode<T: Decodable>() -> T? {
        
        guard let encodedData = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        return try? JSONDecoder().decode(T.self, from: encodedData)
    }
}
