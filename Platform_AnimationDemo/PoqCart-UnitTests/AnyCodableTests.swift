//
//  AnyCodableTests.swift
//  PoqDemoApp
//
//  Created by Balaji Reddy on 14/06/2018.
//

import Foundation
import XCTest
import PoqUtilities

@testable import PoqCart

public class AnyCodableTests: XCTestCase {
    
    func testDecodeDictionary() {
        
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
            
            let decodedDict = decodedAnyCodable?.value as? [String: AnyCodable]
            
            XCTAssertNotNil(decodedDict, "Did not decode to a Dictionary of type [String: AnyCodable]")
            
        } else {
            
            XCTFail("Could not get Data from Json")
        }
    }
    
    func testDecodeArray() {
        
        let arrayJson: String = """
            [
              "R2D2",
               1,
              true,
              "C3PO"
            ]
        """
        
        if let arrayJsonData = arrayJson.data(using: .utf8) {
            
            let decodedAnyCodable = try? JSONDecoder().decode(AnyCodable.self, from: arrayJsonData)
            
            let decodedArray = decodedAnyCodable?.value as? [Any]
            
            XCTAssertNotNil(decodedArray, "Did not decode to an array of type [Any]")
            
        } else {
            
            XCTFail("Could not get Data from Json")
        }
        
    }
    
}
