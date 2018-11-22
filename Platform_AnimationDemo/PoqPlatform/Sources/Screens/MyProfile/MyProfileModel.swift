//
//  MyProfileModel.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 10/25/16.
//
//

import Foundation
import PoqNetworking

public enum MyProfileControlTag: Int {
    case none = 0
    case firstNameTextField = 1
    case lastNameTextField = 2
    case emailTextField = 3
    case passwordTextField = 4
    case dataSharingSwitch = 5
    case promotionSwitch = 6
    case mastercardSwitch = 7
    case termsAndConditionsSwitch = 8
    case dateField = 9
    case phoneField = 10
    
    public var contentItemType: MyProfileContentItemType? {
        switch self {
        case .firstNameTextField:
            return .name
        case .lastNameTextField:
            return .name
        case .emailTextField:
            return .email
        case .passwordTextField:
            return .password
        case .dataSharingSwitch:
            return .dataSharing
        case .promotionSwitch:
            return .promotion
        case .mastercardSwitch:
            return .mastercard
        case .termsAndConditionsSwitch:
            return .termsAndConditions
        case .dateField:
            return .date
        case .phoneField:
            return .phone
        default:
            return nil
        }
    }
}

public enum MyProfileContentItemType {
    case headerImage
    case title
    case name
    case email
    case password
    case date
    case datePicker
    case promotion
    case submitButton
    case dataSharing
    case mastercard
    case cardImage
    case gender
    case webView
    case termsAndConditions
    case dateField
    case phone
}

extension MyProfileContentItemType {
    public var cellIdentifier: String {
        switch self {
        case .headerImage:
            return LoginHeaderTableViewCell.poqReuseIdentifier
        case .title:
            // TODO: Suprise! MyProfileTitle -> MyProfileAddressBookTitleTableViewCell. Remove this strange dependency, addresses is addresses, my profile is my profile
            return MyProfileAddressBookTitleTableViewCell.poqReuseIdentifier
        case .name:
            return TwoTextfieldsTableViewCell.poqReuseIdentifier
        case .email, 
             .password,
             .phone:
            return FullwidthTextFieldCellTableViewCell.poqReuseIdentifier
        case .date:
            return EditMyProfieDateCell.poqReuseIdentifier
        case .datePicker:
            return DatePickerTableViewCell.poqReuseIdentifier
        case .submitButton:
            return ButtonTableViewCell.poqReuseIdentifier
        case .promotion, .dataSharing, .mastercard, .termsAndConditions:
            return SwitchTableViewCell.poqReuseIdentifier
        case .webView:
            return WebviewTableViewCell.poqReuseIdentifier
        case .cardImage:   
            return ImageTableViewCell.poqReuseIdentifier
        case .gender:
            return GenderTableViewCell.poqReuseIdentifier
        case .dateField:
            return DateTableViewCell.poqReuseIdentifier
        }
    }
}

/// Most common usage for configuration of UITextField
public struct MyProfileInputItem {

    public let title: String?
    public var value: String? // contextual usage. May be text of UITextField, may be html body of page, may be link to image
    
    public let controlTag: MyProfileControlTag
    
    public let config: FloatLabelTextFieldConfig?
    
    public init (title: String?) {
        self.title = title
        self.value = nil
        self.controlTag = .none
        self.config = nil
    }
    
    public init (title: String?, value: String?) {
        self.title = title
        self.value = value
        self.controlTag = .none
        self.config = nil
    }
    
    public init (title: String?, value: String?, controlTag: MyProfileControlTag) {
        self.title = title
        self.value = value
        self.controlTag = controlTag
        self.config = nil
    }
    
    public init (title: String?, value: String?, controlTag: MyProfileControlTag, config: FloatLabelTextFieldConfig) {
        self.title = title
        self.value = value
        self.controlTag = controlTag
        self.config = config
    }
}

