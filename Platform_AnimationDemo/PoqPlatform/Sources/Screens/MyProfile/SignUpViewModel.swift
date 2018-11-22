//
//  SignUpViewModel.swift
//  Poq.iOS
//
//  Created by Jun Seki on 24/03/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import UIKit
import PoqAnalytics

private let OptionCellHeight: CGFloat = 70
private let HeaderCellHeight: CGFloat = 80
private let SubmitButtonCellHeight: CGFloat = 60
private let EmptyCellHeight: CGFloat = 60

public protocol PoqDatePickerDelegate {
    var dobDate: Date? { get set }
    func isDateValid() -> Bool
}

// TODO: remove PoqTitleBlock
open class SignUpViewModel: BaseViewModel, BaseAuthorizationViewModel, PoqDatePickerDelegate {
    
    // we use this model in 2 different view controllers. So lets make some ivars which will help us
    fileprivate var signUpPage: PoqPage?
    fileprivate var isEditMyProfile: Bool = false
    public var dobDate: Date?
    
    open var errorMessage: String?
    
    public var content: [MyProfileContentItem] = []
    
    // TODO: rename to registered and make private
    fileprivate var registeredAccount: PoqAccount? = LoginHelper.getAccounDetails()
    
    //This variable is used to enable phone number field on signup form
    var isPhoneNumberEnabled: Bool = false
    
    // MARK: - Basic network tasks
    // ______________________________________________________
    open func postUserAccount() {
        
        let account = createPoqAccount()
        
        let credentials = PoqAccountPost()
        credentials.username = account.email
        credentials.password = account.encryptedPassword
        
        let accountRegister = PoqAccountRegister()
        
        accountRegister.credentials = credentials
        
        accountRegister.profile = account
        
        // TODO: why we are doing it here? may be put on moment when we change swithces?
        if let isMasterCard: Bool = account.isMasterCard, AppSettings.sharedInstance.isMasterCardCellEnabledOnSignup {
            LoginHelper.isMasterCard = isMasterCard
            accountRegister.isMasterCard = isMasterCard
            
        }
        
        if let isDataSharing: Bool = account.allowDataSharing, AppSettings.sharedInstance.allowDataSharingCellEnabledOnSignup {
            LoginHelper.allowDataSharing = isDataSharing
            accountRegister.allowDataSharing = isDataSharing
        }
        
        if let isPromotion: Bool = account.isPromotion, AppSettings.sharedInstance.isPromotionCellEnabledOnSignup {
            LoginHelper.setPromotionSelection(isPromotion)
            accountRegister.isPromotion = isPromotion
        }
        
        PoqNetworkService(networkTaskDelegate: self).registerAccount(accountRegister, poqUserId: User.getUserId())
        
    }
    
    // MARK: - saveUser
    open func updateAccount() {
        
        let poqAccountUpdate = PoqAccountUpdate()
        
        poqAccountUpdate.firstName = contentItem(typeOf: .name)?.firstInputItem.value
        poqAccountUpdate.lastName = contentItem(typeOf: .name)?.secondInputItem?.value
        
        poqAccountUpdate.email = contentItem(typeOf: .email)?.firstInputItem.value
        
        if let birthdayString: String = contentItem(typeOf: .date)?.firstInputItem.value {
            poqAccountUpdate.birthday = DateHelper().apiSaveDateFormat(birthdayString)
        }
        
        // TODO: why we are doing it here? may be put on moment when we change swithces?
        if let isMasterCard: Bool = contentItem(typeOf: .mastercard)?.firstInputItem.value?.toBool(), AppSettings.sharedInstance.isMasterCardCellEnabledOnSignup {
            LoginHelper.isMasterCard = isMasterCard
            poqAccountUpdate.isMasterCard = isMasterCard
            
        }
        
        if let isDataSharing: Bool = contentItem(typeOf: .dataSharing)?.firstInputItem.value?.toBool(), AppSettings.sharedInstance.allowDataSharingCellEnabledOnSignup {
            LoginHelper.allowDataSharing = isDataSharing
            poqAccountUpdate.allowDataSharing = isDataSharing
        }
        
        if let isPromotion: Bool = contentItem(typeOf: .promotion)?.firstInputItem.value?.toBool(), AppSettings.sharedInstance.isPromotionCellEnabledOnSignup {
            LoginHelper.setPromotionSelection(isPromotion)
            poqAccountUpdate.isPromotion = isPromotion
        }
        
        PoqNetworkService(networkTaskDelegate: self).updateAccount(poqAccountUpdate)
    }
    
