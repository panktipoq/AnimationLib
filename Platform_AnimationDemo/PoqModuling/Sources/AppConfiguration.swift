//
//  AppConfiguration.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 08/06/2016.
//
//

import Foundation
import PoqUtilities

// When we add new values, there is a risk we will forget move them from UAT to prod
// And we don't want to override existed app localization only because we forget set value
// So by default, if we got in /splash API empty localization, we ignore it
//
// But in same cases we really need override embeded localization with empty one
// In this cases use it in MB
public let PoqEmptyLocalizationValue = "{__EMPTY__}"

public protocol UpdateableCofiguration {
    
    func setAppsettingValue(_ value: String, forKey key: String)
}

/// Object which present one of 3 configurations: config, localization, theme 
/// Default implementation targeting NSObject subclass for Key-Value-Coding usage
public protocol AppConfiguration {

    var configurationType: PoqSettingsType { get }

    /// Run on array of settings and pick up only needed values
    func update(with settings: [PoqSetting])
    
    /// Set value from PoqSetting. Every specific type of settings can convert to needed value: like from "Arail:14" to UIFont
    /// NOTE: `type` provided for better type cast, since problem might appear with Bool or fonts, which presented by number
    func set(settingValue: String, for key: String, typeOf type: Any.Type?)
}

extension AppConfiguration where Self: NSObject {
    
    public func update(with settings: [PoqSetting]) {
        
        // First: get all children with non-nil label
        let children: [(label: String, value: Any)] = Mirror(reflecting: self).children.compactMap {  (child: Mirror.Child) in
            guard let label = child.label else {
                return nil
            }
            return (label, child.value)
        }
        
        // Second: make set of labels for intant check 'contains'
        let keysSet = Set<String>(children.map({ $0.label }))
        
        var childTypeMap = [String: Any.Type]()
        children.forEach {  (label: String, value: Any) in
            childTypeMap[label] = type(of: value)
        }
        
        // Set all settings (config, locale, theme) from CoreData
        for setting: PoqSetting in settings {
            
            guard let key: String = setting.key, let settingValue: String = setting.value else {
                continue
            }
            
            guard keysSet.contains(key) else {
                continue
            }
            
            let oldValue = value(forKey: key)
            set(settingValue: settingValue, for: key, typeOf: childTypeMap[key])
            
            Log.verbose("\(type(of: self)): \(key) is updated from \(String(describing: oldValue)) to \(settingValue)")
        }
        
        Log.verbose("\(type(of: self)): update \(settings.count) values")
    }
    
    public func set(settingValue: String, for key: String, typeOf type: Any.Type?) {
        
        let updatedValue: Any?
        switch configurationType {
        case .localization:
            updatedValue = convertLocalizationSetting(settingValue, typeOf: type)
        case .theme:
            updatedValue = convertThemeSetting(settingValue, for: key, typeOf: type)
        case .config: 
            updatedValue = convertConfigSetting(settingValue, typeOf: type)
        }

        guard let updatedValueUnwrapped = updatedValue else {
            Log.error("Smth going wrong and we got nil as setting values for \(key) key , which is not supported")
            return
        }

        setValue(updatedValueUnwrapped, forKey: key)
    }
    
    // MARK: - Private
    
    /// Conver string to one of theme types: font, color, double
    /// NOTE: key here needed for type verification
    fileprivate func convertThemeSetting(_ settingValue: String, for key: String, typeOf type: Any.Type?) -> Any? {
        
        // UIFont(name: "SourceSansPro-ExtraLight", size: 18) for fonts
        // UIColor.hexColor("#A6A6A6") for font colors, first two letters (99) in #99a6a6a6 is alpha value for the color
        
        if settingValue.contains("#") { // Set target as UIColor
            let color = UIColor.hexColor(settingValue)
            return color
        }
        
        if settingValue.contains(":") { // Set target as UIFont example value: SourceSansPro-ExtraLight:18
            
            // Set target as UIFont example value: SourceSansPro-ExtraLight:18
            if let separator: Range<String.Index> = settingValue.range(of: ":", options: []) {
                let fontName = settingValue[..<separator.lowerBound]
                let fontSize = settingValue[separator.upperBound...]
                if let validFontSize = Int(fontSize) {
                    if let font = UIFont(name: String(fontName), size: CGFloat(validFontSize)) {
                        return font
                    } else {
                        Log.warning("AppTheme: not valid name font size: \(settingValue)")
                    }
                }
            }
        }
        
        if type == Double.self, let doubleNumber = Double(settingValue) {
            // Here is a rise: what if someone did a stupid thing and put '16'(without : ) for font???
            // We should validate that current type of variable is double
            return doubleNumber
        }
        
        // We use CGFloat in AppTheme as well
        if type == CGFloat.self, let number = NumberFormatter().number(from: settingValue) {
            return CGFloat(truncating: number)
        }
        
        Log.error("AppTheme: \(settingValue) is not valid setting for theme")
        return nil
    }
    
    fileprivate func convertLocalizationSetting(_ settingValue: String, typeOf type: Any.Type?) -> Any? {
        
        if settingValue == PoqEmptyLocalizationValue {
            return ""
        } 
        
        guard !settingValue.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty else {
            return nil
        }
        
        // Check if it's nslocalised string, support NSLocalizes string from MB, so we can have a smooth immigration
        if settingValue.contains("_") {
            return settingValue.localizedPoqString
        }
        
        return settingValue
    }
    
    fileprivate func convertConfigSetting(_ settingValue: String, typeOf type: Any.Type?) -> Any? {
        
        /// We have problem with boolean values and its parsing
        if let typeUnwrapped = type, typeUnwrapped == Bool.self {
            return settingValue.toBool()
        }
        
        return settingValue
    }
}
