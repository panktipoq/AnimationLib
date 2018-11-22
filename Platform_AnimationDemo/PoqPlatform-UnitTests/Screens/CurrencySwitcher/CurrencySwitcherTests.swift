//
//  CurrencySwitcherTests.swift
//  PoqPlatform-UnitTests
//
//  Created by Andrei Mirzac on 16/05/2018.
//

import XCTest

@testable import PoqDemoApp
@testable import PoqNetworking
@testable import PoqPlatform

class CurrencySwitcherTests: XCTestCase {
    
    var stubCurrencies: [Currency] {
        guard let currencies = responseObjects(forJson: "currencies", ofType: Currency.self) else {
            XCTFail("Can't parse currencies got nil response")
            return []
        }
        return currencies
    }
    
    /// MARK: - Helpers
    func topViewController() -> CurrencySwitcherViewController? {
        let viewcontroller = CurrencySwitcherViewController(nibName: CurrencySwitcherViewController.XibName, bundle: nil)
        UIApplication.shared.keyWindow?.rootViewController = viewcontroller
        return viewcontroller
    }
    
    func testSavingCurrency() {
        
        CurrencySwitcherViewModel.saveSelectedCurrency(stubCurrencies[0])
        
        guard let savedCurrency = CurrencySwitcherViewModel.selectedCurrency else {
            XCTFail("Expected currency to be saved")
            return
        }
        
        XCTAssert(savedCurrency.code == "GBP", "Expected currency with code GBP")
        XCTAssert(savedCurrency.countryCode == "GB", "Expected currency with countryCode GB")
        XCTAssert(savedCurrency.symbol == "£", "Expected currency with symbol £")
    }
    
    func testSelectingCurrencyShouldUpdateSymbol() {
        CurrencySwitcherViewModel.saveSelectedCurrency(stubCurrencies[0])
        XCTAssert(CurrencyProvider.shared.currency.symbol == stubCurrencies[0].symbol, "Chaging currency should update the symbol")
    }
    
    func testIfCurrencySwitcherNeeded() {
        CurrencySwitcherViewModel.saveSelectedCurrency(stubCurrencies[0])
        XCTAssert(CurrencySwitcherViewModel.isCurrencySwitcherNeeded == false, "After saving currency to userdefault we shouldn't need to present CurrencySwitcher")
    }
    
    func testNumberOfCurrencyCellsMatchAvailableCurrencies() {
        let viewController = topViewController()
        _  = viewController?.view
        
        guard let currencies = viewController?.service.content[.availableCurrencies] else {
            XCTFail(" Expect non nil currencies object")
            return
        }
        
        XCTAssert(viewController?.tableView?.numberOfRows(inSection: 1) == currencies.count, "Number of currency cells should match number of currencies in json file")
    }
    
    func testSelectedCurrencyIsDisplayedOnCountrySwitcherScreen() {
        
        let stubCurrency = stubCurrencies[0]
        CurrencySwitcherViewModel.saveSelectedCurrency(stubCurrency)
        
        let viewController = topViewController()
        _  = viewController?.view
        
        XCTAssert(viewController?.tableView?.numberOfRows(inSection: 0) == 1, "Number of currency cells should be equal to 1")
        guard let cell = viewController?.tableView?.cellForRow(at: IndexPath(item: 0, section: 0)) as? CurrencySwitcherCell else {
            XCTFail("Expected CurrencySwitcherCell cell type")
            return
        }
        
        if let currencyLabelText = cell.currencyLabel?.text {
            XCTAssert(currencyLabelText == "\(stubCurrency.countryName)" + " (\(stubCurrency.code))", "Cell text doesn't match with the selected currency")
        } else {
            XCTFail("Currency label has empty text")
        }
    }
}
