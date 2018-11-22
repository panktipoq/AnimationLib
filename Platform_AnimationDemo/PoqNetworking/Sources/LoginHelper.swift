//
//  LoginHelper.swift
//  Poq.iOS
//
//  Created by Øyvind Henriksen on 19/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import Locksmith
import PoqUtilities

/**
 To be up-to-date with user logged in status subscribe for these notification in NSNotificationCenter
 Object will be instance of LoginHelper, user infor is nil
 */

/// Notification name when the user has logged in. Objects listening to this will update their views accordingly
public let PoqUserDidLoginNotification = "PoqUserDidLoginNotification"

/// Notification name when the user has logged out. Objects listening to this will update their views accordingly
public let PoqUserDidLogoutNotification = "PoqUserDidLogoutNotification"

/// Common error domain for login related errors.
public let LoginHelperErrorDomain = "LoginHelperErrorDomain"

/// Gender types as required by all backend implementations. Some require m/f some male/female
///
/// - F: User gender type female 
/// - M: User gender type male
/// - FEMALE: User gender type female
/// - MALE: User gender type male
public enum GenderType : String {
    
    case F = "f"
    case M = "m"
    case FEMALE = "female"
    case MALE = "male"
}

/// User defaults key for user's email. TODO: Considering GDPR we should move this to keychain as well
private let EmailUserDefaultsKey: String = "email"

/// Keychain key for user's password
private let PasswordKeychainKey:String = "password"

/// Keychain key for user's refresh token
private let RefreshTokenKeychainKey: String = "refreshToken"

/// Keychain key for user's access token
private let AccessTokenKeychainKey: String = "accessToken"

/// Keychain key for facebook username required for FB authentication
private let FBUserName = "facebook"

/// Keychain key for facebook's access token
private let FBAccessTokenKeychainKey: String = "FBAccessToken"

/// Class used for authenticating, storing and overall managing the user
public final class LoginHelper: NSObject {
    
    // MARK: username operations

    /// - Returns: username if saved, or empty string "" if nothing saved
    
    /// Returns the email of the user if the user is logged in
    ///
    /// - Returns: The email of the user if the user is logged in
    public static func getEmail() -> String? {
        let userDefaults = UserDefaults.standard
        if let defaultUsername: AnyObject = userDefaults.value(forKey: EmailUserDefaultsKey) as AnyObject? {
            return defaultUsername as? String
        }
        return nil
    }
    
    /// Saves username to NSUserDefaults. Pass nil to remove saved username
    
