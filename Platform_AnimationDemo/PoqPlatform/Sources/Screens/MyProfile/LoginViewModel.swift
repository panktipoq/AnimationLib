//
//  LoginViewModel.swift
//  Poq.iOS
//
//  Created by Erinç Erol on 24/02/2015.
//  Copyright (c) 2015 Poq Studio. All rights reserved.
//

import Foundation
import PoqNetworking
import PoqUtilities
import PoqAnalytics
import UIKit

open class LoginViewModel: BaseViewModel, BaseAuthorizationViewModel {
    
    typealias CheckoutItemType = PoqCheckoutItem<PoqBagItem>
    
    open var content: [MyProfileContentItem] = LoginViewModel.createLoginContent(forPage: nil)
    
    fileprivate var loginPage: PoqPage?
    
    var errorMessage: String?
    
    // ______________________________________________________
    // MARK: - Basic network tasks
    
    func getLoginPageDetails(_ isRefresh: Bool = false) {
        
        let loginPageIdString: String = AppSettings.sharedInstance.loginPageId
        guard let loginPageId = loginPageIdString.toInt() else {
            return
        }
        
        PoqNetworkService(networkTaskDelegate: self).getPageDetails(loginPageId, isRefresh: isRefresh)
    }
    
    // MARK: - Login
    func login(_ username: String, password: String) {
        let postAccount = PoqAccountPost()
        postAccount.username = username
        postAccount.password = password
        postAccount.isMasterCard = LoginHelper.isMasterCard
        PoqNetworkService(networkTaskDelegate: self).postAccount(postAccount, poqUserId: User.getUserId())
    }
    
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
        // Send empty result list for avoiding memory issues
        super.networkTaskDidComplete(networkTaskType, result: [])
        
        let handleFailureBlock = { [unowned self, result, networkTaskType] in
            
            // Check for an error message in the response
            if let errorMessage = (result?.first as? PoqAccount)?.message {
                self.errorMessage = errorMessage
            }
            
            self.viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: nil)
        }
        
        if networkTaskType == PoqNetworkTaskType.postAccount {
            
            guard let account = result?.first as? PoqAccount, let validUsername = account.username else {
                Log.error("Login failed")
                handleFailureBlock()
                return
            }
            
            let allowGuestUser = account.statusCode == HTTPResponseCode.UNAUTHORIZED && account.isGuest == true
            guard account.statusCode == HTTPResponseCode.OK || allowGuestUser else {
                Log.error("We trying to login, but failed")
                handleFailureBlock()
                return
            }
            
            guard let validAuthentication = AuthenticationType(rawValue: NetworkSettings.shared.authenticationType) else {
                Log.error("We got unknown auth type in AppSettings.sharedInstance.authenticationType")
                handleFailureBlock()
                return
            }
            
            // Save account data
            LoginHelper.saveAccountDetails(account)
            
            // Save username
            LoginHelper.saveEmail(validUsername)
            
            switch validAuthentication {
            case .password:
                // Only save password when the authentication is based on password like in DW or Magento
                guard let validEncryptedPassword = account.encryptedPassword else {
                    break
                }
                
                LoginHelper.savePassword(validUsername, password: validEncryptedPassword)
            case .oAuth:
                // AccessToken and RefreshToken are the only keys to keep user logged in
                guard let validRefreshToken = account.refreshToken, let validAccessToken = account.accessToken else {
                    break
                }
                
                LoginHelper.saveOAuthTokens(forUsername: validUsername, accessToken: validAccessToken, refreshToken: validRefreshToken)
            }
            
            // Track login event
            
            PoqTrackerHelper.trackUserLogin(label: account.accountRef)
            PoqTrackerV2.shared.login(userId: User.getUserId())
            
        } else if networkTaskType == PoqNetworkTaskType.pageDetails {
            
            if let page: PoqPage = result?.first as? PoqPage {
                
                loginPage = page
            }
            
            content = LoginViewModel.createLoginContent(forPage: loginPage)
            
        }
        
        // Send back network request result to view controller
        viewControllerDelegate?.networkTaskDidComplete(networkTaskType)
    }
    
    /**
     Callback when task fails due to lack of internet etc.
     */
    override open func networkTaskDidFail(_ networkTaskType: PoqNetworkTaskTypeProvider, error: NSError?) {
        
        // Call super to show alert
        super.networkTaskDidFail(networkTaskType, error: error)
        
        errorMessage = error?.localizedDescription ?? errorMessage
        
        // Callback view controller to adjust UI
        viewControllerDelegate?.networkTaskDidFail(networkTaskType, error: error)
    }
}

// MARK: - Private

extension LoginViewModel {
    
    fileprivate static func createLoginContent(forPage page: PoqPage?) -> [MyProfileContentItem] {
        
        // Header image
        let urlString: String? = DeviceType.IS_IPAD ? page?.url : page?.thumbnailUrl
        let headerInputItem = MyProfileInputItem(title: AppLocalization.sharedInstance.signinTitle, value: urlString)
        let header = MyProfileContentItem(type: .headerImage, inputItem: headerInputItem)
        
        var res = [header, MyProfileContentItem.createDefaultEmailItem(), MyProfileContentItem.createDefaultPasswordItem()]
        
        if AppSettings.sharedInstance.signUpViewForPlatform == false {
            
            let value: String = LoginHelper.isMasterCard.toString()
            let switcherInputItem = MyProfileInputItem(title: AppLocalization.sharedInstance.signUpMasterCardText, value: value, controlTag: .dataSharingSwitch)
            let switcher = MyProfileContentItem(type: .dataSharing, inputItem: switcherInputItem)
            res.append(switcher)
        }
        
        // Submit button
        let submitButtonInputItem = MyProfileInputItem(title: AppLocalization.sharedInstance.loginSubmitButtonTitle)
        let submitButton = MyProfileContentItem(type: .submitButton, inputItem: submitButtonInputItem)
        res.append(submitButton)
        
        // Webview / terms&conditions
        let webViewInputItem = MyProfileInputItem(title: nil, value: page?.body)
        let webView = MyProfileContentItem(type: .webView, inputItem: webViewInputItem)
        res.append(webView)
        
        return res
    }
}
