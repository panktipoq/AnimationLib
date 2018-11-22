//
//  CountrySelectionViewModel.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 29/01/2016.
//
//

import UIKit

public typealias CountryObject = [String: String]
public typealias CountriesList = Array<CountryObject>

private let isoCodeKey: String = "isoCode"
private let appIdKey: String = "appId"
private let apiUrlKey: String = "apiUrl"
private let displayNameKey: String = "displayName"
private let facebookAppId: String = "facebookAppID"
private let facebookAppDisplayName: String = "facebookAppDisplayName"
public  let userDefaultsCountrySettingsKey: String = "UserDefaultsCountrySettingsKey"

public class CountrySelectionViewModel: BaseViewModel {
    
    /**
     An array that holds all available Countries.
     ````
     public typealias CountriesList = Array<CountryObject>
     public typealias CountryObject = [String: String]
     ````
     */
    var countries = CountriesList()
    
    /**
     Checks if a selected `CountrySettings` is persisted in UserDefaults
     for key _UserDefaultsCountrySettingsKey_. If a country has not yet
     been selected this function returns **true**.
     
     - Returns:
     **false** - if any `CountrySettings` are persisted in UserDefaults
     */
    class func isCountrySelectionNeeded() -> Bool {
       
        guard CountrySelectionViewModel.isCountrySelectionAvailable() else {
            return false
        }
        
        if CountrySelectionViewModel.selectedCountrySettings() != nil {
            return false
        }
        
        return true
    }
    
    /**
     Checks if array with available CountryObject(s) is provided in Info.plist
     under key `Poq_Countries_List`.
     
     - Returns:
     **true** - if an array of type `CountriesList` has been found in Info.plist
     */
    class func isCountrySelectionAvailable() -> Bool {
        
        guard let _: CountriesList = countriesPlistContent() else {
            return false
        }
        
        return true
    }
    
    override init() {
        super.init()
        parseCountriesList()
    }
    
    override init(viewControllerDelegate: PoqBaseViewController) {
        super.init(viewControllerDelegate: viewControllerDelegate)
        
        parseCountriesList()
    }

    func numberOfAvailableCounties() -> Int {
        return countries.count
    }
    