    /// Saves the user's email in case the user has updated it
    ///
    /// - Parameter username: The new username
    public static func saveEmail(_ username: String?) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(username, forKey: EmailUserDefaultsKey)
        userDefaults.synchronize()
    }
    
    
    /// Returns firstName if saved, or empty string "" if nothing saved
    
    /// Returns the user's date of birth 
    ///
    /// - Returns: The user's date of birth
    public static func getDOB() -> String {
        
        var dob = ""
        
        let userDefaults = UserDefaults.standard
        if let defaultDOB:AnyObject = userDefaults.value(forKey: "birthday") as AnyObject? {
            dob = defaultDOB as! String
            dob = dob[0...9]
        }
        return dob
    }
    
    /// Saves username to NSDefaults
    
    /// Saves the user's date of birth. TODO: We should make a check if the user's logged in before trying to save also as stated previously we should move this to keychain
    ///
    /// - Parameter birthday: The new date of birth of the user
    public static func saveDOB(_ birthday: NSString) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(birthday, forKey: "birthday")
        userDefaults.set(true, forKey:"isDOBUpdated")
        userDefaults.synchronize()
    }
    
    /// Checks to see if the uers's birthday has been updated
    ///
    /// - Returns: true if the user has updated the birthday field
    public static func isDOBUpdated() -> Bool{
        var updated = false
        let userDefaults = UserDefaults.standard
        if let defaultUpdated:AnyObject = userDefaults.value(forKey: "isDOBUpdated") as AnyObject? {
            updated = defaultUpdated as! Bool
        }
        return updated
    }
    
    /// - Returns: password from Keychain via Locksmith pod, or nil, if there is no password
    
    /// Returns the password from keychain
    ///
    /// - Parameter username: The username that points to the password
    /// - Returns: The password of the user. TODO: As a security measure we should elaborate on storing a hash of the password
    fileprivate static func getPassword(_ username: String) -> String? {
        if let dictionary = Locksmith.loadDataForUserAccount(userAccount: username){
            return dictionary[PasswordKeychainKey] as? String
        }
        return nil
    }
    
    
    // MARK: - Facebook Token methods
    
    /// Returns the user's facebook token
    ///
    /// - Returns: The user's facebook token
    public static func getFacebookToken() -> String? {
        return LoginHelper.getKeyChainValue(of: FBAccessTokenKeychainKey , forUsername: FBUserName)
    }
    
    /// Saves the user's facebook token
    ///
    /// - Parameter token: The token that needs to be saved
    /// - Returns: An error if one has been generated while trying to save the facebook token
    @discardableResult
    public static func saveFacebookToken(_ token: String) -> NSError? {
        do {
            if let _ = LoginHelper.getFacebookToken() {
                try Locksmith.updateData(data: [FBAccessTokenKeychainKey: token], forUserAccount: FBUserName)
            } else {
                try Locksmith.saveData(data: [FBAccessTokenKeychainKey: token], forUserAccount: FBUserName)
            }
        } catch {
            return NSError(domain:LoginHelperErrorDomain,
                           code: -1,
                           userInfo:[NSLocalizedDescriptionKey:"Unknown error"])
        }
        return nil
    }
    
    /// Saves password to keychain via Locksmith pod.
    
    /// Saves the user's password
    ///
    /// - Parameters:
    ///   - username: The username for which the password is going to be saved
    ///   - password: The user's password that is going to be saved
    /// - Returns: An error if one has been generated as a result of trying to save the password
    @discardableResult
    public static func savePassword(_ username: String, password: String?) -> NSError? {
        do {
            if let validPassword: String = password {
                // TODO: all these methods can fail sinlently with error -34018 . We need improve Locksmith to let here user know about some problems
                if let _ = getPassword(username) { // No password created, so create new one
                    try Locksmith.updateData(data: [PasswordKeychainKey: validPassword], forUserAccount: username)
                } else {
                    try Locksmith.saveData(data: [PasswordKeychainKey: validPassword], forUserAccount: username)
                }
            } else {
                try Locksmith.deleteDataForUserAccount(userAccount: username)
            }
        }catch {
            return NSError(domain:LoginHelperErrorDomain,
                           code: -1,
                           userInfo:[NSLocalizedDescriptionKey:"Unknown error"])
        }
        
        if isLoggedIn() {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PoqUserDidLoginNotification), object: self)
        }
        return nil
    }
    
    /// Saves oAuth tokens used to sign authenticated requests
    ///
    /// - Parameters:
    ///   - username: The username for which the tokens will be saved
    ///   - accessToken: The access token that will be saved for this user
    ///   - refreshToken: The refresh token that will be saved for this user
    /// - Returns: An error if one was generated as a result of saving the tokens
    @discardableResult
    public static func saveOAuthTokens(forUsername username: String, accessToken: String, refreshToken: String) -> NSError? {
        do {
            let inialValue = Locksmith.loadDataForUserAccount(userAccount: username)
            var userAccountValues = inialValue ?? [:]
            
            userAccountValues[AccessTokenKeychainKey] = accessToken
            userAccountValues[RefreshTokenKeychainKey] = refreshToken
            
            if let _ = inialValue {
                
                // Overwrite
                try Locksmith.updateData(data: userAccountValues, forUserAccount: username)
                
            } else {
                // Add new
                try Locksmith.saveData(data: userAccountValues, forUserAccount: username)
            }
        } catch {
            return NSError(domain:LoginHelperErrorDomain,
                           code: -1,
                           userInfo:[NSLocalizedDescriptionKey:"Unknown error"])
        }
        if isLoggedIn() {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PoqUserDidLoginNotification), object: self)
        }
        return nil
    }
    
    /// Returns the user's refresh token
    ///
    /// - Returns: The user's refresh token if it exists
    public static func getReshreshToken() -> String? {
        
        guard let validUsername: String = getEmail() else {
            return nil
        }
        return getKeyChainValue(of: RefreshTokenKeychainKey, forUsername:validUsername)
    }
    
    /// Updates account information in one batch TODO: We should migrate these to Keychain in the future
    ///
    /// - Parameter userAccount: The user account that needs to be updated
    public static func saveAccountDetails(_ userAccount: PoqAccount) {
        
        let userDefaults = UserDefaults.standard
  
        // There is no easy way to save as an object
        // PoqAccount needs to implement NSObject to do so
        // Instead this way easier to implement
        // Dirty but works for now :)
        // Mahmut Canga
        userDefaults.setValue(userAccount.email, forKey: "email")
        userDefaults.setValue(userAccount.customerNo, forKey: "customerNo")
        userDefaults.setValue(userAccount.loyaltyCardNumber, forKey: "loyaltyCardNumber")
        userDefaults.setValue(userAccount.firstName, forKey: "firstName")
        userDefaults.setValue(userAccount.lastName, forKey: "lastName")
        userDefaults.setValue(userAccount.gender, forKey: "gender")
        userDefaults.setValue(userAccount.title, forKey: "title")
        userDefaults.setValue(userAccount.phone, forKey: "phone")
        userDefaults.setValue(userAccount.statusCode, forKey: "userAccount.statusCode")

        userDefaults.setValue(userAccount.isLoyaltAccountClosed, forKey: "isLoyaltAccountClosed")
        userDefaults.setValue(userAccount.pointsRewardSummary?.currency, forKey: "currency")
        userDefaults.setValue(userAccount.pointsRewardSummary?.balance, forKey: "balance")
        userDefaults.setValue(userAccount.pointsRewardSummary?.points, forKey: "points")
        
        userDefaults.setValue(userAccount.pointsRewardSummary?.expiringBalance, forKey: "expiringBalance")
        userDefaults.setValue(userAccount.pointsRewardSummary?.expiringBalanceDate, forKey: "expiringBalanceDate")
        userDefaults.setValue(userAccount.pointsRewardSummary?.displayConversion, forKey: "displayConversion")
        userDefaults.setValue(userAccount.pointsRewardSummary?.pointsToGo, forKey: "pointsToGo")
        userDefaults.setValue(userAccount.pointsRewardSummary?.pointsForReward, forKey: "pointsForReward")

        //NOTE: if DW return 1901 for anyone under 18 then ignore that.
        //e.g. if user enter 2005/04/23, then DW will return 1901/04/23, so app need to ignore 1901 and display 2005 instead.
        if (userAccount.birthday?.range(of: NetworkSettings.shared.editMyProfileDefaultYear) == nil) {
            userDefaults.setValue(userAccount.birthday, forKey: "birthday")
        }

        userDefaults.setValue(userAccount.isBagMerged, forKey: "isBagMerged")
        userDefaults.setValue(userAccount.isGuest, forKey: "isGuestUser")
        
        //NOTE: no need to save the value after API call, API return false. For one of our clients
        //userDefaults.setValue(userAccount.isMasterCard, forKey: "isMasterCard")
        
        userDefaults.setValue(userAccount.allowDataSharing, forKey: "allowDataSharing")
        userDefaults.setValue(userAccount.isPromotion, forKey: "isPromotion")
        userDefaults.setValue(userAccount.accountRef, forKey: "accountRef")
        userDefaults.synchronize()
    }
    
    /// Updates account data. TODO: Why do we need to methods to do this one could handle both
    ///
    /// - Parameter userAccount: The new user account information
    public static func updateAccountDetails(_ userAccount:PoqAccount) {
        
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(userAccount.firstName, forKey: "firstName")
        userDefaults.setValue(userAccount.lastName, forKey: "lastName")
        userDefaults.setValue(userAccount.email, forKey: "email")
        
        if let email = userAccount.email, let encryptedPassword = userAccount.encryptedPassword {
            
            saveEmail(email)
            savePassword(email, password: encryptedPassword)
        }
        
        userDefaults.setValue(userAccount.isGuest, forKey: "isGuestUser")
        
        //NOTE: if DW return 1901 for anyone under 18 then ignore that.
        //e.g. if user enter 2005/04/23, then DW will return 1901/04/23, so app need to ignore 1901 and display 2005 instead.
        if (userAccount.birthday?.range(of: NetworkSettings.shared.editMyProfileDefaultYear) == nil) {
            userDefaults.setValue(userAccount.birthday, forKey: "birthday")
        }
        userDefaults.setValue(userAccount.isMasterCard, forKey: "isMasterCard")
        userDefaults.setValue(userAccount.allowDataSharing, forKey: "allowDataSharing")
        userDefaults.setValue(userAccount.isPromotion, forKey: "isPromotion")
        userDefaults.setValue(userAccount.accountRef, forKey: "accountRef")
        
        userDefaults.synchronize()
    }
    
    /// Returns the account details
    ///
    /// - Returns: The current user's account details
    public static func getAccounDetails() -> PoqAccount? {
        
        let userDefaults = UserDefaults.standard
        
        let account = PoqAccount()
        account.pointsRewardSummary = PoqPointsRewardSummary()
        
        account.email = userDefaults.value(forKey: "email") as? String
        account.customerNo = userDefaults.value(forKey: "customerNo") as? String
        account.loyaltyCardNumber = userDefaults.value(forKey: "loyaltyCardNumber") as? String
        account.firstName = userDefaults.value(forKey: "firstName") as? String
        account.lastName = userDefaults.value(forKey: "lastName") as? String
        account.gender = userDefaults.value(forKey: "gender") as? String
        account.title = userDefaults.value(forKey: "title") as? String
        account.phone = userDefaults.value(forKey: "phone") as? String
        account.isMasterCard = userDefaults.value(forKey: "isMasterCard") as? Bool
        account.statusCode = userDefaults.value(forKey: "userAccount.statusCode") as? Int

        account.isLoyaltAccountClosed = userDefaults.value(forKey: "isLoyaltAccountClosed") as? Bool
        account.pointsRewardSummary!.currency = userDefaults.value(forKey: "currency") as? String
        account.pointsRewardSummary!.balance = userDefaults.value(forKey: "balance") as? String
        account.pointsRewardSummary!.points = userDefaults.value(forKey: "points") as? Double
        account.pointsRewardSummary!.expiringBalance = userDefaults.value(forKey: "expiringBalance") as? Double
        account.pointsRewardSummary!.expiringBalanceDate = userDefaults.value(forKey: "expiringBalanceDate") as? String
        account.pointsRewardSummary!.displayConversion = userDefaults.value(forKey: "displayConversion") as? String
        account.pointsRewardSummary!.pointsToGo = userDefaults.value(forKey: "pointsToGo") as? Double
        account.pointsRewardSummary!.pointsForReward = userDefaults.value(forKey: "pointsForReward") as? Double
        
        account.birthday = userDefaults.value(forKey: "birthday") as? String
        account.isBagMerged = userDefaults.value(forKey: "isBagMerged") as? Bool
        account.isGuest = userDefaults.value(forKey: "isGuestUser") as? Bool
        
        account.allowDataSharing = userDefaults.value(forKey: "allowDataSharing") as? Bool
        account.isPromotion = userDefaults.value(forKey: "isPromotion") as? Bool
        account.accountRef = userDefaults.value(forKey: "accountRef") as? String
        
        // At least we need to check some basic info that affects the UI and business logic
        // TODO: 1 - really 4 equals??? Only last one have matter, why we need 3 others? 
        // 2 - loyaltyCardNumber - really bad-bad check for logged in and valid account details
        var validAccountData = account.email != nil
        validAccountData = account.loyaltyCardNumber != nil
        validAccountData = account.firstName != nil
        validAccountData = account.lastName != nil
        
        // It is assumed as normal for Guest users to lack some details
        if validAccountData || account.isGuest == true {
            return account
        }
        
        return nil
    }
    
    /**
     * Remove saved facebook token from keychain, if possible
     */
    
    /// Tries to logout of a facebook session
    fileprivate static func logOutFacebookIfPossible() {
        do {
            if let facebookToken = LoginHelper.getFacebookToken(), !facebookToken.isEmpty {
                try Locksmith.deleteDataForUserAccount(userAccount: FBUserName)
            }
        }
        catch {
            Log.warning("We coulnd't delete facebook user or it's already deleted")
        }
    }
    
    /// Logs a user out
    fileprivate static func logOutEmail() {
        do {
            if let validUserName: String = getEmail() {
                try Locksmith.deleteDataForUserAccount(userAccount: validUserName)
            }
        }
        catch {
            Log.warning("We coulnd't delete user with this Email or it's already deleted")
        }
    }
    
    /// Clears user data and logs out
    public static func clear() {
        
        let shouldPostNotification = isLoggedIn()
        
        //To make sure we are loging out properly we are deleting everything from Keychain
        logOutEmail()
        logOutFacebookIfPossible()
        
        let userDefaults = UserDefaults.standard
        
        userDefaults.removeObject(forKey: "customerNo")
        userDefaults.removeObject(forKey: "loyaltyCardNumber")
        userDefaults.removeObject(forKey: "firstName")
        userDefaults.removeObject(forKey: "lastName")
        userDefaults.removeObject(forKey: "gender")
        userDefaults.removeObject(forKey: "title")
        userDefaults.removeObject(forKey: "phone")
        userDefaults.removeObject(forKey: "isLoyaltAccountClosed")
        userDefaults.removeObject(forKey: "currency")
        userDefaults.removeObject(forKey: "balance")
        userDefaults.removeObject(forKey: "points")
        userDefaults.removeObject(forKey: "isGuestUser")
        userDefaults.removeObject(forKey: "userId")
        userDefaults.removeObject(forKey: "accountRef")
        if NetworkSettings.shared.isUpdatingBirthdateEnabled {
            userDefaults.removeObject(forKey: "birthday")

        }
        userDefaults.removeObject(forKey: "isDOBUpdated")
        userDefaults.synchronize()
        
        if shouldPostNotification {
            NotificationCenter.default.post(name: Notification.Name(rawValue: PoqUserDidLogoutNotification), object: self)
        }
    }
    
    /// Checks to see if the user is logged in or not
    ///
    /// - Returns: true if there is a logged in user.
    public static func isLoggedIn() -> Bool {

        guard let authenticationType = AuthenticationType(rawValue: NetworkSettings.shared.authenticationType) else {
            Log.error("We found unknown authtype - \(NetworkSettings.shared.authenticationType)")
            return false
        }
        
        if let facebookToken = LoginHelper.getFacebookToken(), !facebookToken.isEmpty {
            return true
        }
        
        // Username and password is not enough to understand user's login
        // User's account details are also required for MyProfile. So we check account details as well
        guard let validUsername = getEmail(), let _ = getAccounDetails(), !validUsername.isEmpty else {
            return false
        }
        
        switch authenticationType {
        case .password:
            if let password  = getKeyChainValue(of: PasswordKeychainKey, forUsername: validUsername), !password.isEmpty {
                return true
            }
        case .oAuth:
            if let accessToken = getKeyChainValue(of: AccessTokenKeychainKey, forUsername: validUsername), !accessToken.isEmpty {
                return true
            }
        }

        return false
    }
    
    /// Setter and getter for isMastercard field. TODO: We need to check on what the full scope of isMasterCard is might be only used in one of our clients
    public static var isMasterCard: Bool {
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(newValue, forKey: "isMasterCard")
            userDefaults.synchronize()
        }
        
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.value(forKey: "isMasterCard") as! Bool? == true

        }
    }

    /// Setter and getter for allowing data sharing. TODO: What does this do ?
    public static var allowDataSharing: Bool {
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(newValue, forKey: "allowDataSharing")
            userDefaults.synchronize()
        }
        
        get {
            guard LoginHelper.isLoggedIn() else{
                return NetworkSettings.shared.signUpDataShareToggleButtonDefaultValue
            }
            let userDefaults = UserDefaults.standard
            return userDefaults.value(forKey: "allowDataSharing") as! Bool? == true
        }
    }
    
    /// Checks to see if the user has a loyalty card number.
    ///
    /// - Returns: true if the user has a loyalty card number
    public static func hasLoyaltyCardNumber() -> Bool {
        
        let userDefaults = UserDefaults.standard
        let loyaltyCardNumber = userDefaults.value(forKey: "loyaltyCardNumber") as! String?
        
        return loyaltyCardNumber == nil ? false : true
    }
    
    /// Checks to see if promotion is enabled on register
    ///
    /// - Returns: true if the promotion is enabled for this user
    public static func getPromotionSelection() -> Bool {
        guard LoginHelper.isLoggedIn() else{
            return NetworkSettings.shared.signUpPromotionToggleButtonDefaultValue
        }

        let userDefaults = UserDefaults.standard
        let promotionSelected = userDefaults.value(forKey: "isPromotion") as! Bool?
        if promotionSelected == nil{
            return true
        }
        
        return userDefaults.value(forKey: "isPromotion") as! Bool? == true
    }
    
    /// Sets the promotion state selected or unselected 
    ///
    /// - Parameter promotionSelected: The new state of this user's promotion
    public static func setPromotionSelection(_ promotionSelected:Bool){
        let userDefaults = UserDefaults.standard
        
        userDefaults.setValue(promotionSelected, forKey: "isPromotion")
        userDefaults.synchronize()
    }
    
    /// Return value for "Authorization" header, depends on user login status and auth type
    public static func getAuthenticationHeader() -> String? {
        
        guard let validUsername: String = getEmail() else {
            return nil
        }
        
        guard let authenticationType =  AuthenticationType(rawValue: NetworkSettings.shared.authenticationType) else {
            Log.error("We found unknown authtype - \(NetworkSettings.shared.authenticationType)")
            return nil
        }

        switch authenticationType {
        case .password:
            
            if let facebookToken = LoginHelper.getFacebookToken(), facebookToken.isEmpty == false {
                return createAuthenticationHeader(userName: FBUserName, password: facebookToken)
            }
            
            // No need to create authentication header if user is logged out and/or password is not stored in the keychain anymore
            guard let validPassword = LoginHelper.getPassword(validUsername), LoginHelper.isLoggedIn() else{
                return nil
            }
            
            return createAuthenticationHeader(userName: validUsername, password: validPassword)

        case .oAuth:
            guard let accessToken = getKeyChainValue(of: AccessTokenKeychainKey, forUsername: validUsername), !accessToken.isEmpty else {
                return nil
            }
            
            return accessToken
        }
    }
    
    /// Creates an authentication header used to sign requests
    ///
    /// - Parameters:
    ///   - userName: The username used for the headers
    ///   - password: The user's password. TODO: base 64 encoded password in header
    /// - Returns: The authentication header
    private class func createAuthenticationHeader(userName: String, password: String) -> String {
        let loginString = NSString(format: "%@:%@", userName, password)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: [])
        return "Basic \(base64LoginString)"
    }
}

// MARK: - Login helper additional methods
extension LoginHelper {
    
    /// Returns the keychain value of a given field
    ///
    /// - Parameters:
    ///   - key: The key for which the value needs to be returned
    ///   - username: The username 
    /// - Returns: The keychain value for the given key
    fileprivate class func getKeyChainValue(of key: String, forUsername username: String) -> String? {
        
        var userAccountValues = Locksmith.loadDataForUserAccount(userAccount: username)
        
        return userAccountValues?[key] as? String
    }
}

