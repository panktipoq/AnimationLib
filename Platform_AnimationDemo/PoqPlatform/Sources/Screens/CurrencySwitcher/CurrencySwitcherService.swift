//
//  CurrencySwitcherService.swift
//  Poq.iOS.Platform
//
//  Created by Andrei Mirzac on 09/05/2018.
//

import Foundation
import PoqUtilities

/// CurrencySwitcherService defines methods and properties that a any currency switcher view model should follow.
/// Clients that want to provide their own currency switcher view model must conform to this protocol.
public protocol CurrencySwitcherService: class {
    
    /// Presenter that conforms to CurrencySwitcherPresenter.
    var presenter: CurrencySwitcherPresenter? { get set }
    
    /// This is property is datasource provided to currency tableView.
    var content: [CurrencySection: [Currency]] { get set }
    
    /// Represents the state of currency screen.
    var isCurrencySelected: Bool { get }
    
    /// Represents available currencies of the app.
    static var availableCurrencies: [Currency]? { get }
    
    /// Represents selected currency on currency switcher screen.
    static var selectedCurrency: Currency? { get }
    
    /// Determines if currencySwitchershould be presented on app launch.
    static var isCurrencySwitcherNeeded: Bool { get }
    
    /// Generates content to be displayed by currency switcher view controller.
    func generateContent()
    
    /// Static func that saves selected currency from the list of availabel currencies.
    static func saveSelectedCurrency(_ currency: Currency)
}

extension CurrencySwitcherService {
            
    public func generateContent() {
        
        content = [CurrencySection: [Currency]]()
        
        if let currency = Self.selectedCurrency {
            content[.selectedCurrency] = [currency]
        }
        
        if let currencies = Self.availableCurrencies {
            if let currentCurrency = content[.selectedCurrency]?.first {
                content[.availableCurrencies] = currencies.filter({ $0.code != currentCurrency.code })
            } else {
                content[.availableCurrencies] = currencies
            }
        }
    }
}