    // ______________________________________________________
    
    // MARK: - Basic network task callbacks
    
    /**
     Callback before start of the async network task
     */
    override open func networkTaskWillStart(_ networkTaskType: PoqNetworkTaskTypeProvider) {
        
        // Call super to show activity indicator
        super.networkTaskWillStart(networkTaskType)
        
        viewControllerDelegate?.networkTaskWillStart(networkTaskType)
    }
    
    /**
     Callback after async network task is completed
     */
    override open func networkTaskDidComplete(_ networkTaskType: PoqNetworkTaskTypeProvider, result: [Any]?) {
        
        // Call super to hide activity indicator
        // Send empty result list for avoind memory issues
        super.networkTaskDidComplete(networkTaskType, result: [])
        
        guard let networkResult = result, networkResult.count > 0 else {
            
            return
        }
        
        switch networkTaskType {
            
        case PoqNetworkTaskType.updateAccount:
            processUpdateAccountResult(networkResult)
            
        case PoqNetworkTaskType.pageDetails:
            signUpPage = result?.first as? PoqPage
            
            if let index: Int = indexOf(itemWithType:.webView) {
                content[index].firstInputItem.value = signUpPage?.body
            }
            
            if let index: Int = indexOf(itemWithType:.headerImage) {
                content[index].firstInputItem.value = signUpPage?.url
            }
            
        case PoqNetworkTaskType.registerAccount:
            
            if let registeredUser = result?.first as? PoqAccount {
                
                let allowGuestUser = registeredUser.statusCode == HTTPResponseCode.UNAUTHORIZED && registeredUser.isGuest == true
                if registeredUser.statusCode == HTTPResponseCode.OK || allowGuestUser {
                    Log.verbose("Save registered user")
                    SignUpViewModel.saveRegiteredUserInfo(registeredUser)
                    // Track signup event
                    
                    // FIXME: why we have 3! trakc of the same event
                    PoqTrackerHelper.trackRegisterUser()
                    //successfully signed up
                    
                    PoqTrackerHelper.trackSignUp(label: registeredUser.accountRef)
                    
                    if AppSettings.sharedInstance.enableRecognitionTracking {
                        PoqTrackerHelper.trackLoginRecognition(["RecognitionType": "SignUp"])
                    }
                }
            }
            
        default:
            Log.warning("Unknown operation")
        }
        
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
    
    /**
     Callback when task fails due to lack of internet etc.
     */
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        errorMessage = error?.localizedDescription
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
    
    func getDetails() {
        PoqNetworkService(networkTaskDelegate: self).getAccount()
    }
    
    func processUpdateAccountResult(_ networkResult: [Any]) {
        
        guard let account = networkResult[0] as? PoqAccount else {
            
            return
        }
        
        if let statusCode = account.statusCode, statusCode == HTTPResponseCode.OK {
            
            LoginHelper.updateAccountDetails(account)
            
            PoqTrackerHelper.trackUpdateAccount(label: account.accountRef)
            
            if let message = account.message {
                PopupMessageHelper.showMessage("icn-done", message: message)
                
            } else {
                PopupMessageHelper.showMessage("icn-done", message: "Account Updated")
                
            }
        } else {
            
            (viewControllerDelegate as? SignUpViewController)?.presentErrorAlert(account.message)
        }
    }
    
    open func isDateValid() -> Bool {
        guard dobDate != nil else {
            Log.error("Looks like the date is nil. Please provide the DOB date")
            return false
        }
        return true
    }
}

// MARK: convinent API for view controller

extension SignUpViewModel {
    
    /**
     Create content which is specific for Sign Up
     */
    @nonobjc
    public final func setupContentForSignUp() {
        content = createSignUpContent()
        
        if let pageId = AppSettings.sharedInstance.signUpPageId.toInt() {
            PoqNetworkService(networkTaskDelegate: self).getPageDetails(pageId)
        }
    }
    
