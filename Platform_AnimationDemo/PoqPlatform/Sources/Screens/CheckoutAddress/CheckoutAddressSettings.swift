//
//  CheckoutAddressLabelNames.swift
//  Poq.iOS
//
//  Created by Antonia Chekrakchieva on 9/10/15.
//  Copyright (c) 2015 Poq. All rights reserved.
//

import Foundation

public enum AddressTextFieldsType: Int {
    case none           = 0
    case fisrtName      = 1
    case lastName       = 2
    case phone          = 3
    case addressLine1   = 4
    case addressLine2   = 5
    case postCode       = 6
    case city           = 7
    case county         = 8
    case country        = 9
    case email          = 10
    case company        = 11
    case addressName    = 12
    case state          = 13
    
    public var placehoderText: String {
        switch self {
        case .none: return ""
        case .fisrtName:
            return AppLocalization.sharedInstance.firstNameTextCheckout
        case .lastName:
            return AppLocalization.sharedInstance.lastNameTextCheckout
        case .phone:
            return AppLocalization.sharedInstance.phoneTextCheckout
        case .addressLine1:
            return AppLocalization.sharedInstance.addressTextCheckout
        case .addressLine2:
            return AppLocalization.sharedInstance.address2TextCheckout
        case .postCode:
            return AppLocalization.sharedInstance.postCodeTextCheckout
        case .city:
            return AppLocalization.sharedInstance.cityTextCheckout
        case .country:
            return AppLocalization.sharedInstance.countryTextCheckout
        case .email:
            return AppLocalization.sharedInstance.emailTextCheckout
        case .company:
            return AppLocalization.sharedInstance.companyCheckout
        case .county:
            return AppLocalization.sharedInstance.countyTextCheckout
        case .addressName:
            return AppLocalization.sharedInstance.addressNameTextCheckout
        case .state:
            return AppLocalization.sharedInstance.stateTextCheckout
        }
    }
    
    public func wrongValueText(forAddressType addressType: AddressType) -> String {
        
        let format: String?
        switch self {
        case .phone:
            format = AppLocalization.sharedInstance.enterValidTelephone
        case .addressLine1:
            format = AppLocalization.sharedInstance.enterValidAddress
        case .addressLine2:
            format = AppLocalization.sharedInstance.enterValidAddress
        case .postCode:
            format = AppLocalization.sharedInstance.enterValidPostCode
        case .city:
            format = AppLocalization.sharedInstance.enterValidCity
        case .country:
            format = AppLocalization.sharedInstance.enterValidCountry
        case .email:
            format = AppLocalization.sharedInstance.enterValidEmail
        case .addressName:
            format = AppLocalization.sharedInstance.enterValidAddressName
        case .state:
            format = AppLocalization.sharedInstance.enterValidState
        default:
            format = nil
        }
        
        guard let validFomat: String = format else {
            return placehoderText
        }
        
        let message: String
        switch addressType {
        case .Billing:
            message = AppLocalization.sharedInstance.addressTypeBilling
        case .AddressBook:
            message = AppLocalization.sharedInstance.addressTypeAddressBook
        case .Delivery:
            message = AppLocalization.sharedInstance.addressTypeDelivery
        case .NewAddress:
            message = AppLocalization.sharedInstance.addressTypeNewAddress
        }
        
        return String(format: validFomat, arguments: [message])
    }
}

extension UITextField {
    @nonobjc
    public var addressTextFieldsType: AddressTextFieldsType {
        return AddressTextFieldsType(rawValue: tag) ?? .none
    }
}


// FIXME: find proper usage and delete
public struct CheckoutAddressLabelNames {
    public static let SameAsBilling = AppLocalization.sharedInstance.sameAsBillingAddressText
    public static let Title = ""

}

public struct CheckoutAddressTextField {
    // we will put it in UITextField tag
    public let type: AddressTextFieldsType
    
    /// text value or countryId, for example.
    /// In case of country here will be country isoCode
    public var value: String?
    
    public var wrongValueMessage: String?
    
    public init(type: AddressTextFieldsType, value: String?) {
        self.type = type
        self.value = value
        wrongValueMessage = nil
    }
}

public enum CheckoutAddressElementType {
    case title
    case `import`
    case primaryBilling
    case primaryShipping
    case name
    case phone
    case addressLine1
    case addressLine2
    case postCode
    case city
    case county
    case country
    case email
    case company
    case deleteButton
    case addressName
    case state
    
    // FIXME: WTF??? remove and make picker as a keybard!!!!
    case countryPicker
    
    // return value, if label if full width text field, otherwise .None will be returned
    public var textFieldType: AddressTextFieldsType {
        let res: AddressTextFieldsType
        switch self {
        case .phone: res = .phone
        case .addressLine1: res = .addressLine1
        case .addressLine2: res = .addressLine2
        case .postCode: res = .postCode
        case .city: res = .city
        case .county: res = .county
        case .country: res = .country
        case .email: res = .email
        case .company: res = .company
        case .addressName: res = .addressName
        case .state: res = .state
            
        default:
            res = .none
        }
        
        return res
    }
}


public struct CheckoutAddressElement {

    public let type: CheckoutAddressElementType
    public var firstField: CheckoutAddressTextField?
    public var secondField: CheckoutAddressTextField? // we have exceptional case - 2 textfield on one cell: fist and last names
    
    public var parentContent: TableViewContent

    
    public init(type: CheckoutAddressElementType, firstField: CheckoutAddressTextField, secondField: CheckoutAddressTextField, parentContent: TableViewContent) {
        self.type = type
        self.firstField = firstField
        self.secondField = secondField
        self.parentContent = parentContent
    }
    
    public init(type: CheckoutAddressElementType, firstField: CheckoutAddressTextField, parentContent: TableViewContent) {
        self.type = type
        self.firstField = firstField
        self.secondField = nil
        self.parentContent = parentContent
    }
    
    public init(type: CheckoutAddressElementType, parentContent: TableViewContent) {
        self.type = type
        self.firstField = nil
        self.secondField = nil
        self.parentContent = parentContent
    }
}

public enum ValidationType {
    case none
    case email
    case phone
    case ukPostCode
    case usaZipCode
}

public enum CountryForValidate: String{
    case USA = "United States"
    case UK = "United Kingdom"
    case USAShort = "USA"
    case UKShort = "UK"
}

extension UIKeyboardType {

    public static func keyboardType(forTextFieldType type: AddressTextFieldsType?) -> UIKeyboardType {
        guard let existedType = type else {
            return .default
        }
        
        let res: UIKeyboardType
        switch existedType {
        case .email:
            res = .emailAddress
        case .phone:
            res = .phonePad
        default:
            res = .default
        }
        
        return res
    }
}