    public func getCell(forIndexPath indexPath: IndexPath, tableView: UITableView) -> CountrySelectionCell {
    
        guard let cell: CountrySelectionCell = tableView.dequeueReusablePoqCell() else {
            return CountrySelectionCell()
        }
    
        let countryObject: CountryObject = countries[indexPath.row]
    
        guard let countryCode: String = countryObject[isoCodeKey] else {
            return CountrySelectionCell()
        }
        
        if let displayName = countryObject[displayNameKey] {
            // Use display name if one exists and localize as necessary.
            cell.countryNameLabel.text = displayName.localizedPoqString
        } else {
            // Otherwise use the localised name of the country (in the user's language).
            let localeId = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCode])
            cell.countryNameLabel.text = Locale.autoupdatingCurrent.localizedString(forIdentifier: localeId)
        }
        
        let flagImageName = "flag_\(countryCode.lowercased())"
        cell.countryFlagImageView.image = ImageInjectionResolver.loadImage(named: flagImageName)
        
        return cell
    }
    
    /**
     Gets the current selected country from the available `CountriesList`,
     constructs a `CountrySettings` object, that is later saved into UserDefatuls
     for key _UserDefaultsCountrySettingsKey_.
     
     - Parameter index:
     the index of the current selected CountryObject in `countries` array
     */
    func saveSelectedCountrySettings(atIndex index: Int) {
        
        let countryObject: [String: String] = countries[index]

        guard let isoCodeString = countryObject[isoCodeKey], let appIdString = countryObject[appIdKey] else {
            assertionFailure("Missing isoCode or AppId in Country Plist!!!")
            return
        }
        
        let apiUrlStringValue = countryObject[apiUrlKey]
        let facebookAppIdValue = countryObject[facebookAppId]
        let facebookAppDisplayNameValue = countryObject[facebookAppDisplayName]
        
        let selectedCountry = CountrySettings(isoCode: isoCodeString, appId: appIdString, apiUrl: apiUrlStringValue, facebookAppId: facebookAppIdValue, facebookAppDisplayName: facebookAppDisplayNameValue)
        let data = NSKeyedArchiver.archivedData(withRootObject: selectedCountry)
        UserDefaults.standard.set(data, forKey: userDefaultsCountrySettingsKey)
        UserDefaults.standard.synchronize()
    }
    
    func appIdForCountryAtIndex(_ index: Int) -> String {
        
        let countryObject: [String: String] = countries[index]
        
        guard let appIdString: String = countryObject[appIdKey] else {
            return ""
        }
        return appIdString
    }
    
    /**
     - Parameter forCountryAtIndex:
     Index of selected country
     
     - Returns:
     Facebook AppId and AppDisplayName to be used in FBSDK Initialisation
     */
    func facebookAppCredentials(forCountryAtIndex index: Int) -> (facebookAppId: String?, facebookAppDisplayName: String?) {
        let countryObject: [String: String] = countries[index]
        return (facebookAppId: countryObject[facebookAppId], facebookAppDisplayName: countryObject[facebookAppDisplayName])
    }
    
    /**
     - Parameter appId:
     (MightyBot) AppID of a given Country
     
     - Returns:
     ISO code of the country with given (MightyBot) AppID
     */
    func countryIsoCode(forAppId appId: String) -> String {
        
        var resIsoCode: String = ""
        
        for countryObject in countries {
            if let currentAppId = countryObject[appIdKey], currentAppId == appId {
                if let resIsoCodeValue = countryObject[isoCodeKey] {
                    resIsoCode = resIsoCodeValue
                    break
                }
            }
        }
        
        return resIsoCode
    }
    
    /**
     When changing countries, the currently selected should not be listed as available option.
     Therefore, it is removed from the list of countries to choose from.
     */
    func removeCurrentCountryFromCountriesList() {
        
        guard let countrySettings = CountrySelectionViewModel.selectedCountrySettings() else {
            return
        }
        
        let index: Int? = countries.index(where: {
            (country: CountryObject) in
                country[appIdKey] == countrySettings.appId
            })
            
        if let currentCountryIndex = index {
            countries.remove(at: currentCountryIndex)
        }
        
    }
    
    /**
     Returns the CountrySettings saved in UserDefaults for key _UserDefaultsCountrySettingsKey_.
     
     - Returns:
     `nil` if no country settings has been saved yet
     */
    public class func selectedCountrySettings() -> CountrySettings? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsCountrySettingsKey),
            let countrySettings = NSKeyedUnarchiver.unarchiveObject(with: data) as? CountrySettings else {
                return nil
        }
        return countrySettings
    }
    
    /**
     - Returns:
     an array with ISO codes of all available countries
     */
    class func allCounryIsoCodes() -> [String] {

        guard let allCountries: [CountryObject] = Bundle(for: self).object(forInfoDictionaryKey: "Poq_Countries_List") as? [CountryObject] else {
            return []
        }
        
        var countriesIsoCode: [String] = []
        for country: CountryObject in allCountries {
            if let isoCode: String = country[isoCodeKey] {
                countriesIsoCode.append(isoCode)
            }
        }
        
        return countriesIsoCode
    }
    
    /**
     Opens the app Info.plist and search for key `Poq_Countries_List`.
     Then tries to convert the result to `CountriesList` and returns it.
     ````
     public typealias CountriesList = Array<CountryObject>
     public typealias CountryObject = [String: String]
     ````
     
     - Returns:
     an array of type CountriesList
     */
    public class func countriesPlistContent() -> CountriesList? {
        return Bundle.main.object(forInfoDictionaryKey: "Poq_Countries_List") as? CountriesList
    }
    
    // MARK: Private
    
    fileprivate func parseCountriesList() {
        guard let countries: [Dictionary<String, String>] = CountrySelectionViewModel.countriesPlistContent() else {
            return
        }
        
        self.countries = countries
    }
}