    /**
     Create content which is specific for Edit My Profile
     */
    @nonobjc
    final func setupContentForEditMyProfile() {
        content = createEditProfileContent(registeredAccount)
        
        isEditMyProfile = true
    }
}

// MARK: Private
extension SignUpViewModel {
    /// Create content specific for sign up layout
    @nonobjc
    fileprivate func createSignUpContent() -> [MyProfileContentItem] {
        var content: [MyProfileContentItem] = []
        if AppSettings.sharedInstance.showHeaderImageOnSignUp {
            let headerItem = MyProfileInputItem(title: AppLocalization.sharedInstance.signupTitle)
            content.append(MyProfileContentItem(type: .headerImage, cellHeight: HeaderCellHeight, inputItem: headerItem))
        }
        
        // Name
        let firstNameConfig = FloatLabelTextFieldConfig(placeholder: AppLocalization.sharedInstance.signUpFirstNameText, editingMessage: AppLocalization.sharedInstance.signUpFirstNameText, errorMessage: nil)
        let firstName = MyProfileInputItem(title: nil,
                                           value: nil,
                                           controlTag: .firstNameTextField,
                                           config: firstNameConfig)
        
        let lastNameConfig = FloatLabelTextFieldConfig(placeholder: AppLocalization.sharedInstance.signUpLastNameText, editingMessage: AppLocalization.sharedInstance.signUpLastNameText, errorMessage: nil)
        let lasttName = MyProfileInputItem(title: nil,
                                           value: nil,
                                           controlTag: .lastNameTextField,
                                           config: lastNameConfig)
        var nameItem = MyProfileContentItem(type: .name, cellHeight: MyProfileInputCellHeight)
        nameItem.firstInputItem = firstName
        nameItem.secondInputItem = lasttName
        content.append(nameItem)
        
        var emailItem = MyProfileContentItem.createDefaultEmailItem()
        // we don't have predefind value on this screen
        emailItem.firstInputItem.value = nil
        content.append(emailItem)
        content.append(MyProfileContentItem.createDefaultPasswordItem())
        
        if isPhoneNumberEnabled {
            content.append(MyProfileContentItem.createDefaultPhoneItem())
        }
        
        if AppSettings.sharedInstance.isGenderCellEnabledOnSignup {
            content.append(MyProfileContentItem(type: .gender, cellHeight: MyProfileInputCellHeight))
        }
        
        if AppSettings.sharedInstance.isMasterCardCellEnabledOnSignup {
            
            let mastercardInputItem = MyProfileInputItem(title: AppLocalization.sharedInstance.signUpMasterCardText,
                                                         value: LoginHelper.isMasterCard.toString(),
                                                         controlTag: .mastercardSwitch)
            let mastercardCardItem = MyProfileContentItem(type: .mastercard, inputItem: mastercardInputItem)
            
            content.append(mastercardCardItem)
        }
        
        if AppSettings.sharedInstance.isPromotionCellEnabledOnSignup {
            let promotionInputItem = MyProfileInputItem(title: AppLocalization.sharedInstance.signUpPromotionText,
                                                        value: LoginHelper.getPromotionSelection().toString(),
                                                        controlTag: .promotionSwitch)
            let promotionItem = MyProfileContentItem(type: .promotion, inputItem: promotionInputItem)
            content.append(promotionItem)
        }
        
        if AppSettings.sharedInstance.allowDataSharingCellEnabledOnSignup {
            
            let dataSharingInputItem = MyProfileInputItem(title:  AppLocalization.sharedInstance.signUpDataSharingText,
                                                          value: LoginHelper.allowDataSharing.toString(),
                                                          controlTag: .dataSharingSwitch)
            let dataSharingCardItem = MyProfileContentItem(type: .dataSharing, inputItem: dataSharingInputItem)
            
            content.append(dataSharingCardItem)
        }
        
        if AppSettings.sharedInstance.isCardImageCellEnabledOnSignup {
            content.append(MyProfileContentItem(type: .cardImage, cellHeight: 40))
        }
        
        // Submit button
        let submitButtinInputItem = MyProfileInputItem(title: AppLocalization.sharedInstance.signinLandingPageRegisterButtonTitle)
        let submitButtonItem = MyProfileContentItem(type: .submitButton, cellHeight: SubmitButtonCellHeight, inputItem: submitButtinInputItem)
        content.append(submitButtonItem)
        
        content.append(MyProfileContentItem(type: .webView))
        return content
    }
    
