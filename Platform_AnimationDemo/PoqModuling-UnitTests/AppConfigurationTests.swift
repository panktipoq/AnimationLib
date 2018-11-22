//
//  File.swift
//  PoqPlatform-UnitTests
//
//  Created by Andrei Mirzac on 27/10/2017.
//

import Foundation
import XCTest
import UIKit

@testable import PoqModuling

// Acceptable types are UIColor, UIFont, Double, CGFloat
class AppThemeMock: NSObject, AppConfiguration {
    
    public static var sharedInstance: AppThemeMock = AppThemeMock()
    
    public let configurationType: PoqSettingsType = .theme
    
    @objc public var colorTheme: UIColor = UIColor.black
    @objc public var fontTheme: UIFont = UIFont.boldSystemFont(ofSize: 14)
    @objc public var doubleTheme: Double = 18
    @objc public var cgFloatTheme: CGFloat = 14
}

// Acceptable types are Bool, String, Double, CGFloat
class AppSettingsMock: NSObject, AppConfiguration {
    
    public static var sharedInstance: AppSettingsMock = AppSettingsMock()
    
    public let configurationType: PoqSettingsType = .config
    
    @objc public var boolSettingFromDouble: Bool = true
    @objc public var boolSetting: Bool = true
    @objc public var stringSetting: String = "Default String"
    @objc public var doubleSetting: Double = 1.0
    @objc public var cgFloatSetting: CGFloat = 1.0
}

// Acceptable types are String only
class AppLocalizationMock: NSObject, AppConfiguration {
    
    public static var sharedInstance: AppLocalizationMock = AppLocalizationMock()
    
    public let configurationType: PoqSettingsType = .localization
    
    @objc public var defaultTitle = "Default Title"
}

// Helpers
extension PoqSetting {
    
    static func poqSetting(key: String, value: String) -> PoqSetting {
        var setting = PoqSetting()
        setting.key = key
        setting.value = value
        return setting
    }
}

class AppConfigurationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    func testShouldParseAppLocalizationAsEmptySpaceWhenUsingSpecificSymbol() {
        
        let stringSetting = PoqSetting.poqSetting(key: "defaultTitle", value: PoqEmptyLocalizationValue)
        AppLocalizationMock.sharedInstance.update(with: [stringSetting])
        
        XCTAssert(AppLocalizationMock.sharedInstance.defaultTitle == "", "Empty String using symbol \(PoqEmptyLocalizationValue) hasn't been parsed in LocalizationSetting")
    }
    
    func testShouldNotParseAppLocalizationEmptySpace() {
        let stringSetting = PoqSetting.poqSetting(key: "defaultTitle", value: "")
        AppLocalizationMock.sharedInstance.update(with: [stringSetting])
        
        XCTAssert(AppLocalizationMock.sharedInstance.defaultTitle == "Default Title", "Empty String has been parsed in LocalizationSetting")
    }
    
    func testShouldParseLocalizationSettings() {
        let stringSetting = PoqSetting.poqSetting(key: "defaultTitle", value: "New Title")
        AppLocalizationMock.sharedInstance.update(with: [stringSetting])
        
        XCTAssert(AppLocalizationMock.sharedInstance.defaultTitle == "New Title", "String could not been parsed in LocalizationSetting")
    }
    
    func testShouldParseAppThemeSettings() {
        //TODO: Mirror string representation of var instead of hardcoded value
        let stringSetting = PoqSetting.poqSetting(key: "colorTheme", value: "#fffffff")
        let fontTheme = PoqSetting.poqSetting(key: "fontTheme", value: "Heebo-Light:18")
        AppThemeMock.sharedInstance.update(with: [stringSetting, fontTheme])
        
        XCTAssert(AppThemeMock.sharedInstance.colorTheme == UIColor.hexColor("#fffffff"), "Color could not been parsed in AppTheme")
        
        let font = AppThemeMock.sharedInstance.fontTheme
        let isSameFont = font.fontName == "Heebo-Light" && font.pointSize == 18.0
        XCTAssert(isSameFont, " Font could not been parsed in AppTheme")
    }
    
    func testShouldParseConfigSettings() {
        
        let boolSettingFromDouble = PoqSetting.poqSetting(key: "boolSettingFromDouble", value: "0")
        let boolSetting = PoqSetting.poqSetting(key: "boolSetting", value: "false")
        let stringSetting = PoqSetting.poqSetting(key: "stringSetting", value: "newStringValue")
        let doubleSetting = PoqSetting.poqSetting(key: "doubleSetting", value: "2.0")
        let cgFloatSetting = PoqSetting.poqSetting(key: "cgFloatSetting", value: "2.0")
        
        AppSettingsMock.sharedInstance.update(with: [boolSetting, stringSetting, doubleSetting, cgFloatSetting, boolSettingFromDouble])
        
        XCTAssert(AppSettingsMock.sharedInstance.boolSettingFromDouble == false, "Bool from double could not been parsed in AppSettings")
        XCTAssert(AppSettingsMock.sharedInstance.boolSetting == false, "Bool could not been parsed in AppSettings")
        XCTAssert(AppSettingsMock.sharedInstance.stringSetting == "newStringValue", "String could not been parsed AppSettings")
        XCTAssert(AppSettingsMock.sharedInstance.doubleSetting == 2.0, "Double could not been parsed AppSettings")
        XCTAssert(AppSettingsMock.sharedInstance.cgFloatSetting == 2.0, "CGFloat could not been parsed AppSettings")
    }

}

