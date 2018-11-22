//
//  BorderedButtonTests.swift
//  PoqPlatform-UnitTests
//
//  Created by GabrielMassana on 29/11/2017.
//

import XCTest

@testable import PoqPlatform

class BorderedButtonTests: XCTestCase {

    func test_smallButtonText() {
        
        let buttonItem = BorderedButton.createButtonItem(withTitle: "S", target: self, action: #selector(SelectorTest.cancelButtonClick(_:)), width: nil)
        
        if let button = buttonItem.customView as? UIButton {
            
            XCTAssert(button.frame.size.width == 50.0, "Minimum size for Bordered Button is not working, should be 50.0")
        }
    }
    
    func test_longButtonText() {
        
        let buttonItem = BorderedButton.createButtonItem(withTitle: "SuperLongLongLongText", target: self, action: #selector(SelectorTest.cancelButtonClick(_:)), width: nil)

        if let button = buttonItem.customView as? UIButton {
            
            XCTAssert(button.frame.size.width > 50.0, "Minimum size for Bordered Button is not working, should be bigger than 50.0")
        }
    }
}

class SelectorTest {
    
    @objc public static func cancelButtonClick(_ sender: Any) {
    }
}