    /// Create content specific for sign up layout
    @nonobjc
    fileprivate func createEditProfileContent(_ currentAccount: PoqAccount?) -> [MyProfileContentItem] {
        var content: [MyProfileContentItem] = []
        
        if AppSettings.sharedInstance.addressTypeTitleEnabled {
            let titleItem = MyProfileInputItem(title: nil, value: AppLocalization.sharedInstance.editMyProfileTitle)
            content.append(MyProfileContentItem(type: .title, cellHeight: MyProfileInputCellHeight, inputItem: titleItem))
        }
        
        // Name
        let firstNameConfig = FloatLabelTextFieldConfig(placeholder: AppLocalization.sharedInstance.signUpFirstNameText, editingMessage: AppLocalization.sharedInstance.signUpFirstNameText, errorMessage: nil)
        let firstName = MyProfileInputItem(title: nil,
                                           value: currentAccount?.firstName,
                                           controlTag: .firstNameTextField,
                                           config: firstNameConfig)
        
        let lastNameConfig = FloatLabelTextFieldConfig(placeholder: AppLocalization.sharedInstance.signUpLastNameText, editingMessage: AppLocalization.sharedInstance.signUpLastNameText, errorMessage: nil)
        let lasttName = MyProfileInputItem(title: nil,
                                           value: currentAccount?.lastName,
                                           controlTag: .lastNameTextField,
                                           config: lastNameConfig)
        var nameItem = MyProfileContentItem(type: .name, cellHeight: MyProfileInputCellHeight)
        nameItem.firstInputItem = firstName
        nameItem.secondInputItem = lasttName
        content.append(nameItem)
        
        if AppSettings.sharedInstance.isMyProfileEmailEnabled {
            content.append(MyProfileContentItem.createDefaultEmailItem())
        }
        if isPhoneNumberEnabled {
            content.append(MyProfileContentItem.createDefaultPhoneItem())
        }
        
        if AppSettings.sharedInstance.isMyProfileDOBEnabled {
            
            var birthdayString: String? = currentAccount?.birthday
            
            // This strange check arrive from old time, have no idea why  API can't just send nil
            if birthdayString == AppSettings.sharedInstance.editMyProfileRegisterUserDefaultDate {
                birthdayString = nil
            }
            
            let dateInputValue = MyProfileInputItem(title: AppLocalization.sharedInstance.editMyProfileDOBText,
                                                    value: DateHelper().birthdayDateFormat(fromApiDate: birthdayString))
            let birthdayItem = MyProfileContentItem(type: .date, cellHeight: MyProfileInputCellHeight, inputItem: dateInputValue)
            content.append(birthdayItem)
        }
        
        if AppSettings.sharedInstance.isPromotionCellEnabledOnSignup {
            
            let promotionInputItem = MyProfileInputItem(title: AppLocalization.sharedInstance.signUpPromotionText,
                                                        value: currentAccount?.isPromotion?.toString(),
                                                        controlTag: .promotionSwitch)
            let promotionItem = MyProfileContentItem(type: .promotion, inputItem: promotionInputItem)
            content.append(promotionItem)
        }
        
        if AppSettings.sharedInstance.isMasterCardCellEnabledOnSignup {
            
            let mastercardInputItem = MyProfileInputItem(title: AppLocalization.sharedInstance.signUpMasterCardText,
                                                         value: currentAccount?.isMasterCard?.toString(),
                                                         controlTag: .mastercardSwitch)
            let mastercardCardItem = MyProfileContentItem(type: .mastercard, inputItem: mastercardInputItem)
            
            content.append(mastercardCardItem)
        }
        
        if AppSettings.sharedInstance.allowDataSharingCellEnabledOnSignup {
            
            let dataSharingInputItem = MyProfileInputItem(title:  AppLocalization.sharedInstance.signUpDataSharingText,
                                                          value: currentAccount?.allowDataSharing?.toString(),
                                                          controlTag: .dataSharingSwitch)
            let dataSharingCardItem = MyProfileContentItem(type: .dataSharing, inputItem: dataSharingInputItem)
            
            content.append(dataSharingCardItem)
        }
        
        return content
    }
    
