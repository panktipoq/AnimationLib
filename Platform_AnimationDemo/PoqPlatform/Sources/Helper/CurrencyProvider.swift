//
//  CurrencyProvider.swift
//  Poq.iOS.Platform
//
//  Created by Andrei Mirzac on 24/05/2018.
//

import Foundation

/**
 Provides a currency preference.
 This value will be passed to the backend to return prices in a given currency.
 Depending on the client the currency may be a user chosen preference, or a default currency.
 See https://poqcommerce.atlassian.net/wiki/spaces/PLAT/pages/561381389/iOS+Enablement
 */
public class CurrencyProvider {
    
    /// The shared instance of the `CurrencyProvider`.
    public private(set) static var shared = CurrencyProvider()
    
    /// Resets the `shared` instance to a new instance of `CurrencyProvider`.
    // TODO: Potentially remove this function?
    public static func resetInstance() {
        shared = CurrencyProvider()
    }
    
    /// The fallback currency if no json file is loaded, and if the developer missed providing a json.
    /// The frontend must know the currency to display it with the correct symbol and formatting.
    /// The API needs it to make sure the frontend gets the correct currency data when displaying prices.
    private static let defaultCurrency = Currency(countryName: "United Kingdom", countryCode: "GB", currencyCode: "GBP", symbol: "£")
    
    /// An array of app supported currencies parsed from a provided `currencies.json` file.
    public static let availableCurrencies: [Currency] = {
        return File(forResource: "currencies", withExtension: "json").parse() ?? []
    }()
    
    /// The key used to store and retrieve a user selected currency.
    private static let storedCurrencyKey = "savedCurrencyKey"
    
    /// The last user selected currency, stored in UserDefaults.
    static var storedCurrency: Currency? {
        get {
            guard let data = UserDefaults.standard.object(forKey: storedCurrencyKey) as? Data else {
                return nil
            }
            return try? JSONDecoder().decode(Currency.self, from: data)
        }
        set {
            let encoded = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(encoded, forKey: storedCurrencyKey)
        }
    }
    
    /// The current currency used to display prices. This is the first found from:
    /// - The default hardcoded "GBP" if there isn’t a `currencies.json`.
    /// - The currency selected by the user in the country switcher.
    /// - The currency from `currencies.json` that matches the country selected by the user.
    /// - The first currency found in `currencies.json`.
    /// - The default hardcoded "GBP".
    public lazy private(set) var currency: Currency = {
        guard !CurrencyProvider.availableCurrencies.isEmpty else {
            assertionFailure("Couldn't find file currencies.json in the app bundle.")
            return CurrencyProvider.defaultCurrency
        }
        
        // Clients with currency switcher.
        if let currency = CurrencyProvider.storedCurrency {
            return currency
        }
        
        // Clients with country switcher.
        if let countrySettings = CountrySelectionViewModel.selectedCountrySettings() {
            guard let currency = CurrencyProvider.availableCurrencies.first(where: { $0.countryCode == countrySettings.isoCode }) else {
                assertionFailure("isoCode should match countryCode check your json file and country settings")
                return CurrencyProvider.defaultCurrency
            }
            return currency
        }
        
        // Default clients with one currency.
        guard let currency = CurrencyProvider.availableCurrencies.first else {
            return CurrencyProvider.defaultCurrency
        }
        
        return currency
    }()
    
    /// For clients with currency switcher, this allows the switcher to update and store the currency.
    /// - parameter currency: The currency to set and store.
    public func setCurrency(_ currency: Currency) {
        CurrencyProvider.storedCurrency = currency
        self.currency = currency
    }
}
