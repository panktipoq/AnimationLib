//
//  CurrencySwitcherViewModel.swift
//  Poq.iOS.Platform
//
//  Created by Andrei Mirzac on 09/05/2018.
//

import Foundation
import ObjectMapper
import PoqUtilities

open class CurrencySwitcherViewModel: CurrencySwitcherService {
    
    weak public var presenter: CurrencySwitcherPresenter?
    public var content = [CurrencySection: [Currency]]()
    
    public var isCurrencySelected: Bool {
        return CurrencySwitcherViewModel.selectedCurrency != nil
    }
    
    public static var isCurrencySwitcherNeeded: Bool {
        if CountrySelectionViewModel.isCountrySelectionAvailable() {
            return false
        }
        if selectedCurrency != nil {
            return false
        }
        guard let unwrappedAvailableCurrencies = availableCurrencies, unwrappedAvailableCurrencies.count > 1 else {
            return false
        }
        return true
    }
    
    public static func saveSelectedCurrency(_ currency: Currency) {
        CurrencyProvider.shared.setCurrency(currency)
    }
    
    public static var availableCurrencies: [Currency]? {
        return CurrencyProvider.availableCurrencies
    }
    
    public static var selectedCurrency: Currency? {
        return CurrencyProvider.storedCurrency
    }
}