    @nonobjc
    fileprivate static func saveRegiteredUserInfo(_ account: PoqAccount) {
        
        guard let validUsername = account.username, !validUsername.isEmpty else {
            Log.error("We can't save user with empty first name")
            return
        }
        
        // Save account data
        LoginHelper.saveAccountDetails(account)
        
        //Save username
        LoginHelper.saveEmail(validUsername)
        
        guard let validAuthentication: AuthenticationType = AuthenticationType(rawValue: NetworkSettings.shared.authenticationType) else {
            Log.error("We got uknown auth type in AppSettings.sharedInstance.authenticationType")
            return
        }
        
        switch validAuthentication {
        case .password:
            // Only save password when the authentication is based on password like in DW or Magento
            guard let validEncryptedPassword = account.encryptedPassword else {
                break
            }
            
            LoginHelper.savePassword(validUsername, password: validEncryptedPassword)
            break
            
        case .oAuth:
            // AccessToken and RefreshToken are the only keys to keep user logged in
            guard let validRefreshToken = account.refreshToken, let validAccessToken = account.accessToken else {
                break
            }
            
            LoginHelper.saveOAuthTokens(forUsername: validUsername, accessToken: validAccessToken, refreshToken: validRefreshToken)
            break
        }
        
        // Track signup event
        PoqTrackerHelper.trackRegisterUser(label: account.accountRef)
        
        // Track recognition card
        if AppSettings.sharedInstance.enableRecognitionTracking {
            
            if let loyaltyCardNumber = account.loyaltyCardNumber {
                
                // Track recognition card event
                PoqTrackerHelper.trackLoginRecognition(["RecognitionType": "Registered Physical Card", "loyaltyCardNumber": String(loyaltyCardNumber)])
            } else {
                
                // Track recognition card event
                PoqTrackerHelper.trackLoginRecognition(["RecognitionType": "mastercard"])
            }
        }
    }
    
    /**
     Create aaount based on 'content'. Without any validation, just put values in ptoper places
     */
    open func createPoqAccount() -> PoqAccount {
        let account = PoqAccount()
        
        account.email = contentItem(typeOf: .email)?.firstInputItem.value
        account.encryptedPassword = contentItem(typeOf: .password)?.firstInputItem.value
        
        account.firstName = contentItem(typeOf: .name)?.firstInputItem.value
        account.lastName = contentItem(typeOf: .name)?.secondInputItem?.value
        
        if AppSettings.sharedInstance.isMasterCardCellEnabledOnSignup {
            account.isMasterCard = contentItem(typeOf: .mastercard)?.firstInputItem.value?.toBool()
        }
        
        if AppSettings.sharedInstance.allowDataSharingCellEnabledOnSignup {
            account.allowDataSharing = contentItem(typeOf: .dataSharing)?.firstInputItem.value?.toBool()
            
        }
        
        if AppSettings.sharedInstance.isPromotionCellEnabledOnSignup {
            account.isPromotion = contentItem(typeOf: .promotion)?.firstInputItem.value?.toBool()
        }
        
        if let isFemale = contentItem(typeOf: .gender)?.firstInputItem.value?.toBool() {
            account.gender = isFemale ? "f" : "m"
        }
        
        if isPhoneNumberEnabled {
            account.phone = contentItem(typeOf: .phone)?.firstInputItem.value
        }
        
        return account
    }
}

// TODO: what this class do here? or move in other place or embed functionality in SignUpViewModel

open class FloatTableViewHelper {
    
    required public init() {
        // Stub
    }
    
    public func makeNextCellFirstResponder(_ tag: Int, tableView: UITableView?) {
        
        //tags start from 1, cells start from zero index
        var tagValue = tag - 1
        
        if AppSettings.sharedInstance.showHeaderImageOnSignUp {
            
            tagValue = tag
        }
        
        if let currentCell = tableView?.cellForRow(at: IndexPath(row: abs(tagValue), section: 0)) as? TwoTextfieldsTableViewCell, tag >= 0 {
            
            currentCell.lastNameTextField?.becomeFirstResponder()
            
            return
        }
        
        if let nextCell = tableView?.cellForRow(at: IndexPath(row: abs(tagValue), section: 0)) as? FullwidthTextFieldCellTableViewCell {
            
            nextCell.inputTextField?.becomeFirstResponder()
            
            return
        }
    }
}