/// Presentation of cell in MyProfile section. It may have 2 imput text field, thats why we have 2 input items
/// Each cell can use firstInputItem.value for its own purpose, some can keep date in string form, some book in string format  
public struct MyProfileContentItem {

    public let type: MyProfileContentItemType
    public let cellHeight: CGFloat

    /// Keep any value needed for main reder, like title, current value in string format and etc
    public var firstInputItem: MyProfileInputItem = MyProfileInputItem(title: nil)
    
    public var secondInputItem: MyProfileInputItem?
    
    public init(type: MyProfileContentItemType) {
        self.type = type
        self.cellHeight = UITableViewAutomaticDimension
    }
    
    public init(type: MyProfileContentItemType, cellHeight: CGFloat) {
        self.type = type
        self.cellHeight = cellHeight
    }

    public init(type: MyProfileContentItemType, cellHeight: CGFloat, inputItem: MyProfileInputItem) {
        self.type = type
        self.cellHeight = cellHeight
        self.firstInputItem = inputItem
    }
    
    public init(type: MyProfileContentItemType, inputItem: MyProfileInputItem) {
        self.type = type
        self.cellHeight = UITableViewAutomaticDimension
        self.firstInputItem = inputItem
    }
}

extension UITextField {
    @nonobjc
    public var myProfileControlTag: MyProfileControlTag {
        guard let loginControlTag = MyProfileControlTag(rawValue: tag) else {
            return .none
        }
        return loginControlTag
    }
}

public let MyProfileInputCellHeight: CGFloat = 50

// MARK: default model items, common used
extension MyProfileContentItem {
    /// Create email item with default config and proper tag and type
    public static func createDefaultEmailItem() -> MyProfileContentItem {
        // email
        let emailConfig = FloatLabelTextFieldConfig(placeholder: AppLocalization.sharedInstance.signUpEmailText,
                                                       editingMessage: AppLocalization.sharedInstance.signUpEmailText,
                                                       errorMessage: "ENTER_VALID_EMAIL".localizedPoqString)
        
        // just secure ourselfs. Usually username is email, but since we have it in 2 places - and 'LoginHelper.getUsername()' survive logout action
        let initialAccountEmail: String? = LoginHelper.getAccounDetails()?.email ?? LoginHelper.getEmail()  
        
        let emailInputItem = MyProfileInputItem(title: nil, value: initialAccountEmail, controlTag: .emailTextField, config: emailConfig)
        let email = MyProfileContentItem(type: .email, cellHeight: MyProfileInputCellHeight, inputItem: emailInputItem)
        return email
    }
    
    /// Create password item with default config and proper tag and type
    public static func createDefaultPasswordItem() -> MyProfileContentItem {
        // password
        let passwordConfig = FloatLabelTextFieldConfig(placeholder: AppLocalization.sharedInstance.signUpPasswordText,
                                                       editingMessage: nil,
                                                       errorMessage: AppLocalization.sharedInstance.enterValidPassword)
        
        let passwordInputItem = MyProfileInputItem(title: nil, value: nil, controlTag: .passwordTextField, config: passwordConfig)
        let password = MyProfileContentItem(type: .password, cellHeight: MyProfileInputCellHeight, inputItem: passwordInputItem)
        return password
    }
    
    /// Create Phone item with default config and proper tag and type
    public static func createDefaultPhoneItem() -> MyProfileContentItem {
        // Phone
        let phoneConfig = FloatLabelTextFieldConfig(placeholder: "PHONE_NUMBER".localizedPoqString,
                                                       editingMessage: nil,
                                                       errorMessage: "ENTER_VALID_PHONE".localizedPoqString)
        
        let existingPhone: String? = LoginHelper.getAccounDetails()?.phone
        let phoneInputItem = MyProfileInputItem(title: nil, value: existingPhone, controlTag: .phoneField, config: phoneConfig)
        let phoneItem = MyProfileContentItem(type: .phone, cellHeight: MyProfileInputCellHeight, inputItem: phoneInputItem)
        return phoneItem
    }

}
